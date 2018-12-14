Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1EBC8C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 17:50:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 343D9206BA
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 17:50:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729341AbeLNRuy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 12:50:54 -0500
Received: from fieldses.org ([173.255.197.46]:38776 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727168AbeLNRuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Dec 2018 12:50:54 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 56CD81C26; Fri, 14 Dec 2018 12:50:53 -0500 (EST)
Date:   Fri, 14 Dec 2018 12:50:53 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Benjamin Coddington <bcodding@redhat.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: Show pid of lockd for remote locks
Message-ID: <20181214175053.GD8696@fieldses.org>
References: <62c22ff69bf762085a35d5706bd5e9e421bfbb33.1541093385.git.bcodding@redhat.com>
 <20181102184516.GA21442@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181102184516.GA21442@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 02, 2018 at 02:45:16PM -0400, J. Bruce Fields wrote:
> On Thu, Nov 01, 2018 at 01:39:49PM -0400, Benjamin Coddington wrote:
> > Commit 9d5b86ac13c5 ("fs/locks: Remove fl_nspid and use fs-specific l_pid
> > for remote locks") specified that the l_pid returned for F_GETLK on a local
> > file that has a remote lock should be the pid of the lock manager process.
> > That commit, while updating other filesystems, failed to update lockd, such
> > that locks created by lockd had their fl_pid set to that of the remote
> > process holding the lock.  Fix that here to be the pid of lockd.
> > 
> > Also, fix the client case so that the returned lock pid is negative, which
> > indicates a remote lock on a remote file.
> 
> ACK.
> 
> Uh, I guess I'll take this if nobody else speaks up.

Applied for 4.21.--b.

> 
> --b.
> 
> > 
> > Fixes: 9d5b86ac13c5 ("fs/locks: Remove fl_nspid and use fs-specific...")
> > Cc: stable@vger.kernel.org
> > 
> > Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> > ---
> >  fs/lockd/clntproc.c | 2 +-
> >  fs/lockd/xdr.c      | 4 ++--
> >  fs/lockd/xdr4.c     | 4 ++--
> >  3 files changed, 5 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> > index d20b92f271c2..0a67dd4250e9 100644
> > --- a/fs/lockd/clntproc.c
> > +++ b/fs/lockd/clntproc.c
> > @@ -442,7 +442,7 @@ nlmclnt_test(struct nlm_rqst *req, struct file_lock *fl)
> >  			fl->fl_start = req->a_res.lock.fl.fl_start;
> >  			fl->fl_end = req->a_res.lock.fl.fl_end;
> >  			fl->fl_type = req->a_res.lock.fl.fl_type;
> > -			fl->fl_pid = 0;
> > +			fl->fl_pid = -req->a_res.lock.fl.fl_pid;
> >  			break;
> >  		default:
> >  			status = nlm_stat_to_errno(req->a_res.status);
> > diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
> > index 7147e4aebecc..9846f7e95282 100644
> > --- a/fs/lockd/xdr.c
> > +++ b/fs/lockd/xdr.c
> > @@ -127,7 +127,7 @@ nlm_decode_lock(__be32 *p, struct nlm_lock *lock)
> >  
> >  	locks_init_lock(fl);
> >  	fl->fl_owner = current->files;
> > -	fl->fl_pid   = (pid_t)lock->svid;
> > +	fl->fl_pid   = current->tgid;
> >  	fl->fl_flags = FL_POSIX;
> >  	fl->fl_type  = F_RDLCK;		/* as good as anything else */
> >  	start = ntohl(*p++);
> > @@ -269,7 +269,7 @@ nlmsvc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
> >  	memset(lock, 0, sizeof(*lock));
> >  	locks_init_lock(&lock->fl);
> >  	lock->svid = ~(u32) 0;
> > -	lock->fl.fl_pid = (pid_t)lock->svid;
> > +	lock->fl.fl_pid = current->tgid;
> >  
> >  	if (!(p = nlm_decode_cookie(p, &argp->cookie))
> >  	 || !(p = xdr_decode_string_inplace(p, &lock->caller,
> > diff --git a/fs/lockd/xdr4.c b/fs/lockd/xdr4.c
> > index 7ed9edf9aed4..70154f376695 100644
> > --- a/fs/lockd/xdr4.c
> > +++ b/fs/lockd/xdr4.c
> > @@ -119,7 +119,7 @@ nlm4_decode_lock(__be32 *p, struct nlm_lock *lock)
> >  
> >  	locks_init_lock(fl);
> >  	fl->fl_owner = current->files;
> > -	fl->fl_pid   = (pid_t)lock->svid;
> > +	fl->fl_pid   = current->tgid;
> >  	fl->fl_flags = FL_POSIX;
> >  	fl->fl_type  = F_RDLCK;		/* as good as anything else */
> >  	p = xdr_decode_hyper(p, &start);
> > @@ -266,7 +266,7 @@ nlm4svc_decode_shareargs(struct svc_rqst *rqstp, __be32 *p)
> >  	memset(lock, 0, sizeof(*lock));
> >  	locks_init_lock(&lock->fl);
> >  	lock->svid = ~(u32) 0;
> > -	lock->fl.fl_pid = (pid_t)lock->svid;
> > +	lock->fl.fl_pid = current->tgid;
> >  
> >  	if (!(p = nlm4_decode_cookie(p, &argp->cookie))
> >  	 || !(p = xdr_decode_string_inplace(p, &lock->caller,
> > -- 
> > 2.14.3
