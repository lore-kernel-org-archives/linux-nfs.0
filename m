From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] interruptible_sleep_on in lockd
Date: Thu, 01 Apr 2004 17:58:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080860335.2682.68.camel@lade.trondhjem.org>
References: <20040401202656.A24371@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-VQLhbHPEhzQn5Jiyi7my"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9B9I-00027Y-Tz
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 14:59:00 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B9B9I-0006rP-C3
	for nfs@lists.sourceforge.net; Thu, 01 Apr 2004 14:59:00 -0800
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20040401202656.A24371@infradead.org>
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


--=-VQLhbHPEhzQn5Jiyi7my
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2004-04-01 at 14:26, Christoph Hellwig wrote:
> interruptible_sleep_on looks rather bogus, especially when ignoring whether
> it actually was interrupted.  What about the patch below?

The whole way we handle this whole grace period situation looks dubious.
The fact that we have finished reclaiming locks is not the same as
saying that the server is out of its grace period.
Something like the following is perhaps more appropriate.

Cheers,
  Trond



--=-VQLhbHPEhzQn5Jiyi7my
Content-Description: 
Content-Disposition: inline; filename=linux-2.6.5-35-grace.dif
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=iso-8859-1

IGNsbnRsb2NrLmMgfCAgICAxIC0NCiBjbG50cHJvYy5jIHwgICA0NiArKysrKysrKysrKysrKysr
KysrKysrKysrKysrKystLS0tLS0tLS0tLS0tLS0tDQogMiBmaWxlcyBjaGFuZ2VkLCAzMCBpbnNl
cnRpb25zKCspLCAxNyBkZWxldGlvbnMoLSkNCg0KZGlmZiAtdSAtLXJlY3Vyc2l2ZSAtLW5ldy1m
aWxlIC0tc2hvdy1jLWZ1bmN0aW9uIGxpbnV4LTIuNi41LTM0LXJwY19jb25uZWN0L2ZzL2xvY2tk
L2NsbnRsb2NrLmMgbGludXgtMi42LjUtMzUtZ3JhY2UvZnMvbG9ja2QvY2xudGxvY2suYw0KLS0t
IGxpbnV4LTIuNi41LTM0LXJwY19jb25uZWN0L2ZzL2xvY2tkL2NsbnRsb2NrLmMJMjAwNC0wMy0z
MSAyMTo0NDoxNC4wMDAwMDAwMDAgLTA1MDANCisrKyBsaW51eC0yLjYuNS0zNS1ncmFjZS9mcy9s
b2NrZC9jbG50bG9jay5jCTIwMDQtMDQtMDEgMTc6MDM6MDMuMDAwMDAwMDAwIC0wNTAwDQpAQCAt
MjI4LDcgKzIyOCw2IEBAIHJlc3RhcnQ6DQogCX0NCiANCiAJaG9zdC0+aF9yZWNsYWltaW5nID0g
MDsNCi0Jd2FrZV91cCgmaG9zdC0+aF9ncmFjZXdhaXQpOw0KIA0KIAkvKiBOb3csIHdha2UgdXAg
YWxsIHByb2Nlc3NlcyB0aGF0IHNsZWVwIG9uIGEgYmxvY2tlZCBsb2NrICovDQogCWZvciAoYmxv
Y2sgPSBubG1fYmxvY2tlZDsgYmxvY2s7IGJsb2NrID0gYmxvY2stPmJfbmV4dCkgew0KZGlmZiAt
dSAtLXJlY3Vyc2l2ZSAtLW5ldy1maWxlIC0tc2hvdy1jLWZ1bmN0aW9uIGxpbnV4LTIuNi41LTM0
LXJwY19jb25uZWN0L2ZzL2xvY2tkL2NsbnRwcm9jLmMgbGludXgtMi42LjUtMzUtZ3JhY2UvZnMv
bG9ja2QvY2xudHByb2MuYw0KLS0tIGxpbnV4LTIuNi41LTM0LXJwY19jb25uZWN0L2ZzL2xvY2tk
L2NsbnRwcm9jLmMJMjAwNC0wMy0zMSAyMTozNDoxNC4wMDAwMDAwMDAgLTA1MDANCisrKyBsaW51
eC0yLjYuNS0zNS1ncmFjZS9mcy9sb2NrZC9jbG50cHJvYy5jCTIwMDQtMDQtMDEgMTc6NTQ6NDQu
MDAwMDAwMDAwIC0wNTAwDQpAQCAtMjE3LDYgKzIxNywyMSBAQCBubG1jbG50X2FsbG9jX2NhbGwo
dm9pZCkNCiAJcmV0dXJuIE5VTEw7DQogfQ0KIA0KK3N0YXRpYyBpbnQgbmxtX3dhaXRfb25fZ3Jh
Y2Uod2FpdF9xdWV1ZV9oZWFkX3QgKnF1ZXVlKQ0KK3sNCisJREVGSU5FX1dBSVQod2FpdCk7DQor
CWludCBzdGF0dXMgPSAtRUlOVFI7DQorDQorCXByZXBhcmVfdG9fd2FpdChxdWV1ZSwgJndhaXQs
IFRBU0tfSU5URVJSVVBUSUJMRSk7DQorCWlmICghc2lnbmFsbGVkICgpKSB7DQorCQlzY2hlZHVs
ZV90aW1lb3V0KE5MTUNMTlRfR1JBQ0VfV0FJVCk7DQorCQlpZiAoIXNpZ25hbGxlZCAoKSkNCisJ
CQlzdGF0dXMgPSAwOw0KKwl9DQorCWZpbmlzaF93YWl0KHF1ZXVlLCAmd2FpdCk7DQorCXJldHVy
biBzdGF0dXM7DQorfQ0KKw0KIC8qDQogICogR2VuZXJpYyBOTE0gY2FsbA0KICAqLw0KQEAgLTI0
MSwxMCArMjU2LDggQEAgbmxtY2xudF9jYWxsKHN0cnVjdCBubG1fcnFzdCAqcmVxLCB1MzIgcA0K
IAkJbXNnLnJwY19jcmVkID0gbmZzX2ZpbGVfY3JlZChmaWxwKTsNCiANCiAJZG8gew0KLQkJaWYg
KGhvc3QtPmhfcmVjbGFpbWluZyAmJiAhYXJncC0+cmVjbGFpbSkgew0KLQkJCWludGVycnVwdGli
bGVfc2xlZXBfb24oJmhvc3QtPmhfZ3JhY2V3YWl0KTsNCi0JCQljb250aW51ZTsNCi0JCX0NCisJ
CWlmIChob3N0LT5oX3JlY2xhaW1pbmcgJiYgIWFyZ3AtPnJlY2xhaW0pDQorCQkJZ290byBpbl9n
cmFjZV9wZXJpb2Q7DQogDQogCQkvKiBJZiB3ZSBoYXZlIG5vIFJQQyBjbGllbnQgeWV0LCBjcmVh
dGUgb25lLiAqLw0KIAkJaWYgKChjbG50ID0gbmxtX2JpbmRfaG9zdChob3N0KSkgPT0gTlVMTCkN
CkBAIC0yNzksMjIgKzI5MiwyMyBAQCBubG1jbG50X2NhbGwoc3RydWN0IG5sbV9ycXN0ICpyZXEs
IHUzMiBwDQogCQkJCXJldHVybiAtRU5PTENLOw0KIAkJCX0NCiAJCX0gZWxzZSB7DQorCQkJaWYg
KCFhcmdwLT5yZWNsYWltKSB7DQorCQkJCS8qIFdlIGFwcGVhciB0byBiZSBvdXQgb2YgdGhlIGdy
YWNlIHBlcmlvZCAqLw0KKwkJCQl3YWtlX3VwX2FsbCgmaG9zdC0+aF9ncmFjZXdhaXQpOw0KKwkJ
CX0NCiAJCQlkcHJpbnRrKCJsb2NrZDogc2VydmVyIHJldHVybnMgc3RhdHVzICVkXG4iLCByZXNw
LT5zdGF0dXMpOw0KIAkJCXJldHVybiAwOwkvKiBPa2F5LCBjYWxsIGNvbXBsZXRlICovDQogCQl9
DQogDQotCQkvKiBCYWNrIG9mZiBhIGxpdHRsZSBhbmQgdHJ5IGFnYWluICovDQotCQlpbnRlcnJ1
cHRpYmxlX3NsZWVwX29uX3RpbWVvdXQoJmhvc3QtPmhfZ3JhY2V3YWl0LCAxNSpIWik7DQotDQot
CQkvKiBXaGVuIHRoZSBsb2NrIHJlcXVlc3RlZCBieSBGX1NFVExLVyBpc24ndCBhdmFpbGFibGUs
DQotCQkgICB3ZSB3aWxsIHdhaXQgdW50aWwgdGhlIHJlcXVlc3QgY2FuIGJlIHNhdGlzZmllZC4g
SWYNCi0JCSAgIGEgc2lnbmFsIGlzIHJlY2VpdmVkIGR1cmluZyB3YWl0LCB3ZSBzaG91bGQgcmV0
dXJuDQotCQkgICAtRUlOVFIuICovDQotCQlpZiAoc2lnbmFsbGVkICgpKSB7DQotCQkJc3RhdHVz
ID0gLUVJTlRSOw0KLQkJCWJyZWFrOw0KLQkJfQ0KLQl9IHdoaWxlICgxKTsNCitpbl9ncmFjZV9w
ZXJpb2Q6DQorCQkvKg0KKwkJICogVGhlIHNlcnZlciBoYXMgcmVib290ZWQgYW5kIGFwcGVhcnMg
dG8gYmUgaW4gdGhlIGdyYWNlDQorCQkgKiBwZXJpb2QgZHVyaW5nIHdoaWNoIGxvY2tzIGFyZSBv
bmx5IGFsbG93ZWQgdG8gYmUNCisJCSAqIHJlY2xhaW1lZC4NCisJCSAqIFdlIGNhbiBvbmx5IGJh
Y2sgb2ZmIGFuZCB0cnkgYWdhaW4gbGF0ZXIuDQorCQkgKi8NCisJCXN0YXR1cyA9IG5sbV93YWl0
X29uX2dyYWNlKCZob3N0LT5oX2dyYWNld2FpdCk7DQorCX0gd2hpbGUgKHN0YXR1cyA9PSAwKTsN
CiANCiAJcmV0dXJuIHN0YXR1czsNCiB9DQo=

--=-VQLhbHPEhzQn5Jiyi7my--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
