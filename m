Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33148 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757434Ab2DIX0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 19:26:21 -0400
Date: Mon, 9 Apr 2012 19:26:18 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120409232618.GI10508@fieldses.org>
References: <4F7F230A.6080506@parallels.com>
 <20120406234039.GA20940@fieldses.org>
 <4F82C6E3.3030009@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F82C6E3.3030009@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 09, 2012 at 03:24:19PM +0400, Stanislav Kinsbursky wrote:
> 07.04.2012 03:40, bfields@fieldses.org пишет:
> >On Fri, Apr 06, 2012 at 09:08:26PM +0400, Stanislav Kinsbursky wrote:
> >>Hello, Bruce.
> >>Could you, please, clarify this reason why grace list is used?
> >>I.e. why list is used instead of some atomic variable, for example?
> >
> >Like just a reference count?  Yeah, that would be OK.
> >
> >In theory it could provide some sort of debugging help.  (E.g. we could
> >print out the list of "lock managers" currently keeping us in grace.)  I
> >had some idea we'd make those lock manager objects more complicated, and
> >might have more for individual containerized services.
> 
> Could you share this idea, please?
> 
> Anyway, I have nothing against lists. Just was curious, why it was used.
> I added Trond and lists to this reply.
> 
> Let me explain, what is the problem with grace period I'm facing
> right know, and what I'm thinking about it.
> So, one of the things to be containerized during "NFSd per net ns"
> work is the grace period, and these are the basic components of it:
> 1) Grace period start.
> 2) Grace period end.
> 3) Grace period check.
> 3) Grace period restart.

For restart, you're thinking of the fs/lockd/svc.c:restart_grace()
that's called on aisngal in lockd()?

I wonder if there's any way to figure out if that's actually used by
anyone?  (E.g. by any distro init scripts).  It strikes me as possibly
impossible to use correctly.  Perhaps we could deprecate it....

> So, the simplest straight-forward way is to make all internal stuff:
> "grace_list", "grace_lock", "grace_period_end" work and both
> "lockd_manager" and "nfsd4_manager" - per network namespace. Also,
> "laundromat_work" have to be per-net as well.
> In this case:
> 1) Start - grace period can be started per net ns in
> "lockd_up_net()" (thus has to be moves there from "lockd()") and
> "nfs4_state_start()".
> 2) End - grace period can be ended per net ns in "lockd_down_net()"
> (thus has to be moved there from "lockd()"), "nfsd4_end_grace()" and
> "fs4_state_shutdown()".
> 3) Check - looks easy. There is either svc_rqst or net context can
> be passed to function.
> 4) Restart - this is a tricky place. It would be great to restart
> grace period only for the networks namespace of the sender of the
> kill signal. So, the idea is to check siginfo_t for the pid of
> sender, then try to locate the task, and if found, then get sender's
> networks namespace, and restart grace period only for this namespace
> (of course, if lockd was started for this namespace - see below).

If it's really the signalling that's the problem--perhaps we can get
away from the signal-based interface.

At least in the case of lockd I suspect we could.

Or perhaps the decision to share a single lockd thread (or set of nsfd
threads) among multiple network namespaces was a poor one.  But I
realize multithreading lockd doesn't look easy.

--b.

> If task not found, of it's lockd wasn't started for it's namespace,
> then grace period can be either restarted for all namespaces, of
> just silently dropped. This is the place where I'm not sure, how to
> do. Because calling grace period for all namespaces will be
> overkill...
> 
> There also another problem with the "task by pid" search, that found
> task can be actually not sender (which died already), but some other
> new task with the same pid number. In this case, I think, we can
> just neglect this probability and always assume, that we located
> sender (if, of course, lockd was started for sender's network
> namespace).
> 
> Trond, Bruce, could you, please, comment this ideas?
> 
> -- 
> Best regards,
> Stanislav Kinsbursky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
