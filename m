From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problem with NFS4,
	Error: state recovery failed on NFSv4	server 192.168.0.1 with error
	121
Date: Tue, 25 Sep 2007 11:20:27 -0400
Message-ID: <20070925152027.GC30845@fieldses.org>
References: <1190049122.6700.108.camel@heimdal.trondhjem.org>
	<1190056357.5541.12.camel@fry.u7.se>
	<1190059068.6700.125.camel@heimdal.trondhjem.org>
	<1190060733.5541.14.camel@fry.u7.se>
	<1190396486.6690.4.camel@heimdal.trondhjem.org>
	<20070922185227.GD403@fieldses.org>
	<1190668767.3958.9.camel@fry.u7.se>
	<20070924220247.GO26387@fieldses.org>
	<20070924222026.GP26387@fieldses.org>
	<1190722493.3935.3.camel@fry.u7.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jonas Jonsson <jonas@websystem.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IaCD8-0000ze-Jv
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 08:20:30 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IaCDA-0005EG-5E
	for nfs@lists.sourceforge.net; Tue, 25 Sep 2007 08:20:35 -0700
In-Reply-To: <1190722493.3935.3.camel@fry.u7.se>
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

T24gVHVlLCBTZXAgMjUsIDIwMDcgYXQgMDI6MTQ6NTNQTSArMDIwMCwgSm9uYXMgSm9uc3NvbiB3
cm90ZToKPiBtw6VuIDIwMDctMDktMjQga2xvY2thbiAxODoyMCAtMDQwMCBza3JldiBKLiBCcnVj
ZSBGaWVsZHM6Cj4gPiBPbiBNb24sIFNlcCAyNCwgMjAwNyBhdCAwNjowMjo0N1BNIC0wNDAwLCBi
ZmllbGRzIHdyb3RlOgo+ID4gPiBPSywgdGhhbmtzISAgTG9va3MgbGlrZSBpdCBzdGFydHMgb3V0
IGZhaXJseSBub3JtYWxseSwgdGhlbiBhdCBwYWNrZXQKPiA+ID4gODI0IGl0IGdldHMgaW50byB0
aGlzIFNFVENMSUVOVElELT5ORlM0RVJSX1JFU09VUkNFIGxvb3AuICBJJ20gbm90IHN1cmUKPiA+
ID4gaG93IHRoYXQgaGFwcGVuZWQuCj4gPiA+IAo+ID4gPiBJJ20gYSBsaXR0bGUgdW5jbGVhciB3
aGV0aGVyIFJFU09VUkNFIGlzIHN1cHBvc2VkIHRvIGJlIGEgdGVtcG9yYXJ5Cj4gPiA+IGVycm9y
IG9yIG5vdCwgYnV0IGluIGVpdGhlciBjYXNlIHJldHJ5aW5nIGl0IGluZGVmaW5pdGVseSB3aXRo
IG5vIGRlbGF5Cj4gPiA+IGlzIHByb2JhYmx5IGEgYmFkIGlkZWEuICBCdXQgSSBndWVzcyB0aGF0
J3Mgbm90IHRoZSBidWcuICBPSywgSSdsbCB0cnkKPiA+ID4gdG8gZmlndXJlIG91dCB3aGF0IGxl
YWQgdXAgdG8gdGhhdC4uLi4KPiA+IAo+ID4gT2gsIGdvb2QgZ3JpZWYsIHdlJ3JlIGxhbWUuICBD
b3VsZCB5b3UgY2hlY2sgeW91ciAuY29uZmlnLS1pcyBpdAo+ID4gcG9zc2libGUgeW91IGhhdmUg
Q09ORklHX0NSWVBUT19NRDUgdHVybmVkIG9mZj8gIElmIHNvLCBjb3VsZCB5b3UgdmVyaWZ5Cj4g
PiB0aGF0IHR1cm5pbmcgaXQgb24gZml4ZXMgdGhlIHByb2JsZW0/Cj4gPiAKPiA+IFRoZSByZWNv
dmVyeSBjb2RlIGlzIGJlaW5nIHNpbGx5IGFuZCByZXR1cm5pbmcgUkVTT1VSQ0UgaWYgaXQgY2Fu
J3QgbG9hZAo+ID4gdGhhdCBjcnlwdG8gbW9kdWxlLiAgQ3VycmVudCB1cHN0cmVhbSBkb2Vzbid0
IGFsbG93IGJ1aWxkaW5nIHY0IHdpdGhvdXQKPiA+IE1ENSwgc28geW91IHByb2JhYmx5IHdvbid0
IGJlIGFibGUgdG8gcmVwcm9kdWNlIHRoZSBwcm9ibGVtIG9uIHRoZQo+ID4gbGF0ZXN0IGtlcm5l
bC4KPiAKPiBZZXMsIHRoaXMgc29sdmVkIHRoZSBwcm9ibGVtLiBJIGhhZCB0aGUgTUQ1IGNvbXBp
bGVkIGFzIGEgbW9kdWxlLCBidXQgaXQKPiB3YXNuJ3QgbG9hZGVkIHdoZW4gbG9hZGluZyBuZnMg
bW9kdWxlLiBUaGlzIG1pZ2h0IGJlIGZpeGVkIGluIGxhdGVyCj4gdmVyc2lvbnMgb2YgdGhlIGtl
cm5lbC4KPiAKPiBIb3dldmVyLCBvbmUgdGhpbmcgaXMgc3RyYW5nZSwgd2h5IGRpZCBscyB3b3Jr
IHdoZW4gc3RhbmRpbmcgb3V0c2lkZSB0aGUKPiBORlMgbW91bnRlZCBmaWxlc3lzdGVtIG9uIHRo
ZSBjbGllbnQuIEJ1dCB3aGVuIEkgd2FzIHN0YW5kaW5nIGluIHRoZQo+IG1vdW50ZWQgZmlsZXN5
c3RlbSwgbHMgaGFuZ2VkLgoKVGhlIHByb2JsZW0gd291bGQgb2NjdXIgb24gdGhlIGZpcnN0IFNF
VENMSUVOVElELCB3aGljaCBzaG91bGQgaGFwcGVuIG9uCnRoZSBmaXJzdCBvcGVuIG9mIGEgcmVn
dWxhciBmaWxlLiAgSXMgdGhlcmUgc29tZSByZWFzb24geW91ciAnbHMnIGNvdWxkCmJlIHRyeWlu
ZyB0byBvcGVuIGEgZmlsZSBpbiB0aGUgY3VycmVudCB3b3JraW5nIGRpcmVjdG9yeT8gIFdpdGhv
dXQKdGhhdCwgSSdtIHN0dW1wZWQuCgotLWIuCgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tClRoaXMgU0YubmV0
IGVtYWlsIGlzIHNwb25zb3JlZCBieTogTWljcm9zb2Z0CkRlZnkgYWxsIGNoYWxsZW5nZXMuIE1p
Y3Jvc29mdChSKSBWaXN1YWwgU3R1ZGlvIDIwMDUuCmh0dHA6Ly9jbGsuYXRkbXQuY29tL01SVC9n
by92c2UwMTIwMDAwMDcwbXJ0L2RpcmVjdC8wMS8KX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX18KTkZTIG1haWxsaXN0ICAtICBORlNAbGlzdHMuc291cmNlZm9y
Z2UubmV0Cmh0dHBzOi8vbGlzdHMuc291cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL25mcwo=
