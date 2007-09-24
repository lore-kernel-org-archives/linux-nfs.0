From: Jonas Jonsson <jonas@websystem.se>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	 server 192.168.0.1 with
	error 121
Date: Mon, 24 Sep 2007 23:19:26 +0200
Message-ID: <1190668767.3958.9.camel@fry.u7.se>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
	<1190048861.6700.105.camel@heimdal.trondhjem.org>
	<1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
	<1190060733.5541.14.camel@fry.u7.se>
	<1190396486.6690.4.camel@heimdal.trondhjem.org>
	<20070922185227.GD403@fieldses.org>
Reply-To: jonas@websystem.se
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZvMg-00041F-DM
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 14:21:14 -0700
Received: from gonzzor.campus.luth.se ([130.240.199.196] helo=bender.u7.se)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZvMj-0002ce-2l
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 14:21:19 -0700
In-Reply-To: <20070922185227.GD403@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

bMO2ciAyMDA3LTA5LTIyIGtsb2NrYW4gMTQ6NTIgLTA0MDAgc2tyZXYgSi4gQnJ1Y2UgRmllbGRz
Ogo+IE9uIEZyaSwgU2VwIDIxLCAyMDA3IGF0IDAxOjQxOjI2UE0gLTA0MDAsIFRyb25kIE15a2xl
YnVzdCB3cm90ZToKPiA+IFNvLCBpdCBsb29rcyBhcyBpZiB0aGUgc2VydmVyIGlzIGhhbmdpbmcg
aW4gbGF1bmRyb21hdF9tYWluLCBhbmQgdGhhdCBpcwo+ID4gcHJldmVudGluZyB0aGUgY2xpZW50
IGZyb20gcmVnaXN0ZXJpbmcgYSBzZXRjbGllbnRpZC4KPiA+IAo+ID4gQnJ1Y2U/Cj4gCj4gTm8g
aWRlYS4gIFNvcnJ5LCBqdXN0IGNhdGNoaW5nIHVwIGhlcmUuLi4uICBUaGlzIGlzIDEwMCUgcmVw
cm9kdWNlYWJsZT8KV2VsbCwgeWVzIEkgY2FuIHJlcHJvZHVjZSB0aGlzIG9uIG15IHNlcnZlciBt
YWNoaW5lLiBJIGhhdmUgdHJpZWQKdmFyaW91cyBrZXJuZWwgdmVyc2lvbiBmcm9tIDIuNi4xOSB0
byAyLjYuMjIuMy4gSG93ZXZlciBpdCdzIG9ubHkgdGhhdAptYWNoaW5lIEkgY2FuIHJlcHJvZHVj
ZSB0aGlzIHByb2JsZW0gb24uCj4gV291bGQgaXQgYmUgcG9zc2libGUgdG8gc2VlIGEgbmV0d29y
ayB0cmFjZT8gICh0Y3BkdW1wIC1zMCAtd3RtcC5wY2FwLAo+IHRoZW4gc2VuZCBtZSB0bXAucGNh
cC4gIElkZWFsbHkgaXQgc2hvdWxkIGNvdmVyIHRoZSB3aG9sZSB0aW1lIGZyb20gdGhlCj4gaW5p
dGlhbCBtb3VudCB0byB0aGUgZmlyc3Qgc3ltcHRvbXMgb2YgdGhlIHByb2JsZW0pLgoKVGhlIHRt
cC5wY2FwIGZpbGUgaXMgaHVnZSwgNDdtYiBJIGJ6aXAyIGl0IGFuZCBwdXQgaXQgaGVyZQpodHRw
Oi8vdTcuc2UvdG1wLnBjYXAuYnoyCgpJIHJ1biBhbiBsZGFwIHNlcnZlciBvbiBiZW5kZXIoMTky
LjE2OC4wLjEsIHRoZSBzZXJ2ZXIpLiBmcnkKKDE5Mi4xNjguMC40LCBjbGllbnQpLgoKPiAKPiBB
bmQgYXMgYWx3YXlzIGl0IG1pZ2h0IGJlIHdvcnRoIHRyeWluZyB0aGUgbGF0ZXN0IGtlcm5lbCwg
dGhvdWdoIG9uIGEKPiBxdWljayBza2ltIHRocm91Z2ggZ2l0IEkgY2FuJ3Qgc2VlIGFueXRoaW5n
IG9idmlvdXNseSByZWxhdGVkLgpDdXJyZW50bHkgcnVubmluZyAyLjYuMjItZ2VudG9vLXI1LCB0
aGlzIGlzIGFsbW9zdCBhbiB2YW5pbGxhIDIuNi4yMi4zCmtlcm5lbCwgdGhlIHBhdGNoZXMgYWRk
IHNob3VsZG4ndCBiZSByZWxhdGVkIHRvIHRoaXMgcHJvYmxlbS4KCkNhbiB0cnkgbGF0ZXN0IC1n
aXQgdHJlZSBmcm9tIGtlcm5lbC5vcmcgbGF0ZXIgb24uCgovSm9uYXMKPiAKPiAtLWIuCgoKLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBlbWFpbCBpcyBzcG9uc29yZWQgYnk6IE1pY3Jvc29m
dApEZWZ5IGFsbCBjaGFsbGVuZ2VzLiBNaWNyb3NvZnQoUikgVmlzdWFsIFN0dWRpbyAyMDA1Lgpo
dHRwOi8vY2xrLmF0ZG10LmNvbS9NUlQvZ28vdnNlMDEyMDAwMDA3MG1ydC9kaXJlY3QvMDEvCl9f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCk5GUyBtYWlsbGlz
dCAgLSAgTkZTQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJjZWZvcmdl
Lm5ldC9saXN0cy9saXN0aW5mby9uZnMK
