From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [PATCH 4/4] NLM: don't requeue block if it was invalidated while GRANT_MSG was in flight
Date: Fri, 14 Mar 2008 15:55:38 -0400
Message-ID: <170fa0d20803141255k41e8e2a3t6a53f4f812a15d7b@mail.gmail.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-3-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-4-git-send-email-jlayton@redhat.com>
	 <1202315653-11840-5-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_3010_31401078.1205524539024"
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.183]:8266 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945AbYCNTzl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 15:55:41 -0400
Received: by el-out-1112.google.com with SMTP id v27so2635675ele.17
        for <linux-nfs@vger.kernel.org>; Fri, 14 Mar 2008 12:55:39 -0700 (PDT)
In-Reply-To: <1202315653-11840-5-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

------=_Part_3010_31401078.1205524539024
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On 2/6/08, Jeff Layton <jlayton@redhat.com> wrote:
> It's possible for lockd to catch a SIGKILL while a GRANT_MSG callback
>  is in flight. If this happens we don't want lockd to insert the block
>  back into the nlm_blocked list.
>
>  This helps that situation, but there's still a possible race. Fixing
>  that will mean adding real locking for nlm_blocked.
>
>  Signed-off-by: Jeff Layton <jlayton@redhat.com>
>  ---
>   fs/lockd/svclock.c |   11 +++++++++++
>   1 files changed, 11 insertions(+), 0 deletions(-)
>
>  diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
>  index 82db7b3..fe9bdb4 100644
>  --- a/fs/lockd/svclock.c
>  +++ b/fs/lockd/svclock.c
>  @@ -795,6 +795,17 @@ static void nlmsvc_grant_callback(struct rpc_task *task, void *data)
>
>         dprintk("lockd: GRANT_MSG RPC callback\n");
>
>  +       /* if the block is not on a list at this point then it has
>  +        * been invalidated. Don't try to requeue it.
>  +        *
>  +        * FIXME: it's possible that the block is removed from the list
>  +        * after this check but before the nlmsvc_insert_block. In that
>  +        * case it will be added back. Perhaps we need better locking
>  +        * for nlm_blocked?
>  +        */
>  +       if (list_empty(&block->b_list))
>  +               return;
>  +
>         /* Technically, we should down the file semaphore here. Since we
>          * move the block towards the head of the queue only, no harm
>          * can be done, though. */
>

Hi Jeff,

Would the following patch take care of this race?  Two questions I have:
1) Does my patch address your FIXME?  I believe it should.
2) Can I get rid of the BKL in nlmsvc_grant_deferred() given this
nlm_blocked serialization?  It is unclear to me if
nlmsvc_grant_deferred() is taking the BKL purely to protect
nlm_blocked.

As an aside, I'm not convinced that the SIGKILL-only assertion you're
making about the block not being on the list is valid considering it
looks to me like there is a race in nlmsvc_lock().

The block isn't added to nlm_blocked until after there is an opening
for the FS to callback via fl_grant().  Whereby causing
nlmsvc_grant_callback() to not find the block on the list.

Mike

------=_Part_3010_31401078.1205524539024
Content-Type: text/x-patch; name=lockd_nlm_blocked_mutex.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fdt61uas
Content-Disposition: attachment; filename=lockd_nlm_blocked_mutex.patch

ZGlmZiAtLWdpdCBhL2ZzL2xvY2tkL3N2Yy5jIGIvZnMvbG9ja2Qvc3ZjLmMKaW5kZXggMWVkOGJk
NC4uNzYxNDQ5OSAxMDA2NDQKLS0tIGEvZnMvbG9ja2Qvc3ZjLmMKKysrIGIvZnMvbG9ja2Qvc3Zj
LmMKQEAgLTEyOCw2ICsxMjgsNyBAQCBsb2NrZChzdHJ1Y3Qgc3ZjX3Jxc3QgKnJxc3RwKQogCS8q
CiAJICogTGV0IG91ciBtYWtlciBrbm93IHdlJ3JlIHJ1bm5pbmcuCiAJICovCisJbmxtc3ZjX2lu
aXQoKTsKIAlubG1zdmNfcGlkID0gY3VycmVudC0+cGlkOwogCW5sbXN2Y19zZXJ2ID0gcnFzdHAt
PnJxX3NlcnZlcjsKIAljb21wbGV0ZSgmbG9ja2Rfc3RhcnRfZG9uZSk7CmRpZmYgLS1naXQgYS9m
cy9sb2NrZC9zdmNsb2NrLmMgYi9mcy9sb2NrZC9zdmNsb2NrLmMKaW5kZXggZmU5YmRiNC4uMzc0
OWMwNiAxMDA2NDQKLS0tIGEvZnMvbG9ja2Qvc3ZjbG9jay5jCisrKyBiL2ZzL2xvY2tkL3N2Y2xv
Y2suYwpAQCAtNTAsMTcgKzUwLDIzIEBAIHN0YXRpYyBjb25zdCBzdHJ1Y3QgcnBjX2NhbGxfb3Bz
IG5sbXN2Y19ncmFudF9vcHM7CiAgKiBUaGUgbGlzdCBvZiBibG9ja2VkIGxvY2tzIHRvIHJldHJ5
CiAgKi8KIHN0YXRpYyBMSVNUX0hFQUQobmxtX2Jsb2NrZWQpOworc3RhdGljIHN0cnVjdCBtdXRl
eCBubG1fYmxvY2tlZF9tdXRleDsKKwordm9pZCBubG1zdmNfaW5pdCh2b2lkKQoreworCW11dGV4
X2luaXQoJm5sbV9ibG9ja2VkX211dGV4KTsKK30KIAogLyoKICAqIEluc2VydCBhIGJsb2NrZWQg
bG9jayBpbnRvIHRoZSBnbG9iYWwgbGlzdAogICovCiBzdGF0aWMgdm9pZAotbmxtc3ZjX2luc2Vy
dF9ibG9jayhzdHJ1Y3QgbmxtX2Jsb2NrICpibG9jaywgdW5zaWduZWQgbG9uZyB3aGVuKQorbmxt
c3ZjX2luc2VydF9ibG9ja19ub2xvY2soc3RydWN0IG5sbV9ibG9jayAqYmxvY2ssIHVuc2lnbmVk
IGxvbmcgd2hlbikKIHsKIAlzdHJ1Y3QgbmxtX2Jsb2NrICpiOwogCXN0cnVjdCBsaXN0X2hlYWQg
KnBvczsKIAotCWRwcmludGsoImxvY2tkOiBubG1zdmNfaW5zZXJ0X2Jsb2NrKCVwLCAlbGQpXG4i
LCBibG9jaywgd2hlbik7CisJZHByaW50aygibG9ja2Q6IG5sbXN2Y19pbnNlcnRfYmxvY2tfbm9s
b2NrKCVwLCAlbGQpXG4iLCBibG9jaywgd2hlbik7CiAJaWYgKGxpc3RfZW1wdHkoJmJsb2NrLT5i
X2xpc3QpKSB7CiAJCWtyZWZfZ2V0KCZibG9jay0+Yl9jb3VudCk7CiAJfSBlbHNlIHsKQEAgLTg1
LDYgKzkxLDE0IEBAIG5sbXN2Y19pbnNlcnRfYmxvY2soc3RydWN0IG5sbV9ibG9jayAqYmxvY2ss
IHVuc2lnbmVkIGxvbmcgd2hlbikKIAlibG9jay0+Yl93aGVuID0gd2hlbjsKIH0KIAorc3RhdGlj
IHZvaWQKK25sbXN2Y19pbnNlcnRfYmxvY2soc3RydWN0IG5sbV9ibG9jayAqYmxvY2ssIHVuc2ln
bmVkIGxvbmcgd2hlbikKK3sKKwltdXRleF9sb2NrKCZubG1fYmxvY2tlZF9tdXRleCk7CisJbmxt
c3ZjX2luc2VydF9ibG9ja19ub2xvY2soYmxvY2ssIHdoZW4pOworCW11dGV4X3VubG9jaygmbmxt
X2Jsb2NrZWRfbXV0ZXgpOworfQorCiAvKgogICogUmVtb3ZlIGEgYmxvY2sgZnJvbSB0aGUgZ2xv
YmFsIGxpc3QKICAqLwpAQCAtOTIsNyArMTA2LDkgQEAgc3RhdGljIGlubGluZSB2b2lkCiBubG1z
dmNfcmVtb3ZlX2Jsb2NrKHN0cnVjdCBubG1fYmxvY2sgKmJsb2NrKQogewogCWlmICghbGlzdF9l
bXB0eSgmYmxvY2stPmJfbGlzdCkpIHsKKwkJbXV0ZXhfbG9jaygmbmxtX2Jsb2NrZWRfbXV0ZXgp
OwogCQlsaXN0X2RlbF9pbml0KCZibG9jay0+Yl9saXN0KTsKKwkJbXV0ZXhfdW5sb2NrKCZubG1f
YmxvY2tlZF9tdXRleCk7CiAJCW5sbXN2Y19yZWxlYXNlX2Jsb2NrKGJsb2NrKTsKIAl9CiB9CkBA
IC0xMTAsNiArMTI2LDggQEAgbmxtc3ZjX2xvb2t1cF9ibG9jayhzdHJ1Y3QgbmxtX2ZpbGUgKmZp
bGUsIHN0cnVjdCBubG1fbG9jayAqbG9jaykKIAkJCQlmaWxlLCBsb2NrLT5mbC5mbF9waWQsCiAJ
CQkJKGxvbmcgbG9uZylsb2NrLT5mbC5mbF9zdGFydCwKIAkJCQkobG9uZyBsb25nKWxvY2stPmZs
LmZsX2VuZCwgbG9jay0+ZmwuZmxfdHlwZSk7CisKKwltdXRleF9sb2NrKCZubG1fYmxvY2tlZF9t
dXRleCk7CiAJbGlzdF9mb3JfZWFjaF9lbnRyeShibG9jaywgJm5sbV9ibG9ja2VkLCBiX2xpc3Qp
IHsKIAkJZmwgPSAmYmxvY2stPmJfY2FsbC0+YV9hcmdzLmxvY2suZmw7CiAJCWRwcmludGsoImxv
Y2tkOiBjaGVjayBmPSVwIHBkPSVkICVMZC0lTGQgdHk9JWQgY29va2llPSVzXG4iLApAQCAtMTE5
LDkgKzEzNywxMSBAQCBubG1zdmNfbG9va3VwX2Jsb2NrKHN0cnVjdCBubG1fZmlsZSAqZmlsZSwg
c3RydWN0IG5sbV9sb2NrICpsb2NrKQogCQkJCW5sbWRiZ19jb29raWUyYSgmYmxvY2stPmJfY2Fs
bC0+YV9hcmdzLmNvb2tpZSkpOwogCQlpZiAoYmxvY2stPmJfZmlsZSA9PSBmaWxlICYmIG5sbV9j
b21wYXJlX2xvY2tzKGZsLCAmbG9jay0+ZmwpKSB7CiAJCQlrcmVmX2dldCgmYmxvY2stPmJfY291
bnQpOworCQkJbXV0ZXhfdW5sb2NrKCZubG1fYmxvY2tlZF9tdXRleCk7CiAJCQlyZXR1cm4gYmxv
Y2s7CiAJCX0KIAl9CisJbXV0ZXhfdW5sb2NrKCZubG1fYmxvY2tlZF9tdXRleCk7CiAKIAlyZXR1
cm4gTlVMTDsKIH0KQEAgLTE0MywxMSArMTYzLDE0IEBAIG5sbXN2Y19maW5kX2Jsb2NrKHN0cnVj
dCBubG1fY29va2llICpjb29raWUpCiB7CiAJc3RydWN0IG5sbV9ibG9jayAqYmxvY2s7CiAKKwlt
dXRleF9sb2NrKCZubG1fYmxvY2tlZF9tdXRleCk7CiAJbGlzdF9mb3JfZWFjaF9lbnRyeShibG9j
aywgJm5sbV9ibG9ja2VkLCBiX2xpc3QpIHsKLQkJaWYgKG5sbV9jb29raWVfbWF0Y2goJmJsb2Nr
LT5iX2NhbGwtPmFfYXJncy5jb29raWUsY29va2llKSkKKwkJaWYgKG5sbV9jb29raWVfbWF0Y2go
JmJsb2NrLT5iX2NhbGwtPmFfYXJncy5jb29raWUsY29va2llKSl7CisJCQltdXRleF91bmxvY2so
Jm5sbV9ibG9ja2VkX211dGV4KTsKIAkJCWdvdG8gZm91bmQ7CisgICAgICAgICAgICAgICAgfQog
CX0KLQorCW11dGV4X3VubG9jaygmbmxtX2Jsb2NrZWRfbXV0ZXgpOwogCXJldHVybiBOVUxMOwog
CiBmb3VuZDoKQEAgLTY0Myw2ICs2NjYsOCBAQCBzdGF0aWMgaW50IG5sbXN2Y19ncmFudF9kZWZl
cnJlZChzdHJ1Y3QgZmlsZV9sb2NrICpmbCwgc3RydWN0IGZpbGVfbG9jayAqY29uZiwKIAlpbnQg
cmMgPSAtRU5PRU5UOwogCiAJbG9ja19rZXJuZWwoKTsKKwkvKiBUT0RPOiB3aXRoIG5sbV9ibG9j
a2VkX211dGV4IGlzIHRoZSBCS0wgbm8gbG9uZ2VyIG5lZWRlZD8gKi8KKwltdXRleF9sb2NrKCZu
bG1fYmxvY2tlZF9tdXRleCk7CiAJbGlzdF9mb3JfZWFjaF9lbnRyeShibG9jaywgJm5sbV9ibG9j
a2VkLCBiX2xpc3QpIHsKIAkJaWYgKG5sbV9jb21wYXJlX2xvY2tzKCZibG9jay0+Yl9jYWxsLT5h
X2FyZ3MubG9jay5mbCwgZmwpKSB7CiAJCQlkcHJpbnRrKCJsb2NrZDogbmxtc3ZjX25vdGlmeV9i
bG9ja2VkIGJsb2NrICVwIGZsYWdzICVkXG4iLApAQCAtNjU2LDEyICs2ODEsMTMgQEAgc3RhdGlj
IGludCBubG1zdmNfZ3JhbnRfZGVmZXJyZWQoc3RydWN0IGZpbGVfbG9jayAqZmwsIHN0cnVjdCBm
aWxlX2xvY2sgKmNvbmYsCiAJCQl9IGVsc2UgaWYgKHJlc3VsdCA9PSAwKQogCQkJCWJsb2NrLT5i
X2dyYW50ZWQgPSAxOwogCi0JCQlubG1zdmNfaW5zZXJ0X2Jsb2NrKGJsb2NrLCAwKTsKKwkJCW5s
bXN2Y19pbnNlcnRfYmxvY2tfbm9sb2NrKGJsb2NrLCAwKTsKIAkJCXN2Y193YWtlX3VwKGJsb2Nr
LT5iX2RhZW1vbik7CiAJCQlyYyA9IDA7CiAJCQlicmVhazsKIAkJfQogCX0KKwltdXRleF91bmxv
Y2soJm5sbV9ibG9ja2VkX211dGV4KTsKIAl1bmxvY2tfa2VybmVsKCk7CiAJaWYgKHJjID09IC1F
Tk9FTlQpCiAJCXByaW50ayhLRVJOX1dBUk5JTkcgImxvY2tkOiBncmFudCBmb3IgdW5rbm93biBi
bG9ja1xuIik7CkBAIC02ODEsMTQgKzcwNywxNSBAQCBubG1zdmNfbm90aWZ5X2Jsb2NrZWQoc3Ry
dWN0IGZpbGVfbG9jayAqZmwpCiAJc3RydWN0IG5sbV9ibG9jawkqYmxvY2s7CiAKIAlkcHJpbnRr
KCJsb2NrZDogVkZTIHVuYmxvY2sgbm90aWZpY2F0aW9uIGZvciBibG9jayAlcFxuIiwgZmwpOwor
CW11dGV4X2xvY2soJm5sbV9ibG9ja2VkX211dGV4KTsKIAlsaXN0X2Zvcl9lYWNoX2VudHJ5KGJs
b2NrLCAmbmxtX2Jsb2NrZWQsIGJfbGlzdCkgewogCQlpZiAobmxtX2NvbXBhcmVfbG9ja3MoJmJs
b2NrLT5iX2NhbGwtPmFfYXJncy5sb2NrLmZsLCBmbCkpIHsKLQkJCW5sbXN2Y19pbnNlcnRfYmxv
Y2soYmxvY2ssIDApOworCQkJbmxtc3ZjX2luc2VydF9ibG9ja19ub2xvY2soYmxvY2ssIDApOwog
CQkJc3ZjX3dha2VfdXAoYmxvY2stPmJfZGFlbW9uKTsKIAkJCXJldHVybjsKIAkJfQogCX0KLQor
CW11dGV4X3VubG9jaygmbmxtX2Jsb2NrZWRfbXV0ZXgpOwogCXByaW50ayhLRVJOX1dBUk5JTkcg
ImxvY2tkOiBub3RpZmljYXRpb24gZm9yIHVua25vd24gYmxvY2shXG4iKTsKIH0KIApkaWZmIC0t
Z2l0IGEvaW5jbHVkZS9saW51eC9sb2NrZC9sb2NrZC5oIGIvaW5jbHVkZS9saW51eC9sb2NrZC9s
b2NrZC5oCmluZGV4IDRiYWJiMmEuLjY2N2Q3OTEgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgv
bG9ja2QvbG9ja2QuaAorKysgYi9pbmNsdWRlL2xpbnV4L2xvY2tkL2xvY2tkLmgKQEAgLTIwNiw2
ICsyMDYsNyBAQCB1bnNpZ25lZCBsb25nCSAgbmxtc3ZjX3JldHJ5X2Jsb2NrZWQodm9pZCk7CiB2
b2lkCQkgIG5sbXN2Y190cmF2ZXJzZV9ibG9ja3Moc3RydWN0IG5sbV9ob3N0ICosIHN0cnVjdCBu
bG1fZmlsZSAqLAogCQkJCQlubG1faG9zdF9tYXRjaF9mbl90IG1hdGNoKTsKIHZvaWQJCSAgbmxt
c3ZjX2dyYW50X3JlcGx5KHN0cnVjdCBubG1fY29va2llICosIF9fYmUzMik7Cit2b2lkCQkgIG5s
bXN2Y19pbml0KHZvaWQpOwogCiAvKgogICogRmlsZSBoYW5kbGluZyBmb3IgdGhlIHNlcnZlciBw
ZXJzb25hbGl0eQo=
------=_Part_3010_31401078.1205524539024--
