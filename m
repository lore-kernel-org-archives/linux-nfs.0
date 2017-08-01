Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:37721 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbdHARUd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 13:20:33 -0400
MIME-Version: 1.0
In-Reply-To: <20170801155131.xy7nbw5ih7ml5fmf@codemonkey.org.uk>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
 <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk> <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
 <1500245845.13893.3.camel@primarydata.com> <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
 <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
 <20170731154322.tfzkukscda4fe7wm@codemonkey.org.uk> <CA+55aFwwkc-YJ8WQzE6Ax3BAJ3XXR8fhN+0AEH_U8TtcQn7opg@mail.gmail.com>
 <20170801155131.xy7nbw5ih7ml5fmf@codemonkey.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 1 Aug 2017 10:20:31 -0700
Message-ID: <CA+55aFyQdHt0qYQ0uBSK+9wfPOyFfx8mJE4r9FfWoxa3Gyei9g@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
To: "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>,
        Trond Myklebust <trondmy@primarydata.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Type: multipart/mixed; boundary="001a113cddac5b7af10555b45d8c"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--001a113cddac5b7af10555b45d8c
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 1, 2017 at 8:51 AM, davej@codemonkey.org.uk
<davej@codemonkey.org.uk> wrote:
> On Mon, Jul 31, 2017 at 10:35:45PM -0700, Linus Torvalds wrote:
>  > Any chance of getting the output from
>  >
>  >    ./scripts/faddr2line vmlinux nfs4_exchange_id_done+0x3d7/0x8e0
>
>
> Hm, that points to this..
>
> 7463                 /* Save the EXCHANGE_ID verifier session trunk tests */
> 7464                 memcpy(clp->cl_confirm.data, cdata->args.verifier->data,
> 7465                        sizeof(clp->cl_confirm.data));

Ok, that certainly made no sense to me, because the KASAN report made
it look like a stale pathname access (allocated in getname, freed in
putname), but I think the issue is more fundamental than that.

That cdata->args.verifier seems to be entirely broken. AT least for
the "xprt == NULL" case, it does the following:

 - use the address of a local variable ("&verifier")

 - wait for the rpc completion using rpc_wait_for_completion_task().

That's unacceptably buggy crap. rpc_wait_for_completion_task() will
happily exit on a deadly signal even if the rpc hasn't been completed,
so now you'll have a stale pointer to a stack that has been freed.

So I think the 'pathname' part may actually be entirely a red herring,
and it's the underlying access itself that just picks up a random
pointer from a stack that now contains something different. And KASAN
didn't notice the stale stack access itself, because the stack slot is
still valid - it's just no longer the original 'verifier' allocation.

Or *something* like that.

None of this looks even remotely new, though - the code seems to go
back to 2009. Have you just changed what you're testing to trigger
these things?

I'm not even sure why it does that stupid stack allocation. It does a
*real* allocation just a few lines later:

        struct nfs41_exchange_id_data *calldata
        ...
        calldata = kzalloc(sizeof(*calldata), GFP_NOFS);

and the whole verifier structure could easily have been part of that
same allocation as far as I can tell.

And that really might seem to be the right thing to do.

TOTALLY UNTESTED PROBABLY COMPLETE CRAP patch attatched.

That patch compiles for me. It *might* even work. Or it might just be
the ramblings of a diseased mind.

Anna? Trond?

So caveat probatorem,

              Linus

--001a113cddac5b7af10555b45d8c
Content-Type: text/plain; charset="US-ASCII"; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_j5tujz6x0

IGZzL25mcy9uZnM0cHJvYy5jIHwgMTkgKysrKysrKysrKysrKystLS0tLQogMSBmaWxlIGNoYW5n
ZWQsIDE0IGluc2VydGlvbnMoKyksIDUgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZnMvbmZz
L25mczRwcm9jLmMgYi9mcy9uZnMvbmZzNHByb2MuYwppbmRleCAxOGNhNjg3OWQ4ZGUuLjA3MTJh
ZjNkMzhmOCAxMDA2NDQKLS0tIGEvZnMvbmZzL25mczRwcm9jLmMKKysrIGIvZnMvbmZzL25mczRw
cm9jLmMKQEAgLTc0OTAsNiArNzQ5MCwxMSBAQCBzdGF0aWMgY29uc3Qgc3RydWN0IHJwY19jYWxs
X29wcyBuZnM0X2V4Y2hhbmdlX2lkX2NhbGxfb3BzID0gewogCS5ycGNfcmVsZWFzZSA9IG5mczRf
ZXhjaGFuZ2VfaWRfcmVsZWFzZSwKIH07CiAKK3N0cnVjdCB2ZXJpZmllcl9hbmRfY2FsbGRhdGEg
eworCXN0cnVjdCBuZnM0MV9leGNoYW5nZV9pZF9kYXRhIGNhbGxkYXRhOworCW5mczRfdmVyaWZp
ZXIgdmVyaWZpZXI7Cit9OworCiAvKgogICogX25mczRfcHJvY19leGNoYW5nZV9pZCgpCiAgKgpA
QCAtNzQ5OCw3ICs3NTAzLDggQEAgc3RhdGljIGNvbnN0IHN0cnVjdCBycGNfY2FsbF9vcHMgbmZz
NF9leGNoYW5nZV9pZF9jYWxsX29wcyA9IHsKIHN0YXRpYyBpbnQgX25mczRfcHJvY19leGNoYW5n
ZV9pZChzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwLCBzdHJ1Y3QgcnBjX2NyZWQgKmNyZWQsCiAJCQl1
MzIgc3A0X2hvdywgc3RydWN0IHJwY194cHJ0ICp4cHJ0KQogewotCW5mczRfdmVyaWZpZXIgdmVy
aWZpZXI7CisJc3RydWN0IHZlcmlmaWVyX2FuZF9jYWxsZGF0YSAqdm5hOworCW5mczRfdmVyaWZp
ZXIgKnZlcmlmaWVyOwogCXN0cnVjdCBycGNfbWVzc2FnZSBtc2cgPSB7CiAJCS5ycGNfcHJvYyA9
ICZuZnM0X3Byb2NlZHVyZXNbTkZTUFJPQzRfQ0xOVF9FWENIQU5HRV9JRF0sCiAJCS5ycGNfY3Jl
ZCA9IGNyZWQsCkBAIC03NTE2LDE0ICs3NTIyLDE3IEBAIHN0YXRpYyBpbnQgX25mczRfcHJvY19l
eGNoYW5nZV9pZChzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwLCBzdHJ1Y3QgcnBjX2NyZWQgKmNyZWQs
CiAJaWYgKCFhdG9taWNfaW5jX25vdF96ZXJvKCZjbHAtPmNsX2NvdW50KSkKIAkJcmV0dXJuIC1F
SU87CiAKLQljYWxsZGF0YSA9IGt6YWxsb2Moc2l6ZW9mKCpjYWxsZGF0YSksIEdGUF9OT0ZTKTsK
LQlpZiAoIWNhbGxkYXRhKSB7CisJdm5hID0ga3phbGxvYyhzaXplb2YoKnZuYSksIEdGUF9OT0ZT
KTsKKwlpZiAoIXZuYSkgewogCQluZnNfcHV0X2NsaWVudChjbHApOwogCQlyZXR1cm4gLUVOT01F
TTsKIAl9CisJLyoga2ZyZWUoKSBvZiBjYWxsZGF0YSB3aWxsIGFsc28gZnJlZSB0aGUgdmVyaWZp
ZXIgKi8KKwljYWxsZGF0YSA9ICZ2bmEtPmNhbGxkYXRhOworCXZlcmlmaWVyID0gJnZuYS0+dmVy
aWZpZXI7CiAKIAlpZiAoIXhwcnQpCi0JCW5mczRfaW5pdF9ib290X3ZlcmlmaWVyKGNscCwgJnZl
cmlmaWVyKTsKKwkJbmZzNF9pbml0X2Jvb3RfdmVyaWZpZXIoY2xwLCB2ZXJpZmllcik7CiAKIAlz
dGF0dXMgPSBuZnM0X2luaXRfdW5pZm9ybV9jbGllbnRfc3RyaW5nKGNscCk7CiAJaWYgKHN0YXR1
cykKQEAgLTc1NjYsNyArNzU3NSw3IEBAIHN0YXRpYyBpbnQgX25mczRfcHJvY19leGNoYW5nZV9p
ZChzdHJ1Y3QgbmZzX2NsaWVudCAqY2xwLCBzdHJ1Y3QgcnBjX2NyZWQgKmNyZWQsCiAJCQkJUlBD
X1RBU0tfU09GVHxSUENfVEFTS19TT0ZUQ09OTnxSUENfVEFTS19BU1lOQzsKIAkJY2FsbGRhdGEt
PmFyZ3MudmVyaWZpZXIgPSAmY2xwLT5jbF9jb25maXJtOwogCX0gZWxzZSB7Ci0JCWNhbGxkYXRh
LT5hcmdzLnZlcmlmaWVyID0gJnZlcmlmaWVyOworCQljYWxsZGF0YS0+YXJncy52ZXJpZmllciA9
IHZlcmlmaWVyOwogCX0KIAljYWxsZGF0YS0+YXJncy5jbGllbnQgPSBjbHA7CiAjaWZkZWYgQ09O
RklHX05GU19WNF8xX01JR1JBVElPTgo=
--001a113cddac5b7af10555b45d8c--
