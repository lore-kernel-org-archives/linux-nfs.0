Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55875 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab1I0Efb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Sep 2011 00:35:31 -0400
Received: by wyg34 with SMTP id 34so6709251wyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 21:35:30 -0700 (PDT)
In-Reply-To: <1317097001.3176.20.camel@perseus.themaw.net>
References: <CA+55aFyd3QB-vfp9Vm6S6_YRCXO9pNE2YavYZhmO+5g6YfdERA@mail.gmail.com>
 <1316747758.3346.89.camel@perseus.themaw.net> <20110922134510.24683.14576.stgit@warthog.procyon.org.uk>
 <1316707443.3346.44.camel@perseus.themaw.net> <CA+55aFxGxv5DGAQcgn1avwUcW1xZVvz1VEajF6zT5HHiVEsJ2w@mail.gmail.com>
 <1316709935.3346.48.camel@perseus.themaw.net> <20110922133529.6d3ea8de@barsoom.rdu.redhat.com>
 <20110922144453.6cf53a25@barsoom.rdu.redhat.com> <1316719228.3968.14.camel@lade.trondhjem.org>
 <CA+55aFxEAZG2dz3X44OUDqmqv8P-6AJ-eiKVBGfC5+=3C_c+1A@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B480BD4@SACMVEXC2-PRD.hq.netapp.com>
 <CA+55aFx9XbKV7xNR-Vs7NhyDE=vmX7Zr=U2YB=omvcae_ye9XQ@mail.gmail.com>
 <21772.1316774025@redhat.com> <1316788444.14812.10.camel@lade.trondhjem.org>
 <29743.1316791138@redhat.com> <87hb43tf2g.fsf@tucsk.pomaz.szeredi.hu>
 <1316827854.3346.154.camel@perseus.themaw.net> <CA+55aFwPEq5B_P0RtX+pBtGfTadzzS+3U=k=3XTjDw3soNhOdA@mail.gmail.com>
 <20110924073610.4b045189@tlielax.poochiereds.net> <CA+55aFxjFXbCKBZNfBuCOaiBHRQ=ZECnhqKxjPw9maPgyRLiDA@mail.gmail.com>
 <1317013864.3187.81.camel@perseus.themaw.net> <CA+55aFzJnKCHtsiH-mZOwQgVt1ajPJQHWRYB_19eXEKaGRPD1w@mail.gmail.com>
 <1317071626.19951.8.camel@lade.trondhjem.org> <CA+55aFzWCZQjWMcxg16yMUoLr-mEPuXzAFgv49LU4hCn+=rbwQ@mail.gmail.com>
 <1317072718.19951.13.camel@lade.trondhjem.org> <CA+55aFzaScGiKmsSrgXivoUPw4xHjKobsB4VquuEu1fG=7R+wA@mail.gmail.com>
 <1317076424.19951.32.camel@lade.trondhjem.org> <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
 <1317078563.21770.8.camel@lade.trondhjem.org> <CA+55aFzX+DyU7xhAmTLq0g_z6jyKuqoiyPdCYO+w2Xk7pECrqg@mail.gmail.com>
 <1317085155.21770.17.camel@lade.trondhjem.org> <CA+55aFxuaJ-a5u79D2pELU4HbWTrbWjG_4BNcvFqEOcM0H8G2Q@mail.gmail.com>
 <1317097001.3176.20.camel@perseus.themaw.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2011 21:35:09 -0700
Message-ID: <CA+55aFyzxvJJgOkojvV-83ejNtQnXeRnXerwzWRdwFgPF_yMhg@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Ian Kent <raven@themaw.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Jeff Layton <jlayton@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: multipart/mixed; boundary=0016e6d58a732e46fa04ade4ce67
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--0016e6d58a732e46fa04ade4ce67
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Sep 26, 2011 at 9:16 PM, Ian Kent <raven@themaw.net> wrote:
>
> This case is the one were there is no existing directory yet for the
> automount (it's the age old original automount case where mount point
> directories never existed within the automount managed directory before
> being automounted). In this case we always want to automount regardless
> of the lookup flags. So returning -EISDIR should be conditional on also
> having a positive dentry.

Ok. This all just makes me more conviced that the LOOKUP_NO_AUTOMOUNT
code is not even worth trying to salvage (ie not play any games with
the existing AT_NO_AUTOMOUNT flag and perhaps turning
!AT_SYMLINK_NOFOLLOW + !AT_NOAUTOMOUNT -> LOOKUP_AUTOMOUNT). That's
the case that never tested for d_inode being NULL, so it got the
autofs case wrong.

At some point we might want to expose an AT_AUTOMOUNT flag to user
space _if_ it turns out that glibc or somebody wants really wants it,
but the old flag clearly actually had a buggy implementation and
almost certainly isn't worth worrying about.

Of course, we'll have to see if there are any actual regression
reports in this area.. If something actually breaks, we may not have
all that many choices. But at least tentatively, I think we can plan
on applying the attached cleanup to just rip that out (it's already
effectively dead code apart from the buggy lack of d_inode testing,
since apart from d_inode, it never triggers unless the subsequent test
triggers)..

                           Linus

--0016e6d58a732e46fa04ade4ce67
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gt2e3kwt0

IGZzL25hbWVpLmMgICAgICAgICAgICB8ICAgIDYgLS0tLS0tCiBmcy9zdGF0LmMgICAgICAgICAg
ICAgfCAgICAyIC0tCiBpbmNsdWRlL2xpbnV4L25hbWVpLmggfCAgICAyICstCiAzIGZpbGVzIGNo
YW5nZWQsIDEgaW5zZXJ0aW9ucygrKSwgOSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9mcy9u
YW1laS5jIGIvZnMvbmFtZWkuYwppbmRleCAwOTYwNmZkODNkNTcuLjBiMzEzOGRlMmEzYiAxMDA2
NDQKLS0tIGEvZnMvbmFtZWkuYworKysgYi9mcy9uYW1laS5jCkBAIC03MjEsMTIgKzcyMSw2IEBA
IHN0YXRpYyBpbnQgZm9sbG93X2F1dG9tb3VudChzdHJ1Y3QgcGF0aCAqcGF0aCwgdW5zaWduZWQg
ZmxhZ3MsCiAJaWYgKCFwYXRoLT5kZW50cnktPmRfb3AgfHwgIXBhdGgtPmRlbnRyeS0+ZF9vcC0+
ZF9hdXRvbW91bnQpCiAJCXJldHVybiAtRVJFTU9URTsKIAotCS8qIFdlIGRvbid0IHdhbnQgdG8g
bW91bnQgaWYgc29tZW9uZSBzdXBwbGllZCBBVF9OT19BVVRPTU9VTlQKLQkgKiBhbmQgdGhpcyBp
cyB0aGUgdGVybWluYWwgcGFydCBvZiB0aGUgcGF0aC4KLQkgKi8KLQlpZiAoKGZsYWdzICYgTE9P
S1VQX05PX0FVVE9NT1VOVCkgJiYgIShmbGFncyAmIExPT0tVUF9QQVJFTlQpKQotCQlyZXR1cm4g
LUVJU0RJUjsgLyogd2UgYWN0dWFsbHkgd2FudCB0byBzdG9wIGhlcmUgKi8KLQogCS8qIFdlIGRv
bid0IHdhbnQgdG8gbW91bnQgaWYgc29tZW9uZSdzIGp1c3QgZG9pbmcgYSBzdGF0IC0KIAkgKiB1
bmxlc3MgdGhleSdyZSBzdGF0J2luZyBhIGRpcmVjdG9yeSBhbmQgYXBwZW5kZWQgYSAnLycgdG8K
IAkgKiB0aGUgbmFtZS4KZGlmZiAtLWdpdCBhL2ZzL3N0YXQuYyBiL2ZzL3N0YXQuYwppbmRleCBi
YTUzMTZmZmFjNjEuLjc4YTNhYTgzYzdlYSAxMDA2NDQKLS0tIGEvZnMvc3RhdC5jCisrKyBiL2Zz
L3N0YXQuYwpAQCAtODEsOCArODEsNiBAQCBpbnQgdmZzX2ZzdGF0YXQoaW50IGRmZCwgY29uc3Qg
Y2hhciBfX3VzZXIgKmZpbGVuYW1lLCBzdHJ1Y3Qga3N0YXQgKnN0YXQsCiAKIAlpZiAoIShmbGFn
ICYgQVRfU1lNTElOS19OT0ZPTExPVykpCiAJCWxvb2t1cF9mbGFncyB8PSBMT09LVVBfRk9MTE9X
OwotCWlmIChmbGFnICYgQVRfTk9fQVVUT01PVU5UKQotCQlsb29rdXBfZmxhZ3MgfD0gTE9PS1VQ
X05PX0FVVE9NT1VOVDsKIAlpZiAoZmxhZyAmIEFUX0VNUFRZX1BBVEgpCiAJCWxvb2t1cF9mbGFn
cyB8PSBMT09LVVBfRU1QVFk7CiAKZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvbmFtZWkuaCBi
L2luY2x1ZGUvbGludXgvbmFtZWkuaAppbmRleCBlMTNkYWM3Y2FhYjIuLjQwOTMyOGQxY2JiYiAx
MDA2NDQKLS0tIGEvaW5jbHVkZS9saW51eC9uYW1laS5oCisrKyBiL2luY2x1ZGUvbGludXgvbmFt
ZWkuaApAQCAtNTMsNyArNTMsNyBAQCBlbnVtIHtMQVNUX05PUk0sIExBU1RfUk9PVCwgTEFTVF9E
T1QsIExBU1RfRE9URE9ULCBMQVNUX0JJTkR9OwogI2RlZmluZSBMT09LVVBfUEFSRU5UCQkweDAw
MTAKICNkZWZpbmUgTE9PS1VQX1JFVkFMCQkweDAwMjAKICNkZWZpbmUgTE9PS1VQX1JDVQkJMHgw
MDQwCi0jZGVmaW5lIExPT0tVUF9OT19BVVRPTU9VTlQJMHgwMDgwCisKIC8qCiAgKiBJbnRlbnQg
ZGF0YQogICovCg==

--0016e6d58a732e46fa04ade4ce67--
