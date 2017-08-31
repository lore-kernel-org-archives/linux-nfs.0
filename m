Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f171.google.com ([209.85.216.171]:37252 "EHLO
        mail-qt0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbdHaXNH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Aug 2017 19:13:07 -0400
Received: by mail-qt0-f171.google.com with SMTP id h15so4721203qta.4
        for <linux-nfs@vger.kernel.org>; Thu, 31 Aug 2017 16:13:07 -0700 (PDT)
Message-ID: <1504221185.4682.8.camel@redhat.com>
Subject: Re: [PATCH 1/3] fs: cleanup to hide some details of delegation logic
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Date: Thu, 31 Aug 2017 19:13:05 -0400
In-Reply-To: <20170831211002.GG8223@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
         <1503697958-6122-2-git-send-email-bfields@redhat.com>
         <87efrwibyz.fsf@notabene.neil.brown.name>
         <20170829213731.GH8822@parsley.fieldses.org>
         <1504122659.2845.1.camel@redhat.com>
         <20170831211002.GG8223@parsley.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-08-31 at 17:10 -0400, J. Bruce Fields wrote:
> On Wed, Aug 30, 2017 at 03:50:59PM -0400, Jeff Layton wrote:
> > ACK, I like that better too. I think a kerneldoc header is probably
> > warranted here too, since this is a bit of an odd return situation.
> 
> Am I overdoing it?:
> 
> --b.
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 6421feeda4bd..2261728cc900 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2285,6 +2285,25 @@ static inline int break_deleg(struct inode *inode, void *who, unsigned int mode)
>  
>  #define DELEG_NO_WAIT ((struct inode *)1)
>  
> +/**
> + * try_break_deleg - initiate a delegation break
> + * @inode: inode to break the delegation on
> + * @deleg_break_ctl: delegation state; see below
> + *
> + * VFS operations that are incompatible with a delegation call this to
> + * break any delegations on the inode first.  The caller must first lock
> + * the inode to prevent races with processes granting new delegations.
> + *
> + * Delegations may be slow to recall, so we initiate the recall but do
> + * not wait for it here while holding locks.  The caller should instead
> + * drop locks and call break_deleg_wait() which will wait for a recall,
> + * if there is one.  The inode to wait on will be stored in
> + * deleg_break_ctl, which also tracks who is breaking the delegation in
> + * the NFS case.  The caller can then retry the operation (possibly on a
> + * different inode, since a new lookup may have been required after
> + * reacquiring locks.)
> + */
> +
>  static inline int try_break_deleg(struct inode *inode, struct deleg_break_ctl *deleg_break_ctl)
>  {
>  	int ret;
> @@ -2299,6 +2318,22 @@ static inline int try_break_deleg(struct inode *inode, struct deleg_break_ctl *d
>  	return ret;
>  }
>  
> +/**
> + * break_deleg_wait - wait on a delegation recall if necessary
> + * @deleg_break_ctl: delegation state
> + * @error: error to use if there is no delegation to wait on
> + *
> + * This should be called with the deleg_break_ctl previously passed to
> + * try_break_deleg().
> + *
> + * If the previous try_break_deleg() found no delegation in need of
> + * breaking, this is a no-op that just returns the given error.
> + *
> + * Otherwise it will wait for the delegation recall.  If the wait is
> + * succesful, it will return a positive value to indicate to the caller
> + * that it should retry the operation that originally prompted the
> + * break.
> + */
>  static inline int break_deleg_wait(struct deleg_break_ctl *deleg_break_ctl, int error)
>  {
>  	if (!deleg_break_ctl->delegated_inode)

No, I like it. This is tricky code, and having the rationale and
detailed behavior spelled out in detail is a good thing.

-- 
Jeff Layton <jlayton@redhat.com>
