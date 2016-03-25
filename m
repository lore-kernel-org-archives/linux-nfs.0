Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37547 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752008AbcCYH0B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2016 03:26:01 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 359D2209DF
	for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2016 03:26:00 -0400 (EDT)
Message-ID: <1458890751.19150.11.camel@themaw.net>
Subject: Re: call_usermodehelper in containers
From: Ian Kent <raven@themaw.net>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com
Date: Fri, 25 Mar 2016 15:25:51 +0800
In-Reply-To: <20160325012857.GA17892@redhat.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	 <20131112004703.GB15377@kroah.com>
	 <20131112061201.04cf25ab@tlielax.poochiereds.net>
	 <528226EC.4050701@parallels.com>
	 <20131112083043.0ab78e67@tlielax.poochiereds.net>
	 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	 <20131118172844.GA10005@redhat.com> <1458805544.3099.16.camel@themaw.net>
	 <20160325012857.GA17892@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-03-25 at 02:28 +0100, Oleg Nesterov wrote:
> Hi Ian,
> 
> I can't really recall this old discussion, so I can be easily wrong...
> 
> On 03/24, Ian Kent wrote:
> > 
> > On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
> > > 
> > > IOW. Please the the "patch" below. It is obviously incomplete and
> > > wrong,
> > > and it can be more clear/clean. And probably we need another API.
> > > Just
> > > to explain what I mean.
> 
> I hope you didn't miss this part ;)

Not at all.

> 
> In particular, we want to turn task_work_add(..., bool notify) into
> task_work_add(..., how_to_notify mask) and this "mask" should allow
> to force TIF_SIGPENDING.

The point of posting the reply was to try and get some advice as my
understanding of the signalling subsystem is fairly poor.

LOL, I'll have another look at the task_work_add() code and see if I can
understand what your trying to tell me.

> 
> > > With this patch call_usermodehelper(..., UMH_IN_MY_NS) should do
> > > exec
> > > from the caller's namespace.
> > 
> > Umm ... I don't think this can work.
> > 
> > I don't think it can be assumed that the init process of a container
> > will behave like an init process.
> > 
> > If you try and do this with a Docker container that has /bin/bash as
> > the
> > init process signals never arrive and work doesn't start until some
> > other signal arrives
> 
> only if it blocks/ignores SIGCHLD? But this doesn't matter, see above
> and
> note the "until we have task_work_add_interruptibel()" in the pseudo
> -code
> I showed.

It seems, and this is not the only case I've encountered, that the init
process in docker containers can be a problem when you want to capture
and handle signals.

I've seen this with /bin/bash and supervisord so far.
I don't know if it is the docker container creation doing this or
something else .... certainly I can catch signals within subordinate
processes.

The other thing that occurs to me is that just about anything in a
container could be subverted so the definition of a privileged process
which can be used as a template form execution is essentially undefined.

Mmm ... maybe I've got that wrong too, ;)

Ian
