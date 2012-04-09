Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab2DINsJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2012 09:48:09 -0400
Date: Mon, 9 Apr 2012 09:47:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Message-ID: <20120409094743.56932677@tlielax.poochiereds.net>
In-Reply-To: <4F82C6E3.3030009@parallels.com>
References: <4F7F230A.6080506@parallels.com>
	<20120406234039.GA20940@fieldses.org>
	<4F82C6E3.3030009@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 09 Apr 2012 15:24:19 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> 07.04.2012 03:40, bfields@fieldses.org пишет:
> > On Fri, Apr 06, 2012 at 09:08:26PM +0400, Stanislav Kinsbursky wrote:
> >> Hello, Bruce.
> >> Could you, please, clarify this reason why grace list is used?
> >> I.e. why list is used instead of some atomic variable, for example?
> >
> > Like just a reference count?  Yeah, that would be OK.
> >
> > In theory it could provide some sort of debugging help.  (E.g. we could
> > print out the list of "lock managers" currently keeping us in grace.)  I
> > had some idea we'd make those lock manager objects more complicated, and
> > might have more for individual containerized services.
> 
> Could you share this idea, please?
> 
> Anyway, I have nothing against lists. Just was curious, why it was used.
> I added Trond and lists to this reply.
> 
> Let me explain, what is the problem with grace period I'm facing right know, and 
> what I'm thinking about it.
> So, one of the things to be containerized during "NFSd per net ns" work is the 
> grace period, and these are the basic components of it:
> 1) Grace period start.
> 2) Grace period end.
> 3) Grace period check.
> 3) Grace period restart.
> 
> So, the simplest straight-forward way is to make all internal stuff: 
> "grace_list", "grace_lock", "grace_period_end" work and both "lockd_manager" and 
> "nfsd4_manager" - per network namespace. Also, "laundromat_work" have to be 
> per-net as well.
> In this case:
> 1) Start - grace period can be started per net ns in "lockd_up_net()" (thus has 
> to be moves there from "lockd()") and "nfs4_state_start()".
> 2) End - grace period can be ended per net ns in "lockd_down_net()" (thus has to 
> be moved there from "lockd()"), "nfsd4_end_grace()" and "fs4_state_shutdown()".
> 3) Check - looks easy. There is either svc_rqst or net context can be passed to 
> function.
> 4) Restart - this is a tricky place. It would be great to restart grace period 
> only for the networks namespace of the sender of the kill signal. So, the idea 
> is to check siginfo_t for the pid of sender, then try to locate the task, and if 
> found, then get sender's networks namespace, and restart grace period only for 
> this namespace (of course, if lockd was started for this namespace - see below).
> 
> If task not found, of it's lockd wasn't started for it's namespace, then grace 
> period can be either restarted for all namespaces, of just silently dropped. 
> This is the place where I'm not sure, how to do. Because calling grace period 
> for all namespaces will be overkill...
> 
> There also another problem with the "task by pid" search, that found task can be 
> actually not sender (which died already), but some other new task with the same 
> pid number. In this case, I think, we can just neglect this probability and 
> always assume, that we located sender (if, of course, lockd was started for 
> sender's network namespace).
> 
> Trond, Bruce, could you, please, comment this ideas?
> 

I can comment and I'm not sure that will be sufficient.

The grace period has a particular purpose. It keeps nfsd or lockd from
handing out stateful objects (e.g. locks) before clients have an
opportunity to reclaim them. Once the grace period expires, there is no
more reclaim allowed and "normal" lock and open requests can proceed.

Traditionally, there has been one nfsd or lockd "instance" per host.
With that, we were able to get away with a relatively simple-minded
approach of a global grace period that's gated on nfsd or lockd's
startup and shutdown.

Now, you're looking at making multiple nfsd or lockd "instances". Does
it make sense to make this a per-net thing? Here's a particularly
problematic case to illustrate what I mean:

Suppose I have a filesystem that's mounted and exported in two
different containers. You start up one container and then 60s later,
start up the other. The grace period expires in the first container and
that nfsd hands out locks that conflict with some that have not been
reclaimed yet in the other.

Now, we can just try to say "don't export the same fs from more than
one container". But we all know that people will do it anyway, since
there's nothing that really stops you from doing so.

What probably makes more sense is making the grace period a per-sb
property, and coming up with a set of rules for the fs going into and
out of "grace" status.

Perhaps a way for different net namespaces to "subscribe" to a
particular fs, and don't take the fs out of grace until all of the
grace period timers pop? If a fs attempts to subscribe after the fs
comes out of grace, then its subscription would be denied and reclaim
attempts would get NFS4ERR_NOGRACE or the NLM equivalent.

-- 
Jeff Layton <jlayton@redhat.com>
