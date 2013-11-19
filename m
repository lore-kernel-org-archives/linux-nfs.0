Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43065 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab3KSOwH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Nov 2013 09:52:07 -0500
Date: Tue, 19 Nov 2013 09:51:16 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Greg KH <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        devel@openvz.org, bfields@fieldses.org, bharrosh@panasas.com
Subject: Re: call_usermodehelper in containers
Message-ID: <20131119095116.1254aeaa@tlielax.poochiereds.net>
In-Reply-To: <20131118180259.GA11722@redhat.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
	<5285FA0A.2080802@parallels.com>
	<871u2incyo.fsf@xmission.com>
	<20131118172844.GA10005@redhat.com>
	<20131118180259.GA11722@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 18 Nov 2013 19:02:59 +0100
Oleg Nesterov <oleg@redhat.com> wrote:

> On 11/18, Oleg Nesterov wrote:
> >
> > On 11/15, Eric W. Biederman wrote:
> > >
> > > I don't understand that one.  Having a preforked thread with the proper
> > > environment that can act like kthreadd in terms of spawning user mode
> > > helpers works and is simple.
> >
> > Can't we ask ->child_reaper to create the non-daemonized kernel thread
> > with the "right" ->nsproxy, ->fs, etc?
> >
> > IOW. Please the the "patch" below. It is obviously incomplete and wrong,
> > and it can be more clear/clean. And probably we need another API. Just
> > to explain what I mean.
> 
> Or, perhaps UMH_IN_MY_NS should only work if ->child_reaper explicitly
> does, say, prctl(PR_SPAWN_UMH_IN_NS_HELPER) which forks the non-daemonized
> kernel kthread_worker thread, I dunno.
> 
> Oleg.
> 

Neat idea.

So is it always the case that tasks in a container have the same
namespace settings and capabilities as the child_reaper?

We'll still have the basic problem for nfsd that we'll need to keep
track of what the child_reaper is when nfsd is started, but I think
that's not too hard to solve.

-- 
Jeff Layton <jlayton@redhat.com>
