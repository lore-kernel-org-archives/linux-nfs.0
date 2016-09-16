Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:34965 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754074AbcIPVqI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 17:46:08 -0400
Received: by mail-qk0-f179.google.com with SMTP id t7so101174925qkh.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 14:46:07 -0700 (PDT)
Message-ID: <1474062362.13386.13.camel@redhat.com>
Subject: Re: [PATCH v3 2/9] nfs: check for POSIX lock capability on server
 even for flock locks
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Schumaker Anna <anna.schumaker@netapp.com>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>,
        Fields Bruce James <bfields@fieldses.org>
Date: Fri, 16 Sep 2016 17:46:02 -0400
In-Reply-To: <AEF00C6F-ECDD-4292-BDC2-A635D4EBB1B4@primarydata.com>
References: <1474057631-31209-1-git-send-email-jlayton@redhat.com>
         <1474057631-31209-3-git-send-email-jlayton@redhat.com>
         <AEF00C6F-ECDD-4292-BDC2-A635D4EBB1B4@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-09-16 at 21:14 +0000, Trond Myklebust wrote:
> > 
> > > > On Sep 16, 2016, at 16:27, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > We may end up in here with a FL_FLOCK lock request. We translate those
> > to whole-file NFSv4 locks and send them on to the server, so we need to
> > verify that the server supports them no matter what sort of lock request
> > this is.
> > 
> > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/nfs4proc.c | 3 +--
> > 1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 9d38366666f4..a0f25185c78c 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -6135,8 +6135,7 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
> > 	unsigned char fl_flags = request->fl_flags;
> > 	int status = -ENOLCK;
> > 
> > > > -	if ((fl_flags & FL_POSIX) &&
> > > > -			!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
> > > > +	if (!test_bit(NFS_STATE_POSIX_LOCKS, &state->flags))
> > > > 		goto out;
> > 	/* Is this a delegated open? */
> > 	status = nfs4_set_lock_state(state, request);
> > -- 
> > 2.7.4
> 
> The ability to support FL_FLOCK locks does not depend on the server’s
> support for POSIX locking semantics. FL_FLOCK can also use stacked
> lock semantics, precisely because they always cover the whole file.

Oh! I had always thought this flags absence basically meant "I don't
support file locking at all, so don't bother sending any LOCK
requests". Now that I look though, all RFC5661 says is:


   o  OPEN4_RESULT_LOCKTYPE_POSIX indicates that the server's byte-range
      locking behavior supports the complete set of POSIX locking
      techniques [24].  From this, the client can choose to manage byte-
      range locking state in a way to handle a mismatch of byte-range
      locking management.

If this flag isn't there, I guess we can't infer anything about how the
server's locks are implemented. That's just super.

So, ok. If you think this logic is more correct as-is, then I'm fine
with dropping this patch. This check gets moved in a later patch
though, so I'll need to fix that up as well.

-- 
Jeff Layton <jlayton@redhat.com>
