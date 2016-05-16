Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32936 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754293AbcEPUIK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 16:08:10 -0400
Received: by mail-qk0-f171.google.com with SMTP id n63so103213962qkf.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2016 13:08:10 -0700 (PDT)
Message-ID: <1463429284.26783.23.camel@poochiereds.net>
Subject: Re: [PATCH v3 10/13] pnfs: fix bad error handling in send_layoutget
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "hch@infradead.org" <hch@infradead.org>
Date: Mon, 16 May 2016 16:08:04 -0400
In-Reply-To: <FFD84C76-4FD9-403E-9FDE-4FA51C6F9619@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
 <1463274402-17746-11-git-send-email-jeff.layton@primarydata.com>
	 <FFD84C76-4FD9-403E-9FDE-4FA51C6F9619@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2016-05-16 at 19:50 +0000, Trond Myklebust wrote:
> 
> 
> On 5/14/16, 21:06, "Jeff Layton" <jlayton@poochiereds.net> wrote:
> 
> >Currently, the code will clear the fail bit if we get back a fatal
> >error. I don't think that's correct -- we only want to clear that
> >bit if the layoutget succeeds.
> >
> >Fixes: 0bcbf039f6 (nfs: handle request add failure properly)
> >Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> >---
> > fs/nfs/pnfs.c | 8 +++++---
> > 1 file changed, 5 insertions(+), 3 deletions(-)
> >
> >diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> >index e6cad5ee5d29..5f6ed295acb5 100644
> >--- a/fs/nfs/pnfs.c
> >+++ b/fs/nfs/pnfs.c
> >@@ -876,11 +876,13 @@ send_layoutget(struct pnfs_layout_hdr *lo,
> > lseg = nfs4_proc_layoutget(lgp, gfp_flags);
> > } while (lseg == ERR_PTR(-EAGAIN));
> > 
> >-	if (IS_ERR(lseg) && !nfs_error_is_fatal(PTR_ERR(lseg)))
> >-	 lseg = NULL;
> >-	else
> >+	if (IS_ERR(lseg)) {
> >+	 if (!nfs_error_is_fatal(PTR_ERR(lseg)))
> >+	 lseg = NULL;
> >+	} else {
> > pnfs_layout_clear_fail_bit(lo,
> > pnfs_iomode_to_fail_bit(range->iomode));
> >+	}
> 
> No… The intention was indeed that we clear the fail bit in all cases
> except fatal errors. Otherwise, the client won’t attempt another
> layoutget.
> 

Got it, thanks. Let me respin, retest and resend. Let me know if you
see any other problems and I'll get those fixed before the next resend.

Thanks!
--
Jeff Layton <jlayton@poochiereds.net>
