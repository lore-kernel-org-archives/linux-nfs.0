From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 12:57:48 -0400
Message-ID: <1187024268.6628.33.camel@heimdal.trondhjem.org>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
	<1187021560.6628.7.camel@heimdal.trondhjem.org>
	<1187022103.6628.12.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0708131838580.19529@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKdEs-0003Pz-G2
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:57:58 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+1mm2CQrWQRPNQ5damEzd/QLdVjYH0SVA=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKdEu-000135-ET
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:58:02 -0700
In-Reply-To: <Pine.LNX.4.64.0708131838580.19529@maggie.lkpg.cendio.se>
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

T24gTW9uLCAyMDA3LTA4LTEzIGF0IDE4OjQ2ICswMjAwLCBQZXRlciDDhXN0cmFuZCB3cm90ZToK
PiBPbiBNb24sIDEzIEF1ZyAyMDA3LCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6Cj4gCj4gPj4gV2Vs
bCwgbm8gY3VzdG9tZXJzIHdlcmUgY29tcGxhaW5pbmcsIHNvIGl0IHdhc24ndCBtdWNoIG9mIGEg
cHJpb3JpdHkuLi4KPiA+PiAKPiA+PiBDYW4geW91IHNheSAnY2lyY3VsYXIgYXJndW1lbnQnPwo+
ID5Db3VsZCB3ZSBhZGQgYSBDT05GSUcgb3B0aW9uIHRvIGVuYWJsZSByZWdyZXNzaXZlIGRpc3Ry
aWJ1dGlvbnMgdG8gdHVybgo+ID50aGlzIGZlYXR1cmUgb2ZmPyAKPiAKPiBJdCB3b3VsZCBiZSBt
dWNoIG1vcmUgdXNlZnVsIHdpdGggYSBnbGliYyBydW50aW1lIGNvbmZpZ3VyYXRpb24uIAoKUG9z
c2libHkuCgo+ID5JJ20gc2ljayBhbmQgdGlyZWQgb2YgaGF2aW5nIHRvIGNvbnN0YW50bHkgcG9z
dHBvbmUgbmVjZXNzYXJ5IAo+ID5mdW5jdGlvbmFsaXR5IGp1c3QgYmVjYXVzZSBhcHBsaWNhdGlv
biB3cml0ZXJzIGFyZW4ndCBjYXBhYmxlIG9mIGNvZGluZyAKPiA+dXAgc3RhbmRhcmRzIGNvbXBs
aWFudCBwcm9ncmFtcy4KPiAKPiBJIGRvbid0IHVuZGVyc3RhbmQgdGhpcyBsb2dpYy4gV2hhdCBr
aW5kIG9mIHN0YW5kYXJkIGlzIGEgMzIgYml0IG5vbi1MRlMgCj4gYXBwIGJyZWFraW5nPwoKSWYg
aXQgaXNuJ3QgY2FwYWJsZSBvZiBkZWFsaW5nIHdpdGggdGhlIHBvc3NpYmlsaXR5IG9mIEVPVkVS
RkxPVywgdGhlbgppdCBpcyB2aW9sYXRpbmcgdGhlIFNpbmdsZSBVbml4IFNwZWMuCgpJZiBpdCBp
cyBtYWtpbmcgYXNzdW1wdGlvbnMgYWJvdXQgdGhlIHNpemUgb2Ygc3RfaW5vLCB0aGVuIGl0IGlz
CnZpb2xhdGluZyBub3Qgb25seSBTVVMsIGJ1dCBhbHNvIFBPU0lYLCB3aGljaCBkb2VzIG5vdyBt
YW5kYXRlIHRoZSB1c2UKb2YgdGhlIHNwZWNpZmljIHR5cGVzOgoKICBodHRwOi8vd3d3Lm9wZW5n
cm91cC5vcmcvb25saW5lcHVicy8wMDk2OTUzOTkvdG9jLmh0bQoKPiBXaGF0IGtpbmQgb2YgZnVu
Y3Rpb25hbGl0eSBhcmUgeW91IHRoaW5raW5nIG9mPyAxMDAlIGd1YXJhbnRlZWQgdW5pcXVlIAo+
IGlub2RlIG51bWJlcnMsIGFzc3VtaW5nIHRoYXQgYWxsIGZpbGVpZHMgYXJlIHVuaXF1ZT8gWW91
IGFscmVhZHkgaGF2ZSB0aGF0IAo+IG9uIDY0IGJpdCBzeXN0ZW1zLCBhbmQgYXMgZmFyIGFzIEkg
dW5kZXJzdGFuZCwgaXQgc2hvdWxkIGJlIHBvc3NpYmxlIHRvIAo+IGdldCB0aGlzIGZvciBMRlMt
YXdhcmUgMzIgYml0IGFwcHMgYXMgd2VsbC4gCj4gCj4gT3IgYXJlIHlvdSByZWZlcnJpbmcgdG8g
MTAwJSBndWFyYW50ZWVkIHVuaXF1ZSBpbm9kZSBudW1iZXJzIGZvciAzMiBiaXQgCj4gYXBwcywg
TEZTIGF3YXJlIG9yIG5vdD8gV2h5IGlzIHRoaXMgaW1wb3J0YW50Pwo+IAo+IE9yIGFyZSB5b3Ug
dGhpbmtpbmcgb2Ygc29tZSBvdGhlciBmdW5jdGlvbmFsaXR5PwoKSWYgdGhlIHByb2dyYW0gaXMg
d3JpdHRlbiBpbiBhIG1hbm5lciB0aGF0IGlzIFBPU0lYIGNvbXBsaWFudCAoaS5lLiB1c2VzCnRo
ZSBjb3JyZWN0IHR5cGVzKSB0aGVuIHJlY29tcGlsaW5nIGZvciBhIDY0LWJpdCBMRlMgZW52aXJv
bm1lbnQgaXMKdHJpdmlhbC4KClRyb25kCgoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBl
bWFpbCBpcyBzcG9uc29yZWQgYnk6IFNwbHVuayBJbmMuClN0aWxsIGdyZXBwaW5nIHRocm91Z2gg
bG9nIGZpbGVzIHRvIGZpbmQgcHJvYmxlbXM/ICBTdG9wLgpOb3cgU2VhcmNoIGxvZyBldmVudHMg
YW5kIGNvbmZpZ3VyYXRpb24gZmlsZXMgdXNpbmcgQUpBWCBhbmQgYSBicm93c2VyLgpEb3dubG9h
ZCB5b3VyIEZSRUUgY29weSBvZiBTcGx1bmsgbm93ID4+ICBodHRwOi8vZ2V0LnNwbHVuay5jb20v
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCk5GUyBtYWls
bGlzdCAgLSAgTkZTQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJjZWZv
cmdlLm5ldC9saXN0cy9saXN0aW5mby9uZnMK
