From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 64 bit ino support for NFS client
Date: Mon, 13 Aug 2007 12:12:40 -0400
Message-ID: <1187021560.6628.7.camel@heimdal.trondhjem.org>
References: <46B37CDE.1070904@redhat.com>
	<Pine.LNX.4.64.0708131511470.15451@maggie.lkpg.cendio.se>
	<46C05C40.30707@redhat.com>
	<Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Peter Staubach <staubach@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	NFS List <nfs@lists.sourceforge.net>
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKcXp-0006UV-Oj
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:13:29 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/coXyNeEC46q+yBSqUkJbtefnNaGvQdRs=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKcXr-0001IU-Ju
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 09:13:34 -0700
In-Reply-To: <Pine.LNX.4.64.0708131555330.15782@maggie.lkpg.cendio.se>
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

T24gTW9uLCAyMDA3LTA4LTEzIGF0IDE2OjEyICswMjAwLCBQZXRlciDDhXN0cmFuZCB3cm90ZToK
Cj4gU3VyZSwgYnV0IHRvIHByZXZlbnQgY3VzdG9tZXIgdW5oYXBwaW5lc3MsIGl0J3MgbXVjaCBi
ZXR0ZXIgdG8gdXBkYXRlIHRoZSAKPiBhcHBsaWNhdGlvbnMgaW4gYSBjZXJ0YWluIGRpc3RyaWJ1
dGlvbiAqYmVmb3JlKiBjaGFuZ2luZyB0aGUgd29ybGQgYXJvdW5kIAo+IHRoZW0uIEknbSBhcmd1
aW5nIHRoYXQgYSB0eXBpY2FsIGN1c3RvbWVyIHdvdWxkIHJhdGhlciBiZWluZyBhYmxlIHRvIHJ1
biAKPiBPcGVuT2ZmaWNlIHRoYW4gbGl2ZSBpbiB0b21vcnJvd3Mgd29ybGQuCgo+IEFub3RoZXIg
cmVhc29uIHdoeSBJJ20gbm90IGNvbnZpbmNlZCBvZiB0aGlzIHBhdGNoIGlzIHRoYXQgSSBoYXZl
bid0IGhlYXJkIAo+IGFueSBhcmd1bWVudHMgd2h5IHRoaXMgaXMgdGhlIHRpbWUgdG8gYnJlYWsg
Y29tcGF0aWJpbGl0eSB3aXRoIAo+IDMyIGJpdCBub24tTEZTIGFwcHMuIFdoeSBub3QgdG9tb3Jy
b3csIHllc3RlcmRheSBvciAxMCB5ZWFycyBhZ28/IFdoeSBub3c/IAoKVGhpcyBhcmd1bWVudCBn
ZXRzIHRyb3R0ZWQgb3V0IGV2ZXJ5IGZyaWdnaW5nIHRpbWUgc29tZW9uZSBwcm9wb3NlcyBhCnBh
dGNoIG9mIHRoaXMgc29ydC4gMTIgbW9udGhzIGxhdGVyLCBhbm90aGVyIHBhdGNoIGNvbWVzIG91
dCwgYW5kIHdlCmRpc2NvdmVyIHRoYXQgdXNlcmxhbmQgaGFzbid0IGNoYW5nZWQuCgpXaHkgaGFz
bid0IGl0IGNoYW5nZWQ/CgpXZWxsLCBubyBjdXN0b21lcnMgd2VyZSBjb21wbGFpbmluZywgc28g
aXQgd2Fzbid0IG11Y2ggb2YgYSBwcmlvcml0eS4uLgoKQ2FuIHlvdSBzYXkgJ2NpcmN1bGFyIGFy
Z3VtZW50Jz8KClRyb25kCgoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBlbWFpbCBpcyBz
cG9uc29yZWQgYnk6IFNwbHVuayBJbmMuClN0aWxsIGdyZXBwaW5nIHRocm91Z2ggbG9nIGZpbGVz
IHRvIGZpbmQgcHJvYmxlbXM/ICBTdG9wLgpOb3cgU2VhcmNoIGxvZyBldmVudHMgYW5kIGNvbmZp
Z3VyYXRpb24gZmlsZXMgdXNpbmcgQUpBWCBhbmQgYSBicm93c2VyLgpEb3dubG9hZCB5b3VyIEZS
RUUgY29weSBvZiBTcGx1bmsgbm93ID4+ICBodHRwOi8vZ2V0LnNwbHVuay5jb20vCl9fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCk5GUyBtYWlsbGlzdCAgLSAg
TkZTQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xpc3RzLnNvdXJjZWZvcmdlLm5ldC9s
aXN0cy9saXN0aW5mby9uZnMK
