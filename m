From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: simple question about r/wsize
Date: Mon, 01 Oct 2007 23:05:40 -0400
Message-ID: <1191294340.6611.34.camel@heimdal.trondhjem.org>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447540@exchrdm.ad.xensource.com>
	<1191280261.6611.19.camel@heimdal.trondhjem.org>
	<4701B24C.2070102@oxeva.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: Gabriel Barazer <gabriel@oxeva.fr>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcY59-000173-4m
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 20:05:59 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcY5C-0004Nu-K5
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 20:06:04 -0700
In-Reply-To: <4701B24C.2070102@oxeva.fr>
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

T24gVHVlLCAyMDA3LTEwLTAyIGF0IDA0OjUxICswMjAwLCBHYWJyaWVsIEJhcmF6ZXIgd3JvdGU6
Cj4gT24gMTAvMDIvMjAwNyAxOjExOjAxIEFNICswMjAwLCBUcm9uZCBNeWtsZWJ1c3QgCj4gPHRy
b25kLm15a2xlYnVzdEBmeXMudWlvLm5vPiB3cm90ZToKPiA+IE9uIE1vbiwgMjAwNy0xMC0wMSBh
dCAxNTowNCAtMDcwMCwgV2ltIENvbGdhdGUgd3JvdGU6Cj4gPj4gV2hhdOKAmXMgdGhlIGN1cnJl
bnQgTkZTIHYzIHdzaXplIGFuZCByc2l6ZT8gSXQgYXBwZWFycyB0byBiZSA0SyDigJMgYW5kCj4g
Pj4ganVzdCB3YW50ZWQgYSBjb25maXJtYXRpb24uCj4gPj4KPiA+IAo+ID4gSXQgc291bmRzIGxp
a2UgeW91IGFyZSB3b3JraW5nIHdpdGggYW4gb2xkIHN5c3RlbS4gSUlSQywgb2xkZXIgdmVyc2lv
bnMKPiA+IG9mIFJlZEhhdCB1c2VkIHRvIGppbW15IHRoZSAnbW91bnQnIGNvbW1hbmQgdG8gbWFr
ZSA0ayB0aGUgZGVmYXVsdCwKPiA+IGJlY2F1c2UgdGhhdCB3b3JrZWQgYmVzdCB3aXRoIFVEUCBt
b3VudHMgb24gY3J1bW15IG5ldHdvcmtzLgo+ID4gCj4gPiBGb3IgbmV3ZXIgY2xpZW50cywgdGhl
IGRlZmF1bHQgc2hvdWxkIGRlcGVuZCBvbiB3aGF0IHlvdXIgc2VydmVyCj4gPiBzcGVjaWZpZXMg
aW4gdGhlIEZTSU5GTyBuZnMgY29tbWFuZC4gRm9yIG1vc3Qgc2VydmVycywgd2hlbiB5b3UgbW91
bnQKPiA+IHdpdGggYSBUQ1AgY29ubmVjdGlvbiwgdGhlIGRlZmF1bHQgd2lsbCBiZSAzMmssIGJ1
dCBzb21lIG1heSBoYXZlIGxhcmdlcgo+ID4gZGVmYXVsdHMgKE5ldEFwcCBzZXJ2ZXJzIG9mdGVu
IHNwZWNpZnkgYSA2NGsgZGVmYXVsdCkgb3Igc21hbGxlciAob2xkZXIKPiA+IExpbnV4IHNlcnZl
cnMgd2lsbCBzdXBwb3J0IGFuIDhrIG1heGltdW0pLgo+IAo+IEkgc2VlIG9uIG15IHNlcnZlcnMg
KD4yLjYuMjEsIGxhdGVzdCBuZnMtdXRpbHMpIHRoYXQgdGhlIHJzaXplL3dzaXplIGlzIAo+IGFj
dHVhbGx5IGRlZmluZWQgYnkgdGhlIGFtb3VudCBvZiBtZW1vcnkgb24gdGhlIE5GUyBzZXJ2ZXIu
IEl0IHNlZW1zIHRvIAo+IHNldCB0aGUgcnNpemUvd3NpemUgdG8gKHRvdGFsIG1lbW9yeSkvODE5
MiAoNTEyayBpbiBteSBjYXNlIGZvciBhIDRHQiAKPiBuZnMgc2VydmVyKS4gSXMgaXQgYSBidWcg
b3IgYSB3YW50ZWQgYmVoYXZpb3IgPwoKT24gYSBzdGFuZGFyZCAyLjYuMjMtcmM4LCB0aGUgc2Vy
dmVyIHNldHMgUlBDU1ZDX01BWFBBWUxPQURfVENQID09IDFNQiwKUlBDU1ZDX01BWFBBWUxPQURf
VURQID09IDMyay4gVGhlcmUgaXMgbm8gbGluayB0byB0aGUgdG90YWwgYW1vdW50IG9mCm1lbW9y
eS4KClRyb25kCgoKLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpUaGlzIFNGLm5ldCBlbWFpbCBpcyBzcG9uc29y
ZWQgYnk6IE1pY3Jvc29mdApEZWZ5IGFsbCBjaGFsbGVuZ2VzLiBNaWNyb3NvZnQoUikgVmlzdWFs
IFN0dWRpbyAyMDA1LgpodHRwOi8vY2xrLmF0ZG10LmNvbS9NUlQvZ28vdnNlMDEyMDAwMDA3MG1y
dC9kaXJlY3QvMDEvCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fCk5GUyBtYWlsbGlzdCAgLSAgTkZTQGxpc3RzLnNvdXJjZWZvcmdlLm5ldApodHRwczovL2xp
c3RzLnNvdXJjZWZvcmdlLm5ldC9saXN0cy9saXN0aW5mby9uZnMK
