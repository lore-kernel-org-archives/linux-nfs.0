From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFSv3 blocking locks broken in 2.6.7
Date: Wed, 18 Aug 2004 13:02:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092848539.4931.56.camel@lade.trondhjem.org>
References: <OF35B34F68.0EE4F93D-ON88256EF4.00138C8D-88256EF4.0013F948@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-Oi2mU/bPO+CJqNdda83P"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF35B34F68.0EE4F93D-ON88256EF4.00138C8D-88256EF4.0013F948@us.ibm.com>
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


--=-Oi2mU/bPO+CJqNdda83P
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

P=E5 ty , 17/08/2004 klokka 23:38, skreiv Marc Eshel:
>=20
>=20
> I just tried the latest 2.6.8 kernel and the following problem is still
> there.
>=20

Hmm... I suspect that what is happening is that the GRANTED callback
gets screwed up due to an assumption that is made in the svcauth_unix
code that everything needs to be authenticated by the "mountd" daemon.
That certainly never applies to any of the client callbacks (which have
to be authenticated by comparing to the list of outstanding lock RPC
calls), nor does it apply to the notify() callback.

Can you therefore try the following on the clients ONLY (keep the server
as it stands). If that fixes the client issue, then we'll look at a more
permanent fix that addresses both client and server concerns by moving
the mountd upcall into the nfsd code where it belongs.

Cheers,
  Trond

--=-Oi2mU/bPO+CJqNdda83P
Content-Description: 
Content-Disposition: inline; filename=gnurr.dif
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi44LjEtdXAvbmV0L3N1bnJwYy9zdmNhdXRoX3VuaXguYy5vcmlnCTIwMDQt
MDgtMTQgMTQ6MjY6NTUuMDAwMDAwMDAwIC0wNDAwDQorKysgbGludXgtMi42LjguMS11cC9uZXQv
c3VucnBjL3N2Y2F1dGhfdW5peC5jCTIwMDQtMDgtMTggMTI6MzM6NDcuMDAwMDAwMDAwIC0wNDAw
DQpAQCAtMzY4LDYgKzM2OCw3IEBAIHN2Y2F1dGhfbnVsbF9hY2NlcHQoc3RydWN0IHN2Y19ycXN0
ICpycXMNCiAJc3ZjX3B1dHUzMihyZXN2LCBSUENfQVVUSF9OVUxMKTsNCiAJc3ZjX3B1dHUzMihy
ZXN2LCAwKTsNCiANCisjaWYgMA0KIAlrZXkubV9jbGFzcyA9IHJxc3RwLT5ycV9zZXJ2ZXItPnN2
X3Byb2dyYW0tPnBnX2NsYXNzOw0KIAlrZXkubV9hZGRyID0gcnFzdHAtPnJxX2FkZHIuc2luX2Fk
ZHI7DQogDQpAQCAtMzk1LDYgKzM5NiwxMCBAQCBzdmNhdXRoX251bGxfYWNjZXB0KHN0cnVjdCBz
dmNfcnFzdCAqcnFzDQogDQogCWlmIChycXN0cC0+cnFfY2xpZW50ID09IE5VTEwgJiYgcnFzdHAt
PnJxX3Byb2MgIT0gMCkNCiAJCSphdXRocCA9IHJwY19hdXRoZXJyX2JhZGNyZWQ7DQorI2Vsc2UN
CisJcnFzdHAtPnJxX2NsaWVudCA9IE5VTEw7DQorCXJ2ID0gU1ZDX09LOw0KKyNlbmRpZg0KIA0K
IAlyZXR1cm4gcnY7DQogfQ0KQEAgLTQ2MSw2ICs0NjYsNyBAQCBzdmNhdXRoX3VuaXhfYWNjZXB0
KHN0cnVjdCBzdmNfcnFzdCAqcnFzDQogCX0NCiANCiANCisjaWYgMA0KIAlrZXkubV9jbGFzcyA9
IHJxc3RwLT5ycV9zZXJ2ZXItPnN2X3Byb2dyYW0tPnBnX2NsYXNzOw0KIAlrZXkubV9hZGRyID0g
cnFzdHAtPnJxX2FkZHIuc2luX2FkZHI7DQogDQpAQCAtNDg3LDYgKzQ5Myw5IEBAIHN2Y2F1dGhf
dW5peF9hY2NlcHQoc3RydWN0IHN2Y19ycXN0ICpycXMNCiANCiAJaWYgKHJ2ICA9PSBTVkNfT0sg
JiYgcnFzdHAtPnJxX2NsaWVudCA9PSBOVUxMICYmIHJxc3RwLT5ycV9wcm9jICE9IDApDQogCQln
b3RvIGJhZGNyZWQ7DQorI2Vsc2UNCisJcnYgPSBTVkNfT0s7DQorI2VuZGlmDQogDQogCS8qIFB1
dCBOVUxMIHZlcmlmaWVyICovDQogCXN2Y19wdXR1MzIocmVzdiwgUlBDX0FVVEhfTlVMTCk7DQo=

--=-Oi2mU/bPO+CJqNdda83P--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
