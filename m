From: "Lever, Charles" <cel@netapp.com>
Subject: [RFC]: ESTALE is not a permanent error
Date: Wed, 22 Sep 2004 13:44:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E85A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C4A0E4.FC04C0DC"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CADyz-0001iB-O1
	for nfs@lists.sourceforge.net; Wed, 22 Sep 2004 13:44:57 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CADyx-0000jp-NA
	for nfs@lists.sourceforge.net; Wed, 22 Sep 2004 13:44:57 -0700
To: <trond.myklebust@fys.uio.no>
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

This is a multi-part message in MIME format.

------_=_NextPart_001_01C4A0E4.FC04C0DC
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

we've had some customer complaints about ESTALEs becoming permanent
errors, until a file system is unmounted and remounted again.  ESTALE
can be temporary if an NFS share is unexported and reexported while a
client is actively using files on that export.  we've seen this problem
on 2.4 and 2.6 clients, but the Solaris client seems to deal with it
correctly.

the logic in nfs_lookup_revalidate doesn't handle stale inodes
correctly. right now, if nfs_cached_lookup doesn't find the matching
entry and the inode is already marked stale, there is no way to
revalidate the file handle again.

if a real lookup is used to revalidate the file handle, that should be
enough to allow the client to clear NFS_INO_STALE on a stale inode,
right?

i've attached a tested patch (against 2.6.9-rc2) that allows
nfs_lookup_revalidate to recover from a stale file handle properly.

comments?

	- Chuck Lever
--
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>

------_=_NextPart_001_01C4A0E4.FC04C0DC
Content-Type: TEXT/PLAIN;
	name="71-nfs-revalidate-estale.patch"
Content-Transfer-Encoding: base64
Content-Description: 71-nfs-revalidate-estale.patch
Content-Disposition: attachment;
	filename="71-nfs-revalidate-estale.patch"

IA0KIFN1YmplY3Q6IFtQQVRDSF0gTkZTOiBFU1RBTEUgaXMgbm90IGEgcGVybWFuZW50IGVycm9y
DQoNCiBEZXNjcmlwdGlvbjoNCiBOZnNfbG9va3VwX3JldmFsaWRhdGUoKSBzaG91bGQgY2xlYXIg
dGhlIE5GU19JTk9fU1RBTEUgZmxhZyB3aGVuIGl0IGhhcw0KIHZhbGlkYXRlZCBhIGZpbGUgaGFu
ZGxlIHdpdGggYSByZWFsIExPT0tVUCBvcGVyYXRpb24uDQoNCiBUZXN0IHBsYW46DQogQXJ0aWZp
Y2lhbGx5IGdlbmVyYXRlIEVTVEFMRSByZXN1bHRzIGJ5IHVuZXhwb3J0aW5nIGEgZmlsZSBzeXN0
ZW0gd2hpbGUNCiBpdCBpcyBtb3VudGVkIGZyb20gY2xpZW50cy4gIFJlLWV4cG9ydGluZyBpdCBz
aG91bGQgYWxsb3cgbm9ybWFsIGFjY2Vzcw0KIGZyb20gYWxsIGNsaWVudHMuDQoNCiBDcmVhdGVk
OiBXZWQsIDIyIFNlcCAyMDA0IDE2OjM4OjE3IC0wNDAwDQogDQogU2lnbmVkLW9mZi1ieTogQ2h1
Y2sgTGV2ZXIgPGNlbEBuZXRhcHAuY29tPg0KLS0tDQogDQogZnMvbmZzL2Rpci5jIHwgICAxOCAr
KysrKysrKysrLS0tLS0tLS0NCiAxIGZpbGVzIGNoYW5nZWQsIDEwIGluc2VydGlvbnMoKyksIDgg
ZGVsZXRpb25zKC0pDQogDQogDQpkaWZmIC1YIC9ob21lL2NlbC9zcmMvbGludXgvZG9udC1kaWZm
IC1OYXVycCA3MC1uZnMtYmxvY2tzaXplMi9mcy9uZnMvZGlyLmMgNzEtbmZzLXJldmFsaWRhdGUt
ZXN0YWxlL2ZzL25mcy9kaXIuYw0KLS0tIDcwLW5mcy1ibG9ja3NpemUyL2ZzL25mcy9kaXIuYwky
MDA0LTA5LTIxIDAwOjE0OjA5LjI1ODI5NzAwMCAtMDQwMA0KKysrIDcxLW5mcy1yZXZhbGlkYXRl
LWVzdGFsZS9mcy9uZnMvZGlyLmMJMjAwNC0wOS0yMiAxNjowOToyMy4zNzg4MTcwMDAgLTA0MDAN
CkBAIC02NzIsMTYgKzY3MiwxNSBAQCBzdGF0aWMgaW50IG5mc19sb29rdXBfcmV2YWxpZGF0ZShz
dHJ1Y3QgDQogCXZlcmlmaWVyID0gbmZzX3NhdmVfY2hhbmdlX2F0dHJpYnV0ZShkaXIpOw0KIAll
cnJvciA9IG5mc19jYWNoZWRfbG9va3VwKGRpciwgZGVudHJ5LCAmZmhhbmRsZSwgJmZhdHRyKTsN
CiAJaWYgKCFlcnJvcikgew0KLQkJaWYgKG5mc19jb21wYXJlX2ZoKE5GU19GSChpbm9kZSksICZm
aGFuZGxlKSkNCi0JCQlnb3RvIG91dF9iYWQ7DQotCQlpZiAobmZzX2xvb2t1cF92ZXJpZnlfaW5v
ZGUoaW5vZGUsIGlzb3BlbikpDQotCQkJZ290byBvdXRfemFwX3BhcmVudDsNCi0JCWdvdG8gb3V0
X3ZhbGlkX3JlbmV3Ow0KKwkJaWYgKCFORlNfU1RBTEUoaW5vZGUpKSB7DQorCQkJaWYgKG5mc19j
b21wYXJlX2ZoKE5GU19GSChpbm9kZSksICZmaGFuZGxlKSkNCisJCQkJZ290byBvdXRfYmFkOw0K
KwkJCWlmIChuZnNfbG9va3VwX3ZlcmlmeV9pbm9kZShpbm9kZSwgaXNvcGVuKSkNCisJCQkJZ290
byBvdXRfemFwX3BhcmVudDsNCisJCQlnb3RvIG91dF92YWxpZF9yZW5ldzsNCisJCX0NCiAJfQ0K
IA0KLQlpZiAoTkZTX1NUQUxFKGlub2RlKSkNCi0JCWdvdG8gb3V0X2JhZDsNCi0NCiAJZXJyb3Ig
PSBORlNfUFJPVE8oZGlyKS0+bG9va3VwKGRpciwgJmRlbnRyeS0+ZF9uYW1lLCAmZmhhbmRsZSwg
JmZhdHRyKTsNCiAJaWYgKGVycm9yKQ0KIAkJZ290byBvdXRfYmFkOw0KQEAgLTY5MCw2ICs2ODks
OSBAQCBzdGF0aWMgaW50IG5mc19sb29rdXBfcmV2YWxpZGF0ZShzdHJ1Y3QgDQogCWlmICgoZXJy
b3IgPSBuZnNfcmVmcmVzaF9pbm9kZShpbm9kZSwgJmZhdHRyKSkgIT0gMCkNCiAJCWdvdG8gb3V0
X2JhZDsNCiANCisJLyogdGhpcyByZXZhbGlkYXRlcyBvdXIgY2FjaGVkIGZpbGUgaGFuZGxlLiAq
Lw0KKwlORlNfRkxBR1MoaW5vZGUpICY9IH5ORlNfSU5PX1NUQUxFOw0KKw0KICBvdXRfdmFsaWRf
cmVuZXc6DQogCW5mc19yZW5ld190aW1lcyhkZW50cnkpOw0KIAluZnNfc2V0X3ZlcmlmaWVyKGRl
bnRyeSwgdmVyaWZpZXIpOw0K

------_=_NextPart_001_01C4A0E4.FC04C0DC--


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
