From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFSv3 blocking locks broken in 2.6.7
Date: Tue, 24 Aug 2004 21:31:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1093397495.7439.7.camel@lade.trondhjem.org>
References: <OFAF6A9C4E.27A9BF20-ON88256EFB.00020035-88256EFB.0002DABA@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-3TC325BMIEX/6mDqrflH"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OFAF6A9C4E.27A9BF20-ON88256EFB.00020035-88256EFB.0002DABA@us.ibm.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-3TC325BMIEX/6mDqrflH
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

P=E5 ty , 24/08/2004 klokka 20:31, skreiv Marc Eshel:
>=20
>=20
> Hi Trond,
>=20
> I have a question about the serialization of the nlm_blocked list. Is it
> possible that the lockd thread will manipulate the list while a call is
> made to nlmsvc_notify_blocked() on a different thread which is also
> searching the nlm_blocked list?

The BKL should normally protect against that.

There was a problem that originate in 2.5.x due to someone having done a
"cleanup" of the locking code without really understanding how
nlmsvc_delete_block() works.
The attached patch (which was merge into the mainline kernel in
2.6.9-rc1) fixes that problem. Could you check if it fixes the issues
you are seeing?

Cheers,
  Trond

--=-3TC325BMIEX/6mDqrflH
Content-Disposition: inline; filename=linux-2.6.8.1-10-lockd_bug.dif
Content-Type: text/plain; name=linux-2.6.8.1-10-lockd_bug.dif; charset=iso-8859-1
Content-Transfer-Encoding: base64

IHN2Y2xvY2suYyB8ICAgIDkgKysrKysrKy0tDQogMSBmaWxlcyBjaGFuZ2VkLCA3IGluc2VydGlv
bnMoKyksIDIgZGVsZXRpb25zKC0pDQoNCi0tLSBsaW51eC0yLjYuOC4xLWdycnIvZnMvbG9ja2Qv
c3ZjbG9jay5jLm9yaWcJMjAwNC0wOC0xNCAxNDoyNTo1Ni4wMDAwMDAwMDAgLTA0MDANCisrKyBs
aW51eC0yLjYuOC4xLWdycnIvZnMvbG9ja2Qvc3ZjbG9jay5jCTIwMDQtMDgtMTggMTk6MzQ6MTMu
MDAwMDAwMDAwIC0wNDAwDQpAQCAtMjM4LDggKzIzOCwxMyBAQCBubG1zdmNfZGVsZXRlX2Jsb2Nr
KHN0cnVjdCBubG1fYmxvY2sgKmJsDQogDQogCS8qIFJlbW92ZSBibG9jayBmcm9tIGxpc3QgKi8N
CiAJbmxtc3ZjX3JlbW92ZV9ibG9jayhibG9jayk7DQotCXBvc2l4X3VuYmxvY2tfbG9jaygmZmls
ZS0+Zl9maWxlLCBmbCk7DQotCWJsb2NrLT5iX2dyYW50ZWQgPSAwOw0KKwlpZiAoZmwtPmZsX25l
eHQpDQorCQlwb3NpeF91bmJsb2NrX2xvY2soJmZpbGUtPmZfZmlsZSwgZmwpOw0KKwlpZiAodW5s
b2NrKSB7DQorCQlmbC0+ZmxfdHlwZSA9IEZfVU5MQ0s7DQorCQlwb3NpeF9sb2NrX2ZpbGUoJmZp
bGUtPmZfZmlsZSwgZmwpOw0KKwkJYmxvY2stPmJfZ3JhbnRlZCA9IDA7DQorCX0NCiANCiAJLyog
SWYgdGhlIGJsb2NrIGlzIGluIHRoZSBtaWRkbGUgb2YgYSBHUkFOVCBjYWxsYmFjaywNCiAJICog
ZG9uJ3Qga2lsbCBpdCB5ZXQuICovDQo=

--=-3TC325BMIEX/6mDqrflH--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
