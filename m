From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: simple question about r/wsize
Date: Tue, 02 Oct 2007 04:51:56 +0200
Message-ID: <4701B24C.2070102@oxeva.fr>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447540@exchrdm.ad.xensource.com>
	<1191280261.6611.19.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcXrf-0008C6-Go
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 19:52:03 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcXri-0003HG-SN
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 19:52:08 -0700
In-Reply-To: <1191280261.6611.19.camel@heimdal.trondhjem.org>
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

T24gMTAvMDIvMjAwNyAxOjExOjAxIEFNICswMjAwLCBUcm9uZCBNeWtsZWJ1c3QgCjx0cm9uZC5t
eWtsZWJ1c3RAZnlzLnVpby5ubz4gd3JvdGU6Cj4gT24gTW9uLCAyMDA3LTEwLTAxIGF0IDE1OjA0
IC0wNzAwLCBXaW0gQ29sZ2F0ZSB3cm90ZToKPj4gV2hhdOKAmXMgdGhlIGN1cnJlbnQgTkZTIHYz
IHdzaXplIGFuZCByc2l6ZT8gSXQgYXBwZWFycyB0byBiZSA0SyDigJMgYW5kCj4+IGp1c3Qgd2Fu
dGVkIGEgY29uZmlybWF0aW9uLgo+Pgo+IAo+IEl0IHNvdW5kcyBsaWtlIHlvdSBhcmUgd29ya2lu
ZyB3aXRoIGFuIG9sZCBzeXN0ZW0uIElJUkMsIG9sZGVyIHZlcnNpb25zCj4gb2YgUmVkSGF0IHVz
ZWQgdG8gamltbXkgdGhlICdtb3VudCcgY29tbWFuZCB0byBtYWtlIDRrIHRoZSBkZWZhdWx0LAo+
IGJlY2F1c2UgdGhhdCB3b3JrZWQgYmVzdCB3aXRoIFVEUCBtb3VudHMgb24gY3J1bW15IG5ldHdv
cmtzLgo+IAo+IEZvciBuZXdlciBjbGllbnRzLCB0aGUgZGVmYXVsdCBzaG91bGQgZGVwZW5kIG9u
IHdoYXQgeW91ciBzZXJ2ZXIKPiBzcGVjaWZpZXMgaW4gdGhlIEZTSU5GTyBuZnMgY29tbWFuZC4g
Rm9yIG1vc3Qgc2VydmVycywgd2hlbiB5b3UgbW91bnQKPiB3aXRoIGEgVENQIGNvbm5lY3Rpb24s
IHRoZSBkZWZhdWx0IHdpbGwgYmUgMzJrLCBidXQgc29tZSBtYXkgaGF2ZSBsYXJnZXIKPiBkZWZh
dWx0cyAoTmV0QXBwIHNlcnZlcnMgb2Z0ZW4gc3BlY2lmeSBhIDY0ayBkZWZhdWx0KSBvciBzbWFs
bGVyIChvbGRlcgo+IExpbnV4IHNlcnZlcnMgd2lsbCBzdXBwb3J0IGFuIDhrIG1heGltdW0pLgoK
SSBzZWUgb24gbXkgc2VydmVycyAoPjIuNi4yMSwgbGF0ZXN0IG5mcy11dGlscykgdGhhdCB0aGUg
cnNpemUvd3NpemUgaXMgCmFjdHVhbGx5IGRlZmluZWQgYnkgdGhlIGFtb3VudCBvZiBtZW1vcnkg
b24gdGhlIE5GUyBzZXJ2ZXIuIEl0IHNlZW1zIHRvIApzZXQgdGhlIHJzaXplL3dzaXplIHRvICh0
b3RhbCBtZW1vcnkpLzgxOTIgKDUxMmsgaW4gbXkgY2FzZSBmb3IgYSA0R0IgCm5mcyBzZXJ2ZXIp
LiBJcyBpdCBhIGJ1ZyBvciBhIHdhbnRlZCBiZWhhdmlvciA/CgpHYWJyaWVsCgotLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tClRoaXMgU0YubmV0IGVtYWlsIGlzIHNwb25zb3JlZCBieTogTWljcm9zb2Z0CkRlZnkg
YWxsIGNoYWxsZW5nZXMuIE1pY3Jvc29mdChSKSBWaXN1YWwgU3R1ZGlvIDIwMDUuCmh0dHA6Ly9j
bGsuYXRkbXQuY29tL01SVC9nby92c2UwMTIwMDAwMDcwbXJ0L2RpcmVjdC8wMS8KX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTkZTIG1haWxsaXN0ICAtICBO
RlNAbGlzdHMuc291cmNlZm9yZ2UubmV0Cmh0dHBzOi8vbGlzdHMuc291cmNlZm9yZ2UubmV0L2xp
c3RzL2xpc3RpbmZvL25mcwo=
