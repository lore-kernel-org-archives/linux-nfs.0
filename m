From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.21.3: NFS: Buggy server - nlink == 0!
Date: Wed, 06 Jun 2007 08:33:17 -0400
Message-ID: <1181133197.6171.7.camel@heimdal.trondhjem.org>
References: <20070606081303.GB7168@localdomain>
	<Pine.LNX.4.64.0706061221340.18979@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Ravikiran G Thirumalai <kiran@scalex86.org>
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HvuhW-0005F8-Bw
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 05:33:22 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1//84SZzYwBhw5IGYcniyMiQy5ZhoACE9I=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HvuhY-00031q-QO
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 05:33:25 -0700
In-Reply-To: <Pine.LNX.4.64.0706061221340.18979@maggie.lkpg.cendio.se>
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

T24gV2VkLCAyMDA3LTA2LTA2IGF0IDEyOjI1ICswMjAwLCBQZXRlciDDhXN0cmFuZCB3cm90ZToK
PiBPbiBXZWQsIDYgSnVuIDIwMDcsIFJhdmlraXJhbiBHIFRoaXJ1bWFsYWkgd3JvdGU6Cj4gCj4g
PiBXaGlsZSBydW5uaW5nIGEgZGJlbmNoIHN0cmVzcyB0ZXN0IG9uICBhIG5mcyBtb3VudGVkIGZp
bGUgc3lzdGVtLCBJIG5vdGljZQo+ID4gdGhlIHN1YmplY3QgZXJyb3IgbWVzc2FnZSBvbiB0aGUg
Y2xpZW50IG1hY2hpbmUuICBUaGUgY2xpZW50IG1hY2hpbmUgaXMgYSA0OAo+ID4gY29yZSBib3gg
d2l0aCBOVU1BIGNoYXJhY3RlcmlzdGljcyBhbmQgMTAyNCBkYmVuY2ggcHJvY2Vzc2VzIHJ1bm5p
bmcKPiA+IGNvbnRpbnVvdXNseSBpbiBhIGxvb3AsIHdoaWxlIGFub3RoZXIgbWVtb3J5IGhvZyBh
cHBsaWNhdGlvbiBydW5zIGluIHBhcmFsbGVsLgo+ID4gVGhlIGNsaWVudCBpcyBvbiAyLjYuMjEu
My4gIFRoZSBzZXJ2ZXIgaXMgYm9vdGVkIHVwIHdpdGggMi42LjIxLjMgYXMgd2VsbC4KPiA+IEF0
dGFjaGVkIGlzIHRoZSBzZXJ2ZXIgY29uZmlndXJhdGlvbi4gIFNhbWUgdGVzdCBvbiBhIDIuNi4x
NiBjbGllbnQgZG9lcyBub3QKPiA+IHNwZXcgb3V0IHRoZXNlIG1lc3NhZ2VzLiAgSXMgdGhpcyBy
ZWFsbHkgdGhlIHNlcnZlciBpc3N1ZSwgb3IgaXMgdGhlIE5GUwo+ID4gY2xpZW50IHRvIGJlIGJs
YW1lZCBoZXJlPwo+IAo+IEkndmUgc2VlbiB0aGlzIG1lc3NhZ2Ugd2l0aCB0aGUgdW5mczMgc2Vy
dmVyIGFzIHdlbGwsIGFuZCBpdCBjb250YWlucyBzb21lIAo+IGV4cGxpY2l0IGNoZWNrcyB0byBh
dm9pZCBzZW5kaW5nIG5saW5rPTAuIFNvIHRoaXMgaXMgYW5vdGhlciBpbmRpY2F0aW9uIAo+IHRo
YXQgdGhpcyBpcyBhY3R1YWxseSBhIGNsaWVudCBwcm9ibGVtLgoKRmVlbCBmcmVlIHRvIHNlbmQg
YSB0Y3BkdW1wIHRvIHByb3ZlIGl0LiBTbyBmYXIgYWxsIGNhc2VzIEkndmUgZXZlciBzZWVuCm9m
IHRoaXMgZXJyb3IgbWVzc2FnZSBoYXZlIGJlZW4gc2VydmVycyBzZW5kaW5nIGNyYXAgYmFjayBm
b3IgTE9PS1VQCmNhbGxzLiBUaGUgY2xpZW50IGRvZXMgbm90IGV2ZXIgbW9kaWZ5IHRoZSBzdHJ1
Y3QgbmZzX2ZhdHRyIGFmdGVyIGl0IGhhcwpkZWNvZGVkIHRoZSBzZXJ2ZXIgcmVwbHkuCgpUcm9u
ZAoKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0KVGhpcyBTRi5uZXQgZW1haWwgaXMgc3BvbnNvcmVkIGJ5IERC
MiBFeHByZXNzCkRvd25sb2FkIERCMiBFeHByZXNzIEMgLSB0aGUgRlJFRSB2ZXJzaW9uIG9mIERC
MiBleHByZXNzIGFuZCB0YWtlCmNvbnRyb2wgb2YgeW91ciBYTUwuIE5vIGxpbWl0cy4gSnVzdCBk
YXRhLiBDbGljayB0byBnZXQgaXQgbm93LgpodHRwOi8vc291cmNlZm9yZ2UubmV0L3Bvd2VyYmFy
L2RiMi8KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTkZT
IG1haWxsaXN0ICAtICBORlNAbGlzdHMuc291cmNlZm9yZ2UubmV0Cmh0dHBzOi8vbGlzdHMuc291
cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL25mcwo=
