From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS PATCH ] Check for link count change when refreshing inode
Date: Tue, 09 Mar 2004 09:54:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078844047.1938.7.camel@nidelv.trondhjem.org>
References: <20040309022802.86797.qmail@web12825.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-54S+PrFCuHkcHDrmobxN"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0ilV-00050e-1R
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 07:03:29 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B0ice-00024T-TC
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:54:21 -0800
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20040309022802.86797.qmail@web12825.mail.yahoo.com>
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


--=-54S+PrFCuHkcHDrmobxN
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

P=E5 m=E5 , 08/03/2004 klokka 21:28, skreiv Shantanu Goel:
> Hi,
>=20
> The attached patch adds a check for change in link
> count when refreshing an inode.  Otherwise, the
> following sequence of calls produces an incorrect link
> count.  Such a sequence is used by "gnucash" to lock
> its data files.
>=20
> 1. create file "foo" and don't close the descriptor.
> 2. link("foo", "bar")
> 3. stat("foo") to retrieve the link count.  The stock
> NFS client returns 1 instead of 2.
>=20
> The patch is on top of linux-2.6.4-NFS4_ALL.dif.

Hmm... The problem is that nfs_refresh_inode() is only called iff the
RPC call returns post_op attributes, whereas you are pointing to a more
general problem: that of seeing our own updates as soon as they happen.

Post-op attributes should really only be used for catching updates to
the inode that we didn't cause ourselves.

How about the following change instead? It includes your change for
catching updates that have been made by third parties, but also ensures
that we always see our own updates immediately...

Cheers,
  Trond



--=-54S+PrFCuHkcHDrmobxN
Content-Description: 
Content-Disposition: attachment; filename=gnurr.dif
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=iso-8859-1

IGlub2RlLmMgfCAgIDE5ICsrKysrKysrKysrLS0tLS0tLS0NCiB3cml0ZS5jIHwgICAgNCAtLS0t
DQogMiBmaWxlcyBjaGFuZ2VkLCAxMSBpbnNlcnRpb25zKCspLCAxMiBkZWxldGlvbnMoLSkNCg0K
ZGlmZiAtdSAtLXJlY3Vyc2l2ZSAtLW5ldy1maWxlIC0tc2hvdy1jLWZ1bmN0aW9uIGxpbnV4LTIu
Ni40LTAxLWF0dHIub2xkL2ZzL25mcy9pbm9kZS5jIGxpbnV4LTIuNi40LTAxLWF0dHIvZnMvbmZz
L2lub2RlLmMNCi0tLSBsaW51eC0yLjYuNC0wMS1hdHRyLm9sZC9mcy9uZnMvaW5vZGUuYwkyMDA0
LTAzLTA5IDA5OjE3OjE2LjAwMDAwMDAwMCAtMDUwMA0KKysrIGxpbnV4LTIuNi40LTAxLWF0dHIv
ZnMvbmZzL2lub2RlLmMJMjAwNC0wMy0wOSAwOTo0OTozNC4wMDAwMDAwMDAgLTA1MDANCkBAIC0x
MDUzLDE0ICsxMDUzLDEzIEBAIHZvaWQgbmZzX2VuZF9kYXRhX3VwZGF0ZShzdHJ1Y3QgaW5vZGUg
KmkNCiB7DQogCXN0cnVjdCBuZnNfaW5vZGUgKm5mc2kgPSBORlNfSShpbm9kZSk7DQogDQotCWlm
IChhdG9taWNfZGVjX2FuZF90ZXN0KCZuZnNpLT5kYXRhX3VwZGF0ZXMpKSB7DQotCQluZnNpLT5j
YWNoZV9jaGFuZ2VfYXR0cmlidXRlICsrOw0KLQkJLyogTWFyayB0aGUgYXR0cmlidXRlIGNhY2hl
IGZvciByZXZhbGlkYXRpb24gKi8NCi0JCW5mc2ktPmZsYWdzIHw9IE5GU19JTk9fSU5WQUxJRF9B
VFRSOw0KLQkJLyogRGlyZWN0b3JpZXMgYW5kIHN5bWxpbmtzOiBpbnZhbGlkYXRlIHBhZ2UgY2Fj
aGUgdG9vICovDQotCQlpZiAoU19JU0RJUihpbm9kZS0+aV9tb2RlKSB8fCBTX0lTTE5LKGlub2Rl
LT5pX21vZGUpKQ0KLQkJCW5mc2ktPmZsYWdzIHw9IE5GU19JTk9fSU5WQUxJRF9EQVRBOw0KLQl9
DQorCS8qIE1hcmsgdGhlIGF0dHJpYnV0ZSBjYWNoZSBmb3IgcmV2YWxpZGF0aW9uICovDQorCW5m
c2ktPmZsYWdzIHw9IE5GU19JTk9fSU5WQUxJRF9BVFRSOw0KKwkvKiBEaXJlY3RvcmllcyBhbmQg
c3ltbGlua3M6IGludmFsaWRhdGUgcGFnZSBjYWNoZSB0b28gKi8NCisJaWYgKFNfSVNESVIoaW5v
ZGUtPmlfbW9kZSkgfHwgU19JU0xOSyhpbm9kZS0+aV9tb2RlKSkNCisJCW5mc2ktPmZsYWdzIHw9
IE5GU19JTk9fSU5WQUxJRF9EQVRBOw0KKwluZnNpLT5jYWNoZV9jaGFuZ2VfYXR0cmlidXRlICsr
Ow0KKwlhdG9taWNfZGVjKCZuZnNpLT5kYXRhX3VwZGF0ZXMpOw0KIH0NCiANCiAvKioNCkBAIC0x
MTIyLDYgKzExMjEsMTAgQEAgaW50IG5mc19yZWZyZXNoX2lub2RlKHN0cnVjdCBpbm9kZSAqaW5v
ZA0KIAkJCXx8IGlub2RlLT5pX2dpZCAhPSBmYXR0ci0+Z2lkKQ0KIAkJbmZzaS0+ZmxhZ3MgfD0g
TkZTX0lOT19JTlZBTElEX0FUVFI7DQogDQorCS8qIEhhcyB0aGUgbGluayBjb3VudCBjaGFuZ2Vk
PyAqLw0KKwlpZiAoaW5vZGUtPmlfbmxpbmsgIT0gZmF0dHItPm5saW5rKQ0KKwkJbmZzaS0+Zmxh
Z3MgfD0gTkZTX0lOT19JTlZBTElEX0FUVFI7DQorDQogCWlmICghdGltZXNwZWNfZXF1YWwoJmlu
b2RlLT5pX2F0aW1lLCAmZmF0dHItPmF0aW1lKSkNCiAJCW5mc2ktPmZsYWdzIHw9IE5GU19JTk9f
SU5WQUxJRF9BVElNRTsNCiANCmRpZmYgLXUgLS1yZWN1cnNpdmUgLS1uZXctZmlsZSAtLXNob3ct
Yy1mdW5jdGlvbiBsaW51eC0yLjYuNC0wMS1hdHRyLm9sZC9mcy9uZnMvd3JpdGUuYyBsaW51eC0y
LjYuNC0wMS1hdHRyL2ZzL25mcy93cml0ZS5jDQotLS0gbGludXgtMi42LjQtMDEtYXR0ci5vbGQv
ZnMvbmZzL3dyaXRlLmMJMjAwNC0wMy0wOSAwOToxNzoxNi4wMDAwMDAwMDAgLTA1MDANCisrKyBs
aW51eC0yLjYuNC0wMS1hdHRyL2ZzL25mcy93cml0ZS5jCTIwMDQtMDMtMDkgMDk6MjQ6NTEuMDAw
MDAwMDAwIC0wNTAwDQpAQCAtMjA1LDcgKzIwNSw2IEBAIHN0YXRpYyBpbnQgbmZzX3dyaXRlcGFn
ZV9hc3luYyhzdHJ1Y3QgZmkNCiAJbG9mZl90CQllbmQ7DQogCWludAkJc3RhdHVzOw0KIA0KLQlu
ZnNfYmVnaW5fZGF0YV91cGRhdGUoaW5vZGUpOw0KIAlyZXEgPSBuZnNfdXBkYXRlX3JlcXVlc3Qo
ZmlsZSwgaW5vZGUsIHBhZ2UsIG9mZnNldCwgY291bnQpOw0KIAlzdGF0dXMgPSAoSVNfRVJSKHJl
cSkpID8gUFRSX0VSUihyZXEpIDogMDsNCiAJaWYgKHN0YXR1cyA8IDApDQpAQCAtMjE2LDcgKzIx
NSw2IEBAIHN0YXRpYyBpbnQgbmZzX3dyaXRlcGFnZV9hc3luYyhzdHJ1Y3QgZmkNCiAJaWYgKGlf
c2l6ZV9yZWFkKGlub2RlKSA8IGVuZCkNCiAJCWlfc2l6ZV93cml0ZShpbm9kZSwgZW5kKTsNCiAg
b3V0Og0KLQluZnNfZW5kX2RhdGFfdXBkYXRlKGlub2RlKTsNCiAJcmV0dXJuIHN0YXR1czsNCiB9
DQogDQpAQCAtNzAxLDcgKzY5OSw2IEBAIG5mc191cGRhdGVwYWdlKHN0cnVjdCBmaWxlICpmaWxl
LCBzdHJ1Y3QNCiAJCXJldHVybiBzdGF0dXM7DQogCX0NCiANCi0JbmZzX2JlZ2luX2RhdGFfdXBk
YXRlKGlub2RlKTsNCiAJLyoNCiAJICogVHJ5IHRvIGZpbmQgYW4gTkZTIHJlcXVlc3QgY29ycmVz
cG9uZGluZyB0byB0aGlzIHBhZ2UNCiAJICogYW5kIHVwZGF0ZSBpdC4NCkBAIC03MzUsNyArNzMy
LDYgQEAgbmZzX3VwZGF0ZXBhZ2Uoc3RydWN0IGZpbGUgKmZpbGUsIHN0cnVjdA0KIAl9IGVsc2UN
CiAJCW5mc191bmxvY2tfcmVxdWVzdChyZXEpOw0KIGRvbmU6DQotCW5mc19lbmRfZGF0YV91cGRh
dGUoaW5vZGUpOw0KICAgICAgICAgZHByaW50aygiTkZTOiAgICAgIG5mc191cGRhdGVwYWdlIHJl
dHVybnMgJWQgKGlzaXplICVMZClcbiIsDQogCQkJc3RhdHVzLCAobG9uZyBsb25nKWlfc2l6ZV9y
ZWFkKGlub2RlKSk7DQogCWlmIChzdGF0dXMgPCAwKQ0K

--=-54S+PrFCuHkcHDrmobxN--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
