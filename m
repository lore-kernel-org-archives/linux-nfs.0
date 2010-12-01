Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:39099 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab0LATAn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 14:00:43 -0500
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Trond.Myklebust@netapp.com, nbowler@elliptictech.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        akpm@linux-foundation.org, hughd@google.com, riel@redhat.com,
        hch@lst.de, viro@zeniv.linux.org.uk
In-reply-to: <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
	(message from Linus Torvalds on Wed, 1 Dec 2010 08:17:38 -0800)
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
 <20101201150428.GA2879@elliptictech.com> <1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
 <1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com> <AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
Message-Id: <E1PNrQc-0005zr-7B@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 01 Dec 2010 19:29:18 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

On Wed, 1 Dec 2010, Linus Torvalds wrote:
> --00032557542a0c5e6004965ba615
> Content-Type: text/plain; charset=ISO-8859-1
> 
> On Wed, Dec 1, 2010 at 7:36 AM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> >
> > We need to ensure that the entries in the nfs_cache_array get cleared
> > when the page is removed from the page cache. To do so, we use the
> > releasepage address_space operation (which also requires us to set
> > the Pg_private flag).
> 
> So I really think that the whole "releasepage" use in NFS is simply
> overly complicated and was obviously too subtle.
> 
> The whole need for odd return values, for the page lock, and for the
> addition of clearing the up-to-date bit comes from the fact that this
> wasn't really what releasepage was designed for.
> 
> 'releasepage' was really designed for the filesystem having its own
> version of 'try_to_free_buffers()', which is just an optimistic "ok,
> we may be releasing this page, so try to get rid of any IO structures
> you have cached". It wasn't really a memory management thing.
> 
> And the thing is, it looks trivial to do the memory management
> approach by adding a new callback that gets called after the page is
> actually removed from the page cache. If we do that, then there are no
> races with any other users, since we remove things from the page cache
> atomically wrt page cache lookup. So the need for playing games with
> page locking and 'uptodate' simply goes away. As does the PG_private
> thing or the interaction with invalidatepage() etc.
> 
> So this is a TOTALLY UNTESTED trivial patch that just adds another
> callback. Does this work? I dunno. But I get the feeling that instead
> of having NFS work around the odd semantics that don't actually match
> what NFS wants, introducing a new callback with much simpler semantics
> would be simpler for everybody, and avoid the need for subtle code.
> 
> Hmm?
> 
>                    Linus
> 
> --00032557542a0c5e6004965ba615
> Content-Type: text/x-patch; charset=US-ASCII; name="patch.diff"
> Content-Disposition: attachment; filename="patch.diff"
> Content-Transfer-Encoding: base64
> X-Attachment-Id: f_gh6f5ghm0
> 
> IGluY2x1ZGUvbGludXgvZnMuaCB8ICAgIDEgKwogbW0vdm1zY2FuLmMgICAgICAgIHwgICAgMyAr
> KysKIDIgZmlsZXMgY2hhbmdlZCwgNCBpbnNlcnRpb25zKCspLCAwIGRlbGV0aW9ucygtKQoKZGlm
> ZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvZnMuaCBiL2luY2x1ZGUvbGludXgvZnMuaAppbmRleCBj
> OWUwNmNjLi4wOTBmMGVhIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L2ZzLmgKKysrIGIvaW5j
> bHVkZS9saW51eC9mcy5oCkBAIC02MDIsNiArNjAyLDcgQEAgc3RydWN0IGFkZHJlc3Nfc3BhY2Vf
> b3BlcmF0aW9ucyB7CiAJc2VjdG9yX3QgKCpibWFwKShzdHJ1Y3QgYWRkcmVzc19zcGFjZSAqLCBz
> ZWN0b3JfdCk7CiAJdm9pZCAoKmludmFsaWRhdGVwYWdlKSAoc3RydWN0IHBhZ2UgKiwgdW5zaWdu
> ZWQgbG9uZyk7CiAJaW50ICgqcmVsZWFzZXBhZ2UpIChzdHJ1Y3QgcGFnZSAqLCBnZnBfdCk7CisJ
> dm9pZCAoKmZyZWVwYWdlKShzdHJ1Y3QgcGFnZSAqKTsKIAlzc2l6ZV90ICgqZGlyZWN0X0lPKShp
> bnQsIHN0cnVjdCBraW9jYiAqLCBjb25zdCBzdHJ1Y3QgaW92ZWMgKmlvdiwKIAkJCWxvZmZfdCBv
> ZmZzZXQsIHVuc2lnbmVkIGxvbmcgbnJfc2Vncyk7CiAJaW50ICgqZ2V0X3hpcF9tZW0pKHN0cnVj
> dCBhZGRyZXNzX3NwYWNlICosIHBnb2ZmX3QsIGludCwKZGlmZiAtLWdpdCBhL21tL3Ztc2Nhbi5j
> IGIvbW0vdm1zY2FuLmMKaW5kZXggZDMxZDdjZS4uMWFjY2IwMSAxMDA2NDQKLS0tIGEvbW0vdm1z
> Y2FuLmMKKysrIGIvbW0vdm1zY2FuLmMKQEAgLTQ5OSw2ICs0OTksOSBAQCBzdGF0aWMgaW50IF9f
> cmVtb3ZlX21hcHBpbmcoc3RydWN0IGFkZHJlc3Nfc3BhY2UgKm1hcHBpbmcsIHN0cnVjdCBwYWdl
> ICpwYWdlKQogCQltZW1fY2dyb3VwX3VuY2hhcmdlX2NhY2hlX3BhZ2UocGFnZSk7CiAJfQogCisJ
> aWYgKG1hcHBpbmctPmFfb3BzLT5mcmVlcGFnZSkKKwkJbWFwcGluZy0+YV9vcHMtPmZyZWVwYWdl
> KHBhZ2UpOworCiAJcmV0dXJuIDE7CiAKIGNhbm5vdF9mcmVlOgo=
> --00032557542a0c5e6004965ba615--

This violates the "Really. Don't send patches as attachments."
lkml-faq set forth by yourself ;)

Am I the only one who still uses a mail reader that doesn't decode
mime by default?  Maybe it's time to move on...

Thanks,
Miklos
