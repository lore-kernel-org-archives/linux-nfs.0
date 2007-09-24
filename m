From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	server 192.168.0.1 with error
	121
Date: Mon, 24 Sep 2007 18:02:47 -0400
Message-ID: <20070924220247.GO26387@fieldses.org>
References: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
	<1190048861.6700.105.camel@heimdal.trondhjem.org>
	<1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
	<1190060733.5541.14.camel@fry.u7.se>
	<1190396486.6690.4.camel@heimdal.trondhjem.org>
	<20070922185227.GD403@fieldses.org>
	<1190668767.3958.9.camel@fry.u7.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jonas Jonsson <jonas@websystem.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZw11-0008Ea-5q
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 15:02:55 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IZw12-0000Z0-HS
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 15:03:00 -0700
In-Reply-To: <1190668767.3958.9.camel@fry.u7.se>
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

T24gTW9uLCBTZXAgMjQsIDIwMDcgYXQgMTE6MTk6MjZQTSArMDIwMCwgSm9uYXMgSm9uc3NvbiB3
cm90ZToKPiBsw7ZyIDIwMDctMDktMjIga2xvY2thbiAxNDo1MiAtMDQwMCBza3JldiBKLiBCcnVj
ZSBGaWVsZHM6Cj4gPiBPbiBGcmksIFNlcCAyMSwgMjAwNyBhdCAwMTo0MToyNlBNIC0wNDAwLCBU
cm9uZCBNeWtsZWJ1c3Qgd3JvdGU6Cj4gPiA+IFNvLCBpdCBsb29rcyBhcyBpZiB0aGUgc2VydmVy
IGlzIGhhbmdpbmcgaW4gbGF1bmRyb21hdF9tYWluLCBhbmQgdGhhdCBpcwo+ID4gPiBwcmV2ZW50
aW5nIHRoZSBjbGllbnQgZnJvbSByZWdpc3RlcmluZyBhIHNldGNsaWVudGlkLgo+ID4gPiAKPiA+
ID4gQnJ1Y2U/Cj4gPiAKPiA+IE5vIGlkZWEuICBTb3JyeSwganVzdCBjYXRjaGluZyB1cCBoZXJl
Li4uLiAgVGhpcyBpcyAxMDAlIHJlcHJvZHVjZWFibGU/Cj4gV2VsbCwgeWVzIEkgY2FuIHJlcHJv
ZHVjZSB0aGlzIG9uIG15IHNlcnZlciBtYWNoaW5lLiBJIGhhdmUgdHJpZWQKPiB2YXJpb3VzIGtl
cm5lbCB2ZXJzaW9uIGZyb20gMi42LjE5IHRvIDIuNi4yMi4zLiBIb3dldmVyIGl0J3Mgb25seSB0
aGF0Cj4gbWFjaGluZSBJIGNhbiByZXByb2R1Y2UgdGhpcyBwcm9ibGVtIG9uLgo+ID4gV291bGQg
aXQgYmUgcG9zc2libGUgdG8gc2VlIGEgbmV0d29yayB0cmFjZT8gICh0Y3BkdW1wIC1zMCAtd3Rt
cC5wY2FwLAo+ID4gdGhlbiBzZW5kIG1lIHRtcC5wY2FwLiAgSWRlYWxseSBpdCBzaG91bGQgY292
ZXIgdGhlIHdob2xlIHRpbWUgZnJvbSB0aGUKPiA+IGluaXRpYWwgbW91bnQgdG8gdGhlIGZpcnN0
IHN5bXB0b21zIG9mIHRoZSBwcm9ibGVtKS4KPiAKPiBUaGUgdG1wLnBjYXAgZmlsZSBpcyBodWdl
LCA0N21iIEkgYnppcDIgaXQgYW5kIHB1dCBpdCBoZXJlCj4gaHR0cDovL3U3LnNlL3RtcC5wY2Fw
LmJ6MgoKT0ssIHRoYW5rcyEgIExvb2tzIGxpa2UgaXQgc3RhcnRzIG91dCBmYWlybHkgbm9ybWFs
bHksIHRoZW4gYXQgcGFja2V0CjgyNCBpdCBnZXRzIGludG8gdGhpcyBTRVRDTElFTlRJRC0+TkZT
NEVSUl9SRVNPVVJDRSBsb29wLiAgSSdtIG5vdCBzdXJlCmhvdyB0aGF0IGhhcHBlbmVkLgoKSSdt
IGEgbGl0dGxlIHVuY2xlYXIgd2hldGhlciBSRVNPVVJDRSBpcyBzdXBwb3NlZCB0byBiZSBhIHRl
bXBvcmFyeQplcnJvciBvciBub3QsIGJ1dCBpbiBlaXRoZXIgY2FzZSByZXRyeWluZyBpdCBpbmRl
ZmluaXRlbHkgd2l0aCBubyBkZWxheQppcyBwcm9iYWJseSBhIGJhZCBpZGVhLiAgQnV0IEkgZ3Vl
c3MgdGhhdCdzIG5vdCB0aGUgYnVnLiAgT0ssIEknbGwgdHJ5CnRvIGZpZ3VyZSBvdXQgd2hhdCBs
ZWFkIHVwIHRvIHRoYXQuLi4uCgotLWIuCgo+IAo+IEkgcnVuIGFuIGxkYXAgc2VydmVyIG9uIGJl
bmRlcigxOTIuMTY4LjAuMSwgdGhlIHNlcnZlcikuIGZyeQo+ICgxOTIuMTY4LjAuNCwgY2xpZW50
KS4KCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0KVGhpcyBTRi5uZXQgZW1haWwgaXMgc3BvbnNvcmVkIGJ5OiBN
aWNyb3NvZnQKRGVmeSBhbGwgY2hhbGxlbmdlcy4gTWljcm9zb2Z0KFIpIFZpc3VhbCBTdHVkaW8g
MjAwNS4KaHR0cDovL2Nsay5hdGRtdC5jb20vTVJUL2dvL3ZzZTAxMjAwMDAwNzBtcnQvZGlyZWN0
LzAxLwpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpORlMg
bWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5uZXQKaHR0cHM6Ly9saXN0cy5zb3Vy
Y2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCg==
