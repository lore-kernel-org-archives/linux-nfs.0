Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:37068 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753798Ab1JQChA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 Oct 2011 22:37:00 -0400
Date: Sun, 16 Oct 2011 22:36:57 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Silence compiler warning
Message-ID: <20111017023657.GA19126@umich.edu>
References: <1318810012-15140-1-git-send-email-rees@umich.edu>
 <4E9B8B75.4040209@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4E9B8B75.4040209@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy wrote:

  On 2011-10-16 17:06, Jim Rees wrote:
  > fs/nfs/callback_proc.c: In function ‘do_callback_layoutrecall’:
  > fs/nfs/callback_proc.c:115:26: warning: ‘lo’ may be used uninitialized in this function
  > 
  > No functional change. If no layout is found, we'll return before  using
  > "lo".
  > 
  > Signed-off-by: Jim Rees <rees@umich.edu>
  > ---
  >  fs/nfs/callback_proc.c |    2 +-
  >  1 files changed, 1 insertions(+), 1 deletions(-)
  > 
  > diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
  > index 43926ad..93633f1 100644
  > --- a/fs/nfs/callback_proc.c
  > +++ b/fs/nfs/callback_proc.c
  > @@ -112,7 +112,7 @@ static u32 initiate_file_draining(struct nfs_client *clp,
  >  				  struct cb_layoutrecallargs *args)
  >  {
  >  	struct nfs_server *server;
  > -	struct pnfs_layout_hdr *lo;
  > +	struct pnfs_layout_hdr *lo = NULL;
  >  	struct inode *ino;
  >  	bool found = false;
  >  	u32 rv = NFS4ERR_NOMATCHING_LAYOUT;
  
  Hmm, the warning seems bogus since we use lo only iff found==true
  and it is set iff found==true
  I wonder why I don't see that warning.
  What compiler/version are you using?

gcc (Ubuntu/Linaro 4.5.2-8ubuntu4) 4.5.2

I don't remember seeing this warning before either, but I can't think what I
might have changed that would make a difference.  I did turn on SMP, which I
didn't have before (non-SMP kernels don't seem to work on the latest
Virtualbox).  And yes, the warning is bogus, but should be fixed anyway.
