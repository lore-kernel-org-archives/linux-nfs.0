Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53892 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752742AbdJSUUR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Oct 2017 16:20:17 -0400
Date: Thu, 19 Oct 2017 16:20:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] nfsd4: fix cached replies to solo SEQUENCE compounds
Message-ID: <20171019202015.GG16942@parsley.fieldses.org>
References: <CAN-5tyEXeesbAk02LsGDjwoBqZr6q8AzWUhMSV0-V2aUwm44dA@mail.gmail.com>
 <1508361919-30495-1-git-send-email-bfields@redhat.com>
 <CAN-5tyHBv9iFfTEPTgCfNyBo9veiqWiD_2xzVwhHjQ_tNdMFZw@mail.gmail.com>
 <20171019181718.GF16942@parsley.fieldses.org>
 <CAN-5tyFCBrfLnw91R5awik6+miCO7vGfB-K40D1yQw-+nJ6eiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyFCBrfLnw91R5awik6+miCO7vGfB-K40D1yQw-+nJ6eiQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 19, 2017 at 02:34:20PM -0400, Olga Kornievskaia wrote:
> On Thu, Oct 19, 2017 at 2:17 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Thu, Oct 19, 2017 at 01:21:46PM -0400, Olga Kornievskaia wrote:
> >> On Wed, Oct 18, 2017 at 5:25 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >> > From: "J. Bruce Fields" <bfields@redhat.com>
> >> >
> >> > Currently our handling of 4.1+ requests without "cachethis" set is
> >> > confusing and not quite correct.
> >> >
> >> > Suppose a client sends a compound consisting of only a single SEQUENCE
> >> > op, and it matches the seqid in a session slot (so it's a retry), but
> >> > the previous request with that seqid did not have "cachethis" set.
> >> >
> >> > The obvious thing to do might be to return NFS4ERR_RETRY_UNCACHED_REP,
> >> > but the protocol only allows that to be returned on the op following the
> >> > SEQUENCE, and there is no such op in this case.
> >> >
> >> > The protocol permits us to cache replies even if the client didn't ask
> >> > us to.  And it's easy to do so in the case of solo SEQUENCE compounds.
> >> >
> >> > So, when we get a solo SEQUENCE, we can either return the previously
> >> > cached reply or NFSERR_SEQ_FALSE_RETRY if we notice it differs in some
> >> > way from the original call.
> >>
> >> I'm confused in my testing the error was SEQ_MISORDERED and not
> >> SEQ_FALSE_RETRY error?
> >
> > Yes, I must have a typo somewhere, but I haven't spotted it yet.  That
> > was with both patches applied?
> 
> Yes both patches.

Some days I wonder if I should just turn in my C programmer card.

--b.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7bd3ad88b85c..8aeda6ad15b9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2294,7 +2294,7 @@ nfsd4_store_cache_entry(struct nfsd4_compoundres *resp)
 
 	slot->sl_flags |= NFSD4_SLOT_INITIALIZED;
 	if (!nfsd4_cache_this(resp)) {
-		slot->sl_flags &= !NFSD4_SLOT_CACHED;
+		slot->sl_flags &= ~NFSD4_SLOT_CACHED;
 		return;
 	}
 	slot->sl_flags |= NFSD4_SLOT_CACHED;
