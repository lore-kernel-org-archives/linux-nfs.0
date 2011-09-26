Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34591 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752114Ab1IZW4W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 18:56:22 -0400
Received: by wyg34 with SMTP id 34so6423035wyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 15:56:21 -0700 (PDT)
In-Reply-To: <1317076424.19951.32.camel@lade.trondhjem.org>
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
 <1317076424.19951.32.camel@lade.trondhjem.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 26 Sep 2011 15:56:01 -0700
Message-ID: <CA+55aFzi+0Z6HXJCxW=Uc1EZsp4qA00i+ihNcSX_v6bVTbU2BA@mail.gmail.com>
Subject: Re: [PATCH] VFS: Suppress automount on [l]stat, [l]getxattr, etc.
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Ian Kent <raven@themaw.net>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        David Howells <dhowells@redhat.com>, viro@zeniv.linux.org.uk,
        gregkh@suse.de, linux-nfs@vger.kernel.org, leonardo.lists@gmail.com
Content-Type: multipart/mixed; boundary=0016364c757048ffeb04ade01152
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--0016364c757048ffeb04ade01152
Content-Type: text/plain; charset=ISO-8859-1

On Mon, Sep 26, 2011 at 3:33 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
>
> Lookup permission checks would be replaced with open permission checks
> on the server.
>
> IOW: the operation could potentially fail due to a completely unrelated
> issue.

Quite frankly, that still sounds like a "I'm trying to make a problem
out of something that isn't actually a problem". And you still seem to
be unwilling to admit that LOOKUP_FOLLOW is a problem that has
actually been reported in real life, so you just cut out that part of
my question about how this would be a bigger issue.

But whatever. I can't really care, since it's a two-liner to add a new
flag, and then it falls down to "if you want to follow automounts, you
can set that flag instead".

Almost nobody is ever going to bother setting the flag anyway, since
LOOKUP_OPEN and LOOKUP_DIRECTORY are going to take care of all the
common cases.

So here. You can set LOOKUP_AUTOMOUNT to force an automount traversal. Ok?

                       Linus

--0016364c757048ffeb04ade01152
Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
Content-Disposition: attachment; filename="patch.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gt2236bc0

IGZzL25hbWVpLmMgICAgICAgICAgICB8ICAgIDIgKy0KIGluY2x1ZGUvbGludXgvbmFtZWkuaCB8
ICAgIDEgKwogMiBmaWxlcyBjaGFuZ2VkLCAyIGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0p
CgpkaWZmIC0tZ2l0IGEvZnMvbmFtZWkuYyBiL2ZzL25hbWVpLmMKaW5kZXggZjQ3ODgzNjVlYTIy
Li4wOTYwNmZkODNkNTcgMTAwNjQ0Ci0tLSBhL2ZzL25hbWVpLmMKKysrIGIvZnMvbmFtZWkuYwpA
QCAtNzM5LDcgKzczOSw3IEBAIHN0YXRpYyBpbnQgZm9sbG93X2F1dG9tb3VudChzdHJ1Y3QgcGF0
aCAqcGF0aCwgdW5zaWduZWQgZmxhZ3MsCiAJICogb2YgdGhlIGRhZW1vbiB0byBpbnN0YW50aWF0
ZSB0aGVtIGJlZm9yZSB0aGV5IGNhbiBiZSB1c2VkLgogCSAqLwogCWlmICghKGZsYWdzICYgKExP
T0tVUF9QQVJFTlQgfCBMT09LVVBfRElSRUNUT1JZIHwKLQkJICAgICBMT09LVVBfT1BFTiB8IExP
T0tVUF9DUkVBVEUpKSAmJgorCQkgICAgIExPT0tVUF9PUEVOIHwgTE9PS1VQX0NSRUFURSB8IExP
T0tVUF9BVVRPTU9VTlQpKSAmJgogCSAgICBwYXRoLT5kZW50cnktPmRfaW5vZGUpCiAJCXJldHVy
biAtRUlTRElSOwogCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L25hbWVpLmggYi9pbmNsdWRl
L2xpbnV4L25hbWVpLmgKaW5kZXggNzZmZTJjNjJhZTcxLi5lMTNkYWM3Y2FhYjIgMTAwNjQ0Ci0t
LSBhL2luY2x1ZGUvbGludXgvbmFtZWkuaAorKysgYi9pbmNsdWRlL2xpbnV4L25hbWVpLmgKQEAg
LTQ4LDYgKzQ4LDcgQEAgZW51bSB7TEFTVF9OT1JNLCBMQVNUX1JPT1QsIExBU1RfRE9ULCBMQVNU
X0RPVERPVCwgTEFTVF9CSU5EfTsKICAqLwogI2RlZmluZSBMT09LVVBfRk9MTE9XCQkweDAwMDEK
ICNkZWZpbmUgTE9PS1VQX0RJUkVDVE9SWQkweDAwMDIKKyNkZWZpbmUgTE9PS1VQX0FVVE9NT1VO
VAkweDAwMDQKIAogI2RlZmluZSBMT09LVVBfUEFSRU5UCQkweDAwMTAKICNkZWZpbmUgTE9PS1VQ
X1JFVkFMCQkweDAwMjAK

--0016364c757048ffeb04ade01152--
