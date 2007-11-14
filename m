From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: [PATCH] 2.6.24-rc2-mm1 - Build fails - in nsfd/vfs.c
Date: Wed, 14 Nov 2007 10:19:04 +0530
Message-ID: <20071114044904.GA12453@linux.vnet.ibm.com>
Reply-To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	apw@shadowen.org
To: akpm@linux-foundation.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsABz-0002Xe-Vf
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 20:49:36 -0800
Received: from e23smtp06.au.ibm.com ([202.81.18.175])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsAC4-0002P2-E2
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 20:49:41 -0800
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id lAE4nSn9015958
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 15:49:28 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id
	lAE4nUh72392144
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 15:49:30 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	lAE3mZnf025111
	for <nfs@lists.sourceforge.net>; Wed, 14 Nov 2007 14:48:36 +1100
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

SGkgQW5kcmV3LAoKVGhlIEtlcm5lbCBidWlsZCBmYWlscywgd2l0aCBlcnJvcgoKICBDQyAgICAg
IGZzL25mc2QvdmZzLm8KZnMvbmZzZC92ZnMuYzogSW4gZnVuY3Rpb24g4oCYbmZzZF9yZW5hbWXi
gJk6CmZzL25mc2QvdmZzLmM6MTY5NTogZXJyb3I6IHJlcXVlc3QgZm9yIG1lbWJlciDigJhtbnTi
gJkgaW4gc29tZXRoaW5nIG5vdCBhIHN0cnVjdHVyZSBvciB1bmlvbgptYWtlWzJdOiAqKiogW2Zz
L25mc2QvdmZzLm9dIEVycm9yIDEKbWFrZVsxXTogKioqIFtmcy9uZnNkXSBFcnJvciAyCm1ha2U6
ICoqKiBbZnNdIEVycm9yIDIKClNpZ25lZC1vZmYtYnk6IEthbWFsZXNoIEJhYnVsYWwgPGthbWFs
ZXNoQGxpbnV4LnZuZXQuaWJtLmNvbT4KLS0KLS0tIGxpbnV4LTIuNi4yNC1yYzIvZnMvbmZzZC92
ZnMuYwkyMDA3LTExLTEzIDIyOjE2OjE4LjAwMDAwMDAwMCAtMDUwMAorKysgbGludXgtMi42LjI0
LXJjMi9mcy9uZnNkL352ZnMuYwkyMDA3LTExLTEzIDIzOjEwOjE4LjAwMDAwMDAwMCAtMDUwMApA
QCAtMTY5Miw3ICsxNjkyLDcgQEAgbmZzZF9yZW5hbWUoc3RydWN0IHN2Y19ycXN0ICpycXN0cCwg
c3RydQogCQlpZiAoIWhvc3RfZXJyKQogCQkJaG9zdF9lcnIgPSBuZnNkX3N5bmNfZGlyKGZkZW50
cnkpOwogCX0KLQltbnRfZHJvcF93cml0ZShmZmhwLT5maF9leHBvcnQtPmV4X3BhdGgubW50KTsK
KwltbnRfZHJvcF93cml0ZShmZmhwLT5maF9leHBvcnQtPmV4X21udCk7CiAKICBvdXRfZHB1dF9u
ZXc6CiAJZHB1dChuZGVudHJ5KTsKCi0tIApUaGFua3MgJiBSZWdhcmRzLApLYW1hbGVzaCBCYWJ1
bGFsLApMaW51eCBUZWNobm9sb2d5IENlbnRlciwKSUJNLCBJU1RMLgoKLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LQpUaGlzIFNGLm5ldCBlbWFpbCBpcyBzcG9uc29yZWQgYnk6IFNwbHVuayBJbmMuClN0aWxsIGdy
ZXBwaW5nIHRocm91Z2ggbG9nIGZpbGVzIHRvIGZpbmQgcHJvYmxlbXM/ICBTdG9wLgpOb3cgU2Vh
cmNoIGxvZyBldmVudHMgYW5kIGNvbmZpZ3VyYXRpb24gZmlsZXMgdXNpbmcgQUpBWCBhbmQgYSBi
cm93c2VyLgpEb3dubG9hZCB5b3VyIEZSRUUgY29weSBvZiBTcGx1bmsgbm93ID4+IGh0dHA6Ly9n
ZXQuc3BsdW5rLmNvbS8KX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KTkZTIG1haWxsaXN0ICAtICBORlNAbGlzdHMuc291cmNlZm9yZ2UubmV0Cmh0dHBzOi8v
bGlzdHMuc291cmNlZm9yZ2UubmV0L2xpc3RzL2xpc3RpbmZvL25mcwo=
