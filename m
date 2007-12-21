From: "Mike Snitzer" <snitzer@gmail.com>
Subject: [RFC][PATCH] lockd: refine support for deferred blocking locks
Date: Fri, 21 Dec 2007 17:50:58 -0500
Message-ID: <170fa0d20712211450u6cdddf8dlfcef04d9e59bf12c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2329_7443381.1198277459026"
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:64536 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755720AbXLUWvD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2007 17:51:03 -0500
Received: by py-out-1112.google.com with SMTP id u77so1137104pyb.16
        for <linux-nfs@vger.kernel.org>; Fri, 21 Dec 2007 14:51:00 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_Part_2329_7443381.1198277459026
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Dec 19, 2007 12:45 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Tue, Dec 18, 2007 at 11:03:01PM -0500, Mike Snitzer wrote:
> > I could be missing something blatantly obvious so please be kind...
> >
> > I would like to understand how one _should_ implement ->lock() for a
> > filesystem that can't immediately determine that the request would
> > result in -EDEADLK or -ENOLCK.  Particularly for deferred SETLKW
> > requests.
> >
> > That is, the filesystem's ->lock() initially responds with
> > -EINPROGRESS but later goes on to fail the request with -EDEADLK or
> > -ENOLCK.  The filesystem's call to ->fl_grant() will be made with an
> > unsupported 'result'.
> >
> > Having reviewed the code in fs/lockd/svclock.c it would seem that it
> > was never designed to allow EDEADLK or ENOLCK _after_ nlmsvc_lock()'s
> > initial call to vfs_lock_file().
> >
> > nlmsvc_grant_deferred() properly handles deferred SETLKW processing
> > IFF the result is 0 (aka granted).
> > nlmsvc_grant_deferred()'s SETLK processing will at least return
> > failures (but they are assumed to be B_TIMED_OUT).
> > In the end the real 'result' gets dropped on the floor.
> >
> > Why must ->lock() immediately return error (e.g. EDEADLK), otherwise
> > it is assumed the request will complete successfully (or timeout in
> > the B_QUEUED/SETLK case)?  Seems overly constrained (painfully so for
> > SETLKW) when you consider that the whole point of deferred processing
> > (via EINPROGRESS and ->fl_grant) is to accomodate filesystems that
> > can't respond to a lock request immediately.
>
> Yeah, the assuumption was that we only needed to deal with non-blocking
> requests first, under the theory that the blocking case could always be
> handled with a deny followed by an eventual grant.  Which, as you point
> out, may not ever be coming in the EDEALK or ENOLCK cases.  I'm inclined
> to agree it's ugly.
>
> That said, I find it hard to care about the EDEADLK case--deadlock
> detection just isn't going to be reliable in the presence of nfs clients
> anyway.  And are there really a lot of cases where ENOLCK has to be
> returned and where the local filesystem doesn't know that immediately?
>
> But it should probably be rethought anyway.  I'm grateful for any
> suggestions (but probably won't be working on this seriously until the
> new year).

Hi Bruce,

The attached patch is an example of one possible way to refine how lockd
and ->lock process blocking lock.  Here is a general overview for the patch:

Filesystems that cannot respond to blocking lock requests immediately are
allowed to leverage asynchronous processing semantics via ->fl_grant().
The current lockd code unfortunately requires the filesystem's ->lock() to
respond immediately with an error if the lock will be denied (EDEADLOCK,
ENOLCK, etc).  Otherwise, lockd assumes that the blocking lock will
eventually be granted.

To refine deferred blocking lock processing semantics it would be ideal to
flag such requests as B_QUEUED_WAIT iff ->lock() initially responds with
EINPROGRESS.  B_QUEUED_WAIT conveys that ->lock() is actively working on
the blocking request and will respond with the result via ->fl_grant().
As such, subsequent lockd attempts to vfs_lock_file() are _not_ needed,
and are avoided entirely, because the eventual ->lock() result will be
returned via the ->fl_grant() callback.  The callback's result is stored
in a new 'b_result' data member of struct nlm_block.  b_result is known to
be valid iff B_GOT_CALLBACK is set.

The proposed implementation does not yet prevent/warn against some
filesystem's ->lock() from returning an ->fl_grant() result of EINPROGRESS
or EAGAIN.  Such a result does not make sense as the final result of the
deferred blocking lock request.

Please advise, thanks.
Mike

------=_Part_2329_7443381.1198277459026
Content-Type: text/x-patch;
 name=lockd-refine-support-for-deferred-blocking-locks.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fahbcuul0
Content-Disposition: attachment;
 filename=lockd-refine-support-for-deferred-blocking-locks.patch

ZGlmZiAtLWdpdCBhL2ZzL2xvY2tkL3N2Y2xvY2suYyBiL2ZzL2xvY2tkL3N2Y2xvY2suYwppbmRl
eCBkMTIwZWMzLi4zNWI5N2UxIDEwMDY0NAotLS0gYS9mcy9sb2NrZC9zdmNsb2NrLmMKKysrIGIv
ZnMvbG9ja2Qvc3ZjbG9jay5jCkBAIC00MDksMTMgKzQwOSwyMCBAQCBubG1zdmNfbG9jayhzdHJ1
Y3Qgc3ZjX3Jxc3QgKnJxc3RwLCBzdHJ1Y3QgbmxtX2ZpbGUgKmZpbGUsCiAJCX0KIAkJcmV0ID0g
bmxtX2Ryb3BfcmVwbHk7CiAJCWdvdG8gb3V0OwotCX0KLQotCWlmICghd2FpdCkKKwl9IGVsc2Ug
aWYgKGJsb2NrLT5iX2ZsYWdzICYgQl9RVUVVRURfV0FJVCkgeworCQkvKiBEb24ndCByZXRyeSBh
IGRlZmVycmVkIGJsb2NraW5nIHJlcXVlc3QgKi8KKwkJZHByaW50aygibG9ja2Q6IG5sbXN2Y19s
b2NrIGRlZmVycmVkIGJsb2NraW5nIGJsb2NrICVwIGZsYWdzICVkXG4iLAorCQkJCQkJCWJsb2Nr
LCBibG9jay0+Yl9mbGFncyk7CisJCWVycm9yID0gLUVJTlBST0dSRVNTOworCQlpZiAoYmxvY2st
PmJfZmxhZ3MgJiBCX0dPVF9DQUxMQkFDSykKKwkJCWVycm9yID0gYmxvY2stPmJfcmVzdWx0Owor
CX0gZWxzZSB7CisJCWlmICghd2FpdCkKKwkJCWxvY2stPmZsLmZsX2ZsYWdzICY9IH5GTF9TTEVF
UDsKKwkJZXJyb3IgPSB2ZnNfbG9ja19maWxlKGZpbGUtPmZfZmlsZSwgRl9TRVRMSywgJmxvY2st
PmZsLCBOVUxMKTsKIAkJbG9jay0+ZmwuZmxfZmxhZ3MgJj0gfkZMX1NMRUVQOwotCWVycm9yID0g
dmZzX2xvY2tfZmlsZShmaWxlLT5mX2ZpbGUsIEZfU0VUTEssICZsb2NrLT5mbCwgTlVMTCk7Ci0J
bG9jay0+ZmwuZmxfZmxhZ3MgJj0gfkZMX1NMRUVQOwotCisJfQorCQogCWRwcmludGsoImxvY2tk
OiB2ZnNfbG9ja19maWxlIHJldHVybmVkICVkXG4iLCBlcnJvcik7CiAJc3dpdGNoKGVycm9yKSB7
CiAJCWNhc2UgMDoKQEAgLTQyNSw4ICs0MzIsMTAgQEAgbmxtc3ZjX2xvY2soc3RydWN0IHN2Y19y
cXN0ICpycXN0cCwgc3RydWN0IG5sbV9maWxlICpmaWxlLAogCQkJcmV0ID0gbmxtX2xja19kZW5p
ZWQ7CiAJCQlicmVhazsKIAkJY2FzZSAtRUlOUFJPR1JFU1M6Ci0JCQlpZiAod2FpdCkKKwkJCWlm
ICh3YWl0KSB7CisJCQkJYmxvY2stPmJfZmxhZ3MgfD0gQl9RVUVVRURfV0FJVDsKIAkJCQlicmVh
azsKKwkJCX0KIAkJCS8qIEZpbGVzeXN0ZW0gbG9jayBvcGVyYXRpb24gaXMgaW4gcHJvZ3Jlc3MK
IAkJCSAgIEFkZCBpdCB0byB0aGUgcXVldWUgd2FpdGluZyBmb3IgY2FsbGJhY2sgKi8KIAkJCXJl
dCA9IG5sbXN2Y19kZWZlcl9sb2NrX3Jxc3QocnFzdHAsIGJsb2NrKTsKQEAgLTYyMiw5ICs2MzEs
MTEgQEAgbmxtc3ZjX3VwZGF0ZV9kZWZlcnJlZF9ibG9jayhzdHJ1Y3QgbmxtX2Jsb2NrICpibG9j
aywgc3RydWN0IGZpbGVfbG9jayAqY29uZiwKIAkJCSAgICAgaW50IHJlc3VsdCkKIHsKIAlibG9j
ay0+Yl9mbGFncyB8PSBCX0dPVF9DQUxMQkFDSzsKKwkvKiBOT1RFOiBhIGNhbGxiYWNrIHJlc3Vs
dCBvZiBFQUdBSU4gb3IgRUlOUFJPR1JFU1MgaXMgaW52YWxpZCAqLworCWJsb2NrLT5iX3Jlc3Vs
dCA9IHJlc3VsdDsKIAlpZiAocmVzdWx0ID09IDApCiAJCWJsb2NrLT5iX2dyYW50ZWQgPSAxOwot
CWVsc2UKKwllbHNlIGlmIChibG9jay0+Yl9mbGFncyAmIEJfUVVFVUVEKQogCQlibG9jay0+Yl9m
bGFncyB8PSBCX1RJTUVEX09VVDsKIAlpZiAoY29uZikgewogCQlpZiAoYmxvY2stPmJfZmwpCkBA
IC02NDgsMTAgKzY1OSw5IEBAIHN0YXRpYyBpbnQgbmxtc3ZjX2dyYW50X2RlZmVycmVkKHN0cnVj
dCBmaWxlX2xvY2sgKmZsLCBzdHJ1Y3QgZmlsZV9sb2NrICpjb25mLAogCQkJCQlyYyA9IC1FTk9M
Q0s7CiAJCQkJCWJyZWFrOwogCQkJCX0KLQkJCQlubG1zdmNfdXBkYXRlX2RlZmVycmVkX2Jsb2Nr
KGJsb2NrLCBjb25mLCByZXN1bHQpOwotCQkJfSBlbHNlIGlmIChyZXN1bHQgPT0gMCkKLQkJCQli
bG9jay0+Yl9ncmFudGVkID0gMTsKLQorCQkJfQorCQkJbmxtc3ZjX3VwZGF0ZV9kZWZlcnJlZF9i
bG9jayhibG9jaywgY29uZiwgcmVzdWx0KTsKKwkJCQogCQkJbmxtc3ZjX2luc2VydF9ibG9jayhi
bG9jaywgMCk7CiAJCQlzdmNfd2FrZV91cChibG9jay0+Yl9kYWVtb24pOwogCQkJcmMgPSAwOwpA
QCAtNzMyLDExICs3NDIsMTggQEAgbmxtc3ZjX2dyYW50X2Jsb2NrZWQoc3RydWN0IG5sbV9ibG9j
ayAqYmxvY2spCiAJCWdvdG8gY2FsbGJhY2s7CiAJfQogCi0JLyogVHJ5IHRoZSBsb2NrIG9wZXJh
dGlvbiBhZ2FpbiAqLwotCWxvY2stPmZsLmZsX2ZsYWdzIHw9IEZMX1NMRUVQOwotCWVycm9yID0g
dmZzX2xvY2tfZmlsZShmaWxlLT5mX2ZpbGUsIEZfU0VUTEssICZsb2NrLT5mbCwgTlVMTCk7Ci0J
bG9jay0+ZmwuZmxfZmxhZ3MgJj0gfkZMX1NMRUVQOwotCisJaWYgKGJsb2NrLT5iX2ZsYWdzICYg
Ql9RVUVVRURfV0FJVCkgeworCQkvKiBEb24ndCByZXRyeSBhIGRlZmVycmVkIGJsb2NraW5nIHJl
cXVlc3QgKi8KKwkJZXJyb3IgPSAtRUlOUFJPR1JFU1M7CisJCWlmIChibG9jay0+Yl9mbGFncyAm
IEJfR09UX0NBTExCQUNLKQorCQkJZXJyb3IgPSBibG9jay0+Yl9yZXN1bHQ7CisJfSBlbHNlIHsK
KwkJLyogVHJ5IHRoZSBsb2NrIG9wZXJhdGlvbiBhZ2FpbiAqLworCQlsb2NrLT5mbC5mbF9mbGFn
cyB8PSBGTF9TTEVFUDsKKwkJZXJyb3IgPSB2ZnNfbG9ja19maWxlKGZpbGUtPmZfZmlsZSwgRl9T
RVRMSywgJmxvY2stPmZsLCBOVUxMKTsKKwkJbG9jay0+ZmwuZmxfZmxhZ3MgJj0gfkZMX1NMRUVQ
OworCX0KKwkJCiAJc3dpdGNoIChlcnJvcikgewogCWNhc2UgMDoKIAkJYnJlYWs7CmRpZmYgLS1n
aXQgYS9pbmNsdWRlL2xpbnV4L2xvY2tkL2xvY2tkLmggYi9pbmNsdWRlL2xpbnV4L2xvY2tkL2xv
Y2tkLmgKaW5kZXggZTJkMWNlMy4uMTg3YWZjZiAxMDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9s
b2NrZC9sb2NrZC5oCisrKyBiL2luY2x1ZGUvbGludXgvbG9ja2QvbG9ja2QuaApAQCAtMTM3LDEw
ICsxMzcsMTIgQEAgc3RydWN0IG5sbV9ibG9jayB7CiAJc3RydWN0IGNhY2hlX3JlcSAqCWJfY2Fj
aGVfcmVxOwkvKiBkZWZlcnJlZCByZXF1ZXN0IGhhbmRsaW5nICovCiAJc3RydWN0IGZpbGVfbG9j
ayAqCWJfZmw7CQkvKiBzZXQgZm9yIEdFVExLICovCiAJc3RydWN0IGNhY2hlX2RlZmVycmVkX3Jl
cSAqIGJfZGVmZXJyZWRfcmVxOworCXVuc2lnbmVkIGludAkJYl9yZXN1bHQ7CS8qIGNhbGxiYWNr
IHJlc3VsdCAqLwogCXVuc2lnbmVkIGludAkJYl9mbGFnczsJLyogYmxvY2sgZmxhZ3MgKi8KICNk
ZWZpbmUgQl9RVUVVRUQJCTEJLyogbG9jayBxdWV1ZWQgKi8KICNkZWZpbmUgQl9HT1RfQ0FMTEJB
Q0sJCTIJLyogZ290IGxvY2sgb3IgY29uZmxpY3RpbmcgbG9jayAqLwogI2RlZmluZSBCX1RJTUVE
X09VVAkJNAkvKiBmaWxlc3lzdGVtIHRvbyBzbG93IHRvIHJlc3BvbmQgKi8KKyNkZWZpbmUgQl9R
VUVVRURfV0FJVAkJOAkvKiBibG9ja2luZyBsb2NrIHF1ZXVlZCAqLwogfTsKIAogLyoK
------=_Part_2329_7443381.1198277459026--
