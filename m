From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [patch] provide non-standard getgrouplist()
	in	libnfsidmap when need be
Date: Mon, 26 Mar 2007 11:46:43 -0400
Message-ID: <1174924003.6838.17.camel@heimdal.trondhjem.org>
References: <200703250329.03353.vapier@gentoo.org>
	<1174915365.6838.6.camel@heimdal.trondhjem.org>
	<Pine.LNX.4.64.0703261624130.12321@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net
To: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HVrPR-0004Y0-7f
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 08:47:01 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19IvuHFE6dfXVOcnvoO09jgAscomg3x5Xk=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HVrPR-0005QA-No
	for nfs@lists.sourceforge.net; Mon, 26 Mar 2007 08:47:03 -0700
In-Reply-To: <Pine.LNX.4.64.0703261624130.12321@maggie.lkpg.cendio.se>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

T24gTW9uLCAyMDA3LTAzLTI2IGF0IDE2OjMyICswMjAwLCBQZXRlciDDhXN0cmFuZCB3cm90ZToK
PiBPbiBNb24sIDI2IE1hciAyMDA3LCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6Cj4gCj4gPiBPbiBT
dW4sIDIwMDctMDMtMjUgYXQgMDM6MjkgLTA0MDAsIE1pa2UgRnJ5c2luZ2VyIHdyb3RlOgo+ID4g
PiBsaWJuZnNpZG1hcCB1c2VzIHRoZSBub24tc3RhbmRhcmQgZnVuY3Rpb24gZ2V0Z3JvdXBsaXN0
KCkgLi4uIHRoZSBhdHRhY2hlZCAKPiA+ID4gcGF0Y2ggdGFrZXMgY29kZSBmcm9tIEZyZWVCU0Qg
dG8gaW1wbGVtZW50IHRoZSBmdW5jdGlvbiBiYXNlZCBvbiBQT1NJWCAKPiA+ID4gZnVuY3Rpb25z
IHdoZW4gdGhlIHN5c3RlbSBsaWJjIGlzIG5vdCBzdWZmaWNpZW50Cj4gPiA+IC1taWtlCj4gPiAK
PiA+IFdoeSBub3QganVzdCBtb2RpZnkgbGlibmZzaWRtYXAgdG8gZGlyZWN0bHkgdXNlIHRoZSBw
b3NpeCBmdW5jdGlvbnM/Cj4gCj4gVGhlIHRyYWRpdGlvbmFsIHdheSBvZiBmZXRjaGluZyB0aGUg
bGlzdCBvZiB1c2VyIGdyb3VwcyBpcyB0byBlbnVtZXJhdGUgCj4gdGhlIGVudGlyZSBncm91cCBk
YXRhYmFzZSwgYW5kIHRoZW4gYWRkIHRoZSBncm91cHMgdGhhdCB0aGUgdXNlciBpcyBhIAo+IG1l
bWJlciBvZi4gVGhpcyBpcyAqdmVyeSogc2xvdyBvbiBzeXN0ZW1zIHdpdGggYSBsYXJnZSBudW1i
ZXIgb2YgdXNlcnMgYW5kIAo+IGdyb3Vwcy4gTWFueSBOU1MgYmFja2VuZHMsIHN1Y2ggYXMgbnNz
X2xkYXAsIHByb3ZpZGVzIGEgZmFzdGVyIEFQSSwgd2hpY2ggCj4gdXNlcyBzbWFydCBMREFQIHF1
ZXJpZXMgaW5zdGVhZC4gaW5pdGdyb3VwcygpIHVzZXMgdGhpcywgYW5kIHBlcmhhcHMgYWxzbwo+
IGdldGdyb3VwcygpLiAoSWYgbm90LCBpdCBuZWVkcyBhIGZpeC4pCj4gCj4gKEFzIGEgc2lkZSBu
b3RlLCB0aGVyZSdzIGEgbG90IG9mIHNvZnR3YXJlIG91dCB0aGVyZSB3aGljaCBlbnVtZXJhdGVz
IAo+IGdyb3VwcyB0aGUgc2xvdyB3YXkuIFRoaXMgaW5jbHVkZXMgdGhlIE9wZW5TU0ggc2VydmVy
LCBzbyBpZiB5b3UgYWN0aXZhdGUgCj4gdGhlIEFsbG93R3JvdXBzIGNvbmZpZ3VyYXRpb24gZGly
ZWN0aXZlLCBTU0ggbG9naW5zIHRha2VzIGZvcmV2ZXIgb24gCj4gbGFyZ2Ugc3lzdGVtcy4pCgpX
ZSdyZSBub3QgYWZ0ZXIgdGhlIGZ1bGwgbGlzdCBvZiB1c2VyIGdyb3VwcyBvciB0aGUgZ3JvdXAg
ZW50cmllcy4KbGlibmZzaWRtYXAgZXhpc3RzIHB1cmVseSBpbiBvcmRlciB0byBtYXAgYSBzaW5n
bGUgZ2lkIGludG8gYSBncm91cCBuYW1lCm9yIHZpY2UgdmVyc2EgYW5kIHRoZW4gc3R1ZmYgdGhl
IHJlc3VsdCBpbnRvIGEga2VybmVsIGNhY2hlLgoKSU9XOiBpdCBzaG91bGQgYmUganVzdCBmaW5l
IHRvIGNhbGwgZ2V0Z3JnaWQoKSBvciBnZXRncm5hbSgpIGluIHRoZQphcHByb3ByaWF0ZSBwbGFj
ZXMuCgpDaGVlcnMKICBUcm9uZAoKCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KVGFrZSBTdXJ2ZXlzLiBFYXJu
IENhc2guIEluZmx1ZW5jZSB0aGUgRnV0dXJlIG9mIElUCkpvaW4gU291cmNlRm9yZ2UubmV0J3Mg
VGVjaHNheSBwYW5lbCBhbmQgeW91J2xsIGdldCB0aGUgY2hhbmNlIHRvIHNoYXJlIHlvdXIKb3Bp
bmlvbnMgb24gSVQgJiBidXNpbmVzcyB0b3BpY3MgdGhyb3VnaCBicmllZiBzdXJ2ZXlzLWFuZCBl
YXJuIGNhc2gKaHR0cDovL3d3dy50ZWNoc2F5LmNvbS9kZWZhdWx0LnBocD9wYWdlPWpvaW4ucGhw
JnA9c291cmNlZm9yZ2UmQ0lEPURFVkRFVgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fXwpORlMgbWFpbGxpc3QgIC0gIE5GU0BsaXN0cy5zb3VyY2Vmb3JnZS5u
ZXQKaHR0cHM6Ly9saXN0cy5zb3VyY2Vmb3JnZS5uZXQvbGlzdHMvbGlzdGluZm8vbmZzCg==
