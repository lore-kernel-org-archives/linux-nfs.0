From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFSv3 blocking locks broken in 2.6.7
Date: Wed, 18 Aug 2004 19:39:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1092872360.9329.106.camel@lade.trondhjem.org>
References: <OF1E311F0C.DE07BF39-ON88256EF4.0074E199-88256EF4.0076294E@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-/TnCj1rXcniSGbUvZYl7"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <OF1E311F0C.DE07BF39-ON88256EF4.0074E199-88256EF4.0076294E@us.ibm.com>
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


--=-/TnCj1rXcniSGbUvZYl7
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

P=E5 on , 18/08/2004 klokka 17:30, skreiv Marc Eshel:
>=20
>=20
> Hi Trond,
>=20
> I tried the changed that you recommended on the NFS client but it did not
> help. Following is an NLM trace on the NFS server that shows the problem.
> Tracing the code points to a problem that is marked below with '*****'
>=20

Well debugged!

Grr... These "design cleanups" are costing a lot of extra work to fix up
the bugs.

So the following patch fixes it for you then?

Cheers,
  Trond

--=-/TnCj1rXcniSGbUvZYl7
Content-Description: 
Content-Disposition: inline; filename=gnurr.dif
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: base64

LS0tIGxpbnV4LTIuNi44LjEtZ3Jyci9mcy9sb2NrZC9zdmNsb2NrLmMub3JpZwkyMDA0LTA4LTE0
IDE0OjI1OjU2LjAwMDAwMDAwMCAtMDQwMA0KKysrIGxpbnV4LTIuNi44LjEtZ3Jyci9mcy9sb2Nr
ZC9zdmNsb2NrLmMJMjAwNC0wOC0xOCAxOTozNDoxMy4wMDAwMDAwMDAgLTA0MDANCkBAIC0yMzgs
OCArMjM4LDEzIEBAIG5sbXN2Y19kZWxldGVfYmxvY2soc3RydWN0IG5sbV9ibG9jayAqYmwNCiAN
CiAJLyogUmVtb3ZlIGJsb2NrIGZyb20gbGlzdCAqLw0KIAlubG1zdmNfcmVtb3ZlX2Jsb2NrKGJs
b2NrKTsNCi0JcG9zaXhfdW5ibG9ja19sb2NrKCZmaWxlLT5mX2ZpbGUsIGZsKTsNCi0JYmxvY2st
PmJfZ3JhbnRlZCA9IDA7DQorCWlmIChmbC0+ZmxfbmV4dCkNCisJCXBvc2l4X3VuYmxvY2tfbG9j
aygmZmlsZS0+Zl9maWxlLCBmbCk7DQorCWlmICh1bmxvY2spIHsNCisJCWZsLT5mbF90eXBlID0g
Rl9VTkxDSzsNCisJCXBvc2l4X2xvY2tfZmlsZSgmZmlsZS0+Zl9maWxlLCBmbCk7DQorCQlibG9j
ay0+Yl9ncmFudGVkID0gMDsNCisJfQ0KIA0KIAkvKiBJZiB0aGUgYmxvY2sgaXMgaW4gdGhlIG1p
ZGRsZSBvZiBhIEdSQU5UIGNhbGxiYWNrLA0KIAkgKiBkb24ndCBraWxsIGl0IHlldC4gKi8NCg==

--=-/TnCj1rXcniSGbUvZYl7--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
