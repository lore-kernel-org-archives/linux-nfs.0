From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: simple question about r/wsize
Date: Mon, 01 Oct 2007 19:11:01 -0400
Message-ID: <1191280261.6611.19.camel@heimdal.trondhjem.org>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447540@exchrdm.ad.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net
To: Wim Colgate <Wim.Colgate@xensource.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcUPy-0003VW-S6
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 16:11:15 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcUQ3-0007ln-K4
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 16:11:20 -0700
In-Reply-To: <A9AD3C3BCF83FD4182B7D4D99E37FAD8447540@exchrdm.ad.xensource.com>
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

T24gTW9uLCAyMDA3LTEwLTAxIGF0IDE1OjA0IC0wNzAwLCBXaW0gQ29sZ2F0ZSB3cm90ZToKPiBX
aGF04oCZcyB0aGUgY3VycmVudCBORlMgdjMgd3NpemUgYW5kIHJzaXplPyBJdCBhcHBlYXJzIHRv
IGJlIDRLIOKAkyBhbmQKPiBqdXN0IHdhbnRlZCBhIGNvbmZpcm1hdGlvbi4KPiAKCkl0IHNvdW5k
cyBsaWtlIHlvdSBhcmUgd29ya2luZyB3aXRoIGFuIG9sZCBzeXN0ZW0uIElJUkMsIG9sZGVyIHZl
cnNpb25zCm9mIFJlZEhhdCB1c2VkIHRvIGppbW15IHRoZSAnbW91bnQnIGNvbW1hbmQgdG8gbWFr
ZSA0ayB0aGUgZGVmYXVsdCwKYmVjYXVzZSB0aGF0IHdvcmtlZCBiZXN0IHdpdGggVURQIG1vdW50
cyBvbiBjcnVtbXkgbmV0d29ya3MuCgpGb3IgbmV3ZXIgY2xpZW50cywgdGhlIGRlZmF1bHQgc2hv
dWxkIGRlcGVuZCBvbiB3aGF0IHlvdXIgc2VydmVyCnNwZWNpZmllcyBpbiB0aGUgRlNJTkZPIG5m
cyBjb21tYW5kLiBGb3IgbW9zdCBzZXJ2ZXJzLCB3aGVuIHlvdSBtb3VudAp3aXRoIGEgVENQIGNv
bm5lY3Rpb24sIHRoZSBkZWZhdWx0IHdpbGwgYmUgMzJrLCBidXQgc29tZSBtYXkgaGF2ZSBsYXJn
ZXIKZGVmYXVsdHMgKE5ldEFwcCBzZXJ2ZXJzIG9mdGVuIHNwZWNpZnkgYSA2NGsgZGVmYXVsdCkg
b3Igc21hbGxlciAob2xkZXIKTGludXggc2VydmVycyB3aWxsIHN1cHBvcnQgYW4gOGsgbWF4aW11
bSkuCgonY2F0IC9wcm9jL21vdW50cycgc2hvdWxkIGFsd2F5cyB0ZWxsIHlvdSB3aGF0IHRoZSBj
bGllbnQgaXMgYWN0dWFsbHkKdXNpbmcgZm9yIHJzaXplL3dzaXplLgoKQ2hlZXJzCiAgVHJvbmQK
CgotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tClRoaXMgU0YubmV0IGVtYWlsIGlzIHNwb25zb3JlZCBieTogTWlj
cm9zb2Z0CkRlZnkgYWxsIGNoYWxsZW5nZXMuIE1pY3Jvc29mdChSKSBWaXN1YWwgU3R1ZGlvIDIw
MDUuCmh0dHA6Ly9jbGsuYXRkbXQuY29tL01SVC9nby92c2UwMTIwMDAwMDcwbXJ0L2RpcmVjdC8w
MS8KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX18KTkZTIG1h
aWxsaXN0ICAtICBORlNAbGlzdHMuc291cmNlZm9yZ2UubmV0Cmh0dHBzOi8vbGlzdHMuc291cmNl
Zm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL25mcwo=
