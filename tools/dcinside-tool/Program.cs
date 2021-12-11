using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using HtmlAgilityPack;
using Newtonsoft.Json;

namespace dcinside_tool
{
    class Program
    {
        public static string DownloadString(string address)
        {
            WebClient client = new WebClient();
            string reply = client.DownloadString(address);

            return reply;
        }

        /// <summary>
        /// 일반 갤러리의 리스트를 가져옵니다.
        /// </summary>
        /// <returns></returns>
        public static SortedDictionary<string, string> GetGalleryList()
        {
            var dic = new SortedDictionary<string, string>();
            var src = DownloadString("http://wstatic.dcinside.com/gallery/gallindex_iframe_new_gallery.html");

            var parse = new List<Match>();
            parse.AddRange(Regex.Matches(src, @"onmouseover=""gallery_view\('(\w+)'\);""\>[\s\S]*?\<.*?\>([\w\s]+)\<").Cast<Match>().ToList());
            parse.AddRange(Regex.Matches(src, @"onmouseover\=""gallery_view\('(\w+)'\);""\>\s*([\w\s]+)\<").Cast<Match>().ToList());

            foreach (var match in parse)
            {
                var identification = match.Groups[1].Value;
                var name = match.Groups[2].Value.Trim();

                if (!string.IsNullOrEmpty(name))
                {
                    if (name[0] == '-')
                        name = name.Remove(0, 1).Trim();
                    if (!dic.ContainsKey(name))
                        dic.Add(name, identification);
                }
            }

            return dic;
        }

        public static SortedDictionary<string, string> GetMinorGalleryList()
        {
            var dic = new SortedDictionary<string, string>();
            var html = DownloadString("https://gall.dcinside.com/m");

            HtmlDocument document = new HtmlDocument();
            document.LoadHtml(html);
            foreach (var a in document.DocumentNode.SelectNodes("//a[@onmouseout='thumb_hide();']"))
                dic.Add(a.InnerText.Trim(), a.GetAttributeValue("href", "").Split('=').Last());

            var under_name = new List<string>();
            foreach (var b in document.DocumentNode.SelectNodes("//button[@class='btn_cate_more']"))
                under_name.Add(b.GetAttributeValue("data-lyr", ""));

            int count = 1;
            foreach (var un in under_name)
            {
            RETRY:
                //var wc = NetCommon.GetDefaultClient();
                //wc.Headers.Add("X-Requested-With", "XMLHttpRequest");
                //wc.QueryString.Add("under_name", un);
                //var subhtml = Encoding.UTF8.GetString(wc.UploadValues("https://gall.dcinside.com/ajax/minor_ajax/get_under_gall", "POST", wc.QueryString));
                var subhtml = DownloadString($"https://wstatic.dcinside.com/gallery/mgallindex_underground/{un}.html");
                if (subhtml.Trim() == "")
                {
                    Console.WriteLine($"[{count}/{under_name.Count}] Retry {un}...");
                    goto RETRY;
                }

                HtmlDocument document2 = new HtmlDocument();
                document2.LoadHtml(subhtml);
                foreach (var c in document2.DocumentNode.SelectNodes("//a[@class='list_title']"))
                    if (!dic.ContainsKey(c.InnerText.Trim()))
                        dic.Add(c.InnerText.Trim(), c.GetAttributeValue("href", "").Split('=').Last());
                Console.WriteLine($"[{count++}/{under_name.Count}] Complete {un}");
            }

            return dic;
        }

        static void Main(string[] args)
        {
            foreach (var x in GetGalleryList())
            {
                Console.WriteLine($"\"{x.Key}\": \"{x.Value}\",");
            }
        }
    }
}
