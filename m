From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Sat, 01 May 2004 20:22:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083457337.3687.60.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>
	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hHtlYziCOl/4KUmYUHZO"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BK4kP-0004bn-NJ
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 17:22:21 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BK4kP-0005eN-4u
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 17:22:21 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4094397C.3030303@RedHat.com>
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


--=-hHtlYziCOl/4KUmYUHZO
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2004-05-01 at 19:57, Steve Dickson wrote:

> Believe me... I hear you.... and do understand what I'm trying to do....
> And I also apologize for being so persistent.... but just bothers the
> hell out of me that other clients can recover from ESTALEs and we don't...

So please tell me why the following patch (which addresses the
particular problem that you raised of someone resetting mtime on the
parent directory) does not suffice?

Cheers,
  Trond

--=-hHtlYziCOl/4KUmYUHZO
Content-Description: 
Content-Disposition: inline; filename=gnurr.dif
Content-Type: text/x-patch; charset=iso-8859-1
Content-Transfer-Encoding: base64

ZGlmZiAtdSAtLXJlY3Vyc2l2ZSAtLW5ldy1maWxlIC0tc2hvdy1jLWZ1bmN0aW9uIGxpbnV4LTIu
NC4yNi9mcy9uZnMvZGlyLmMgZ251cnIvZnMvbmZzL2Rpci5jDQotLS0gbGludXgtMi40LjI2L2Zz
L25mcy9kaXIuYwkyMDA0LTA0LTE0IDE0OjI4OjIzLjAwMDAwMDAwMCAtMDQwMA0KKysrIGdudXJy
L2ZzL25mcy9kaXIuYwkyMDA0LTA1LTAxIDIwOjE0OjE1LjAwMDAwMDAwMCAtMDQwMA0KQEAgLTQy
MSw3ICs0MjEsNyBAQCBpbnQgbmZzX2NoZWNrX3ZlcmlmaWVyKHN0cnVjdCBpbm9kZSAqZGlyDQog
CQlyZXR1cm4gMTsNCiAJaWYgKG5mc19yZXZhbGlkYXRlX2lub2RlKE5GU19TRVJWRVIoZGlyKSwg
ZGlyKSkNCiAJCXJldHVybiAwOw0KLQlyZXR1cm4gdGltZV9hZnRlcihkZW50cnktPmRfdGltZSwg
TkZTX01USU1FX1VQREFURShkaXIpKTsNCisJcmV0dXJuIHRpbWVfYWZ0ZXIoZGVudHJ5LT5kX3Rp
bWUsIE5GU19DVElNRV9VUERBVEUoZGlyKSk7DQogfQ0KIA0KIC8qDQpkaWZmIC11IC0tcmVjdXJz
aXZlIC0tbmV3LWZpbGUgLS1zaG93LWMtZnVuY3Rpb24gbGludXgtMi40LjI2L2ZzL25mcy9pbm9k
ZS5jIGdudXJyL2ZzL25mcy9pbm9kZS5jDQotLS0gbGludXgtMi40LjI2L2ZzL25mcy9pbm9kZS5j
CTIwMDQtMDQtMTQgMTQ6Mjg6MzYuMDAwMDAwMDAwIC0wNDAwDQorKysgZ251cnIvZnMvbmZzL2lu
b2RlLmMJMjAwNC0wNS0wMSAyMDoxMzo1NS4wMDAwMDAwMDAgLTA0MDANCkBAIC0xMDU0LDE2ICsx
MDU0LDE2IEBAIF9fbmZzX3JlZnJlc2hfaW5vZGUoc3RydWN0IGlub2RlICppbm9kZSwNCiAJaWYg
KG5mc19oYXZlX3dyaXRlYmFja3MoaW5vZGUpICYmIG5ld19pc2l6ZSA8IGlub2RlLT5pX3NpemUp
DQogCQluZXdfaXNpemUgPSBpbm9kZS0+aV9zaXplOw0KIA0KLQlORlNfQ0FDSEVfQ1RJTUUoaW5v
ZGUpID0gZmF0dHItPmN0aW1lOw0KLQlpbm9kZS0+aV9jdGltZSA9IG5mc190aW1lX3RvX3NlY3Mo
ZmF0dHItPmN0aW1lKTsNCisJaWYgKE5GU19DQUNIRV9DVElNRShpbm9kZSkgIT0gZmF0dHItPmN0
aW1lKSB7DQorCQlORlNfQ0FDSEVfQ1RJTUUoaW5vZGUpID0gZmF0dHItPmN0aW1lOw0KKwkJaW5v
ZGUtPmlfY3RpbWUgPSBuZnNfdGltZV90b19zZWNzKGZhdHRyLT5jdGltZSk7DQorCQlORlNfQ1RJ
TUVfVVBEQVRFKGlub2RlKSA9IGppZmZpZXM7DQorCX0NCiANCiAJaW5vZGUtPmlfYXRpbWUgPSBu
ZXdfYXRpbWU7DQogDQotCWlmIChORlNfQ0FDSEVfTVRJTUUoaW5vZGUpICE9IG5ld19tdGltZSkg
ew0KLQkJTkZTX01USU1FX1VQREFURShpbm9kZSkgPSBqaWZmaWVzOw0KLQkJTkZTX0NBQ0hFX01U
SU1FKGlub2RlKSA9IG5ld19tdGltZTsNCi0JCWlub2RlLT5pX210aW1lID0gbmZzX3RpbWVfdG9f
c2VjcyhuZXdfbXRpbWUpOw0KLQl9DQorCU5GU19DQUNIRV9NVElNRShpbm9kZSkgPSBuZXdfbXRp
bWU7DQorCWlub2RlLT5pX210aW1lID0gbmZzX3RpbWVfdG9fc2VjcyhuZXdfbXRpbWUpOw0KIA0K
IAlORlNfQ0FDSEVfSVNJWkUoaW5vZGUpID0gbmV3X3NpemU7DQogCWlub2RlLT5pX3NpemUgPSBu
ZXdfaXNpemU7DQpkaWZmIC11IC0tcmVjdXJzaXZlIC0tbmV3LWZpbGUgLS1zaG93LWMtZnVuY3Rp
b24gbGludXgtMi40LjI2L2luY2x1ZGUvbGludXgvbmZzX2ZzLmggZ251cnIvaW5jbHVkZS9saW51
eC9uZnNfZnMuaA0KLS0tIGxpbnV4LTIuNC4yNi9pbmNsdWRlL2xpbnV4L25mc19mcy5oCTIwMDQt
MDQtMTQgMTQ6Mjg6MTguMDAwMDAwMDAwIC0wNDAwDQorKysgZ251cnIvaW5jbHVkZS9saW51eC9u
ZnNfZnMuaAkyMDA0LTA1LTAxIDIwOjE1OjA1LjAwMDAwMDAwMCAtMDQwMA0KQEAgLTc4LDcgKzc4
LDcgQEAgc3RhdGljIGlubGluZSBzdHJ1Y3QgbmZzX2lub2RlX2luZm8gKk5GUw0KICNkZWZpbmUg
TkZTX0NPTkdFU1RFRChpbm9kZSkJCShSUENfQ09OR0VTVEVEKE5GU19DTElFTlQoaW5vZGUpKSkN
CiAjZGVmaW5lIE5GU19DT09LSUVWRVJGKGlub2RlKQkJKChpbm9kZSktPnUubmZzX2kuY29va2ll
dmVyZikNCiAjZGVmaW5lIE5GU19SRUFEVElNRShpbm9kZSkJCSgoaW5vZGUpLT51Lm5mc19pLnJl
YWRfY2FjaGVfamlmZmllcykNCi0jZGVmaW5lIE5GU19NVElNRV9VUERBVEUoaW5vZGUpCQkoKGlu
b2RlKS0+dS5uZnNfaS5jYWNoZV9tdGltZV9qaWZmaWVzKQ0KKyNkZWZpbmUgTkZTX0NUSU1FX1VQ
REFURShpbm9kZSkJCSgoaW5vZGUpLT51Lm5mc19pLmNhY2hlX2N0aW1lX2ppZmZpZXMpDQogI2Rl
ZmluZSBORlNfQ0FDSEVfQ1RJTUUoaW5vZGUpCQkoKGlub2RlKS0+dS5uZnNfaS5yZWFkX2NhY2hl
X2N0aW1lKQ0KICNkZWZpbmUgTkZTX0NBQ0hFX01USU1FKGlub2RlKQkJKChpbm9kZSktPnUubmZz
X2kucmVhZF9jYWNoZV9tdGltZSkNCiAjZGVmaW5lIE5GU19DQUNIRV9JU0laRShpbm9kZSkJCSgo
aW5vZGUpLT51Lm5mc19pLnJlYWRfY2FjaGVfaXNpemUpDQpkaWZmIC11IC0tcmVjdXJzaXZlIC0t
bmV3LWZpbGUgLS1zaG93LWMtZnVuY3Rpb24gbGludXgtMi40LjI2L2luY2x1ZGUvbGludXgvbmZz
X2ZzX2kuaCBnbnVyci9pbmNsdWRlL2xpbnV4L25mc19mc19pLmgNCi0tLSBsaW51eC0yLjQuMjYv
aW5jbHVkZS9saW51eC9uZnNfZnNfaS5oCTIwMDQtMDQtMTQgMTQ6Mjg6MTguMDAwMDAwMDAwIC0w
NDAwDQorKysgZ251cnIvaW5jbHVkZS9saW51eC9uZnNfZnNfaS5oCTIwMDQtMDUtMDEgMjA6MTU6
MzIuMDAwMDAwMDAwIC0wNDAwDQpAQCAtNDksMTAgKzQ5LDEwIEBAIHN0cnVjdCBuZnNfaW5vZGVf
aW5mbyB7DQogCXVuc2lnbmVkIGxvbmcJCWF0dHJ0aW1lb190aW1lc3RhbXA7DQogDQogCS8qDQot
CSAqIFRpbWVzdGFtcCB0aGF0IGRhdGVzIHRoZSBjaGFuZ2UgbWFkZSB0byByZWFkX2NhY2hlX210
aW1lLg0KKwkgKiBUaW1lc3RhbXAgdGhhdCBkYXRlcyB0aGUgY2hhbmdlIG1hZGUgdG8gcmVhZF9j
YWNoZV9jdGltZS4NCiAJICogVGhpcyBpcyBvZiB1c2UgZm9yIGRlbnRyeSByZXZhbGlkYXRpb24N
CiAJICovDQotCXVuc2lnbmVkIGxvbmcJCWNhY2hlX210aW1lX2ppZmZpZXM7DQorCXVuc2lnbmVk
IGxvbmcJCWNhY2hlX2N0aW1lX2ppZmZpZXM7DQogDQogCS8qDQogCSAqIFRoaXMgaXMgdGhlIGNv
b2tpZSB2ZXJpZmllciB1c2VkIGZvciBORlN2MyByZWFkZGlyDQo=

--=-hHtlYziCOl/4KUmYUHZO--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
