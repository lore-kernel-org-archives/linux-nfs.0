From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Sat, 01 May 2004 23:28:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083468517.3687.70.camel@lade.trondhjem.org>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>
	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>
	 <1083457337.3687.60.camel@lade.trondhjem.org> <409468B2.40200@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-s8B3evrtYk5iUGtdfERU"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BK7eh-0003zZ-Lg
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 20:28:39 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BK7eh-0008K7-C3
	for nfs@lists.sourceforge.net; Sat, 01 May 2004 20:28:39 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <409468B2.40200@RedHat.com>
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


--=-s8B3evrtYk5iUGtdfERU
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2004-05-01 at 23:19, Steve Dickson wrote:
> Again this is were I started... and this patch does take care of the ESTALEs
> but it also increases normal traffic by 2% to 3% (mostly getattrs and 
> lookups)

So this is what I don't understand.

Which are the operations that are supposed to "ctime" without changing
"mtime"? AFAICS the *only* such operation is utime(), which was the one
that was causing you trouble in the first place.

I certainly would not expect any difference between the two when looking
at the standard connectathon suite.

Unless....

Is your kernel perhaps missing the appended patch, which is already in
2.4.26?

Cheers,
  Trond



--=-s8B3evrtYk5iUGtdfERU
Content-Description: 
Content-Disposition: inline; filename=gnarf.dif
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=iso-8859-1

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBkaWZmIC1OcnUgc3R5bGUgcGF0Y2guDQoj
DQojIENoYW5nZVNldA0KIyAgIDIwMDQvMDIvMDkgMTE6MDk6MjItMDY6MDAgc2hhZ2d5QGtsZWlr
YW1wLmR5bi53ZWJhaGVhZC5pYm0uY29tIA0KIyAgIEpGUzogcmVuYW1lIHNob3VsZCB1cGRhdGUg
bXRpbWUgb24gc291cmNlIGFuZCB0YXJnZXQgZGlyZWN0b3JpZXMNCiMgDQojIGZzL2pmcy9uYW1l
aS5jDQojICAgMjAwNC8wMi8wOSAxMTowNzoyNC0wNjowMCBzaGFnZ3lAa2xlaWthbXAuZHluLndl
YmFoZWFkLmlibS5jb20gKzIgLTINCiMgICByZW5hbWUgc2hvdWxkIHVwZGF0ZSBpX210aW1lIG9u
IGFmZmVjdGVkIGRpcmVjdG9yaWVzDQojIA0KZGlmZiAtTnJ1IGEvZnMvamZzL25hbWVpLmMgYi9m
cy9qZnMvbmFtZWkuYw0KLS0tIGEvZnMvamZzL25hbWVpLmMJU2F0IE1heSAgMSAyMzoyODoxMyAy
MDA0DQorKysgYi9mcy9qZnMvbmFtZWkuYwlTYXQgTWF5ICAxIDIzOjI4OjEzIDIwMDQNCkBAIC0x
MjIzLDcgKzEyMjMsNyBAQA0KIAlvbGRfaXAtPmlfY3RpbWUgPSBDVVJSRU5UX1RJTUU7DQogCW1h
cmtfaW5vZGVfZGlydHkob2xkX2lwKTsNCiANCi0JbmV3X2Rpci0+aV9jdGltZSA9IENVUlJFTlRf
VElNRTsNCisJbmV3X2Rpci0+aV9jdGltZSA9IG5ld19kaXItPmlfbXRpbWUgPSBDVVJSRU5UX1RJ
TUU7DQogCW1hcmtfaW5vZGVfZGlydHkobmV3X2Rpcik7DQogDQogCS8qIEJ1aWxkIGxpc3Qgb2Yg
aW5vZGVzIG1vZGlmaWVkIGJ5IHRoaXMgdHJhbnNhY3Rpb24gKi8NCkBAIC0xMjM1LDcgKzEyMzUs
NyBAQA0KIA0KIAlpZiAob2xkX2RpciAhPSBuZXdfZGlyKSB7DQogCQlpcGxpc3RbaXBjb3VudCsr
XSA9IG5ld19kaXI7DQotCQlvbGRfZGlyLT5pX2N0aW1lID0gQ1VSUkVOVF9USU1FOw0KKwkJb2xk
X2Rpci0+aV9jdGltZSA9IG9sZF9kaXItPmlfbXRpbWUgPSBDVVJSRU5UX1RJTUU7DQogCQltYXJr
X2lub2RlX2RpcnR5KG9sZF9kaXIpOw0KIAl9DQogDQo=

--=-s8B3evrtYk5iUGtdfERU--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
