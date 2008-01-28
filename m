From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 015/100] nfsd: Fix handling of negative lengths in
	read_buf()
Date: Mon, 28 Jan 2008 18:31:44 -0500
Message-ID: <20080128233144.GV16785@fieldses.org>
References: <1201303040-7779-11-git-send-email-bfields@citi.umich.edu> <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <346EF0C5-EFD6-4187-BA51-1946142920AB@oracle.com> <20080128201507.GG16785@fieldses.org> <F228287C-EE5C-4274-9DBE-35F87D7DE030@oracle.com> <20080128221406.GQ16785@fieldses.org> <C56728F5-40AC-49F0-B9AD-574FEC4C404C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56371 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753588AbYA1Xbq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 18:31:46 -0500
In-Reply-To: <C56728F5-40AC-49F0-B9AD-574FEC4C404C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 06:16:14PM -0500, Chuck Lever wrote:
> I haven't checked it carefully enough to say whether there is a run-time 
> problem with the old or the patched version of read_buf().  At this point 
> it's not likely, but there is enough implicit type casting in the 
> comparisons and when passing arguments that the original intention of the 
> authors of this code is not exactly clear.
>
> I do now make it a practice in patch descriptions to state "Clean up:" if 
> the patch does not address a run-time bug.

If it's obvious from the comment that's fine too (just keep in mind I'm
often tired and/or stupid, so our definitions of "obvious" may differ!)
I'm not looking for excuses to ignore them, I just want to understand
whether a patch is supposed to make no change in run-time behavior at
all, or fixes a critical runtime bug, or something in between.

>
>> The change in behavior of these comparisons was exactly the point of
>> the patch:
>>
>> 	"The length "nbytes" passed into read_buf should never be
>> 	negative, but we check only for too-large values of "nbytes",
>> 	not for too-small values.  Make nbytes unsigned, so it's clear
>> 	that the former tests are sufficient."
>>
>> Was my comment there unclear, or am I missing some other problem?
>
>
> In my opinion, introducing a mixed sign comparison makes the tests less 
> clear.  I would fix at least "avail" and perhaps "argp->pagelen", and 
> assert that argp->end > argp->p, to make the tests in read_buf() entirely 
> precise.

OK.  For now I'd like to fix the one obvious thing (fixing "avail") and
leave the rest as is.

--b.

commit c93b00d7b51e2fa6fd00aaa41f49c4abc264c151
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sun Nov 11 15:43:12 2007 -0500

    nfsd: Fix handling of negative lengths in read_buf()
    
    The length "nbytes" passed into read_buf should never be negative, but
    we check only for too-large values of "nbytes", not for too-small
    values.  Make nbytes unsigned, so it's clear that the former tests are
    sufficient.  (Despite this read_buf() currently correctly returns an xdr
    error in the case of a negative length, thanks to an unsigned
    comparison with size_of() and bounds-checking in kmalloc().  This seems
    very fragile, though.)
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5733394..20a0961 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -148,12 +148,12 @@ xdr_error:					\
 	}					\
 } while (0)
 
-static __be32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
+static __be32 *read_buf(struct nfsd4_compoundargs *argp, u32 nbytes)
 {
 	/* We want more bytes than seem to be available.
 	 * Maybe we need a new page, maybe we have just run out
 	 */
-	int avail = (char*)argp->end - (char*)argp->p;
+	unsigned int avail = (char*)argp->end - (char*)argp->p;
 	__be32 *p;
 	if (avail + argp->pagelen < nbytes)
 		return NULL;
@@ -169,6 +169,11 @@ static __be32 *read_buf(struct nfsd4_compoundargs *argp, int nbytes)
 			return NULL;
 		
 	}
+	/*
+	 * The following memcpy is safe because read_buf is always
+	 * called with nbytes > avail, and the two cases above both
+	 * guarantee p points to at least nbytes bytes.
+	 */
 	memcpy(p, argp->p, avail);
 	/* step to next page */
 	argp->p = page_address(argp->pagelist[0]);
