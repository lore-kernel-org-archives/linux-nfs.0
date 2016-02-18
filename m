Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59186 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933442AbcBRHhV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 02:37:21 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id B280E2159A
	for <linux-nfs@vger.kernel.org>; Thu, 18 Feb 2016 02:37:20 -0500 (EST)
Message-ID: <1455781033.2908.5.camel@themaw.net>
Subject: Re: call_usermodehelper in containers
From: Ian Kent <raven@themaw.net>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
Date: Thu, 18 Feb 2016 15:37:13 +0800
In-Reply-To: <1455777387.3188.24.camel@themaw.net>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	 <20131112004703.GB15377@kroah.com>
	 <20131112061201.04cf25ab@tlielax.poochiereds.net>
	 <528226EC.4050701@parallels.com>
	 <20131112083043.0ab78e67@tlielax.poochiereds.net>
	 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
	 <20131118172844.GA10005@redhat.com> <1455149857.2903.9.camel@themaw.net>
	 <8737sq4teb.fsf@x220.int.ebiederm.org> <56C53DE3.1070108@jp.fujitsu.com>
	 <1455777387.3188.24.camel@themaw.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-02-18 at 14:36 +0800, Ian Kent wrote:
> On Thu, 2016-02-18 at 12:43 +0900, Kamezawa Hiroyuki wrote:
> > On 2016/02/18 11:57, Eric W. Biederman wrote:
> > > 
> > > Ccing The containers list because a related discussion is
> > > happening
> > > there
> > > and somehow this thread has never made it there.
> > > 
> > > Ian Kent <raven@themaw.net> writes:
> > > 
> > > > On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
> > > > > On 11/15, Eric W. Biederman wrote:
> > > > > > 
> > > > > > I don't understand that one.  Having a preforked thread with
> > > > > > the
> > > > > > proper
> > > > > > environment that can act like kthreadd in terms of spawning
> > > > > > user
> > > > > > mode
> > > > > > helpers works and is simple.
> > > > 
> > > > Forgive me replying to such an old thread but ...
> > > > 
> > > > After realizing workqueues can't be used to pre-create threads
> > > > to
> > > > run
> > > > usermode helpers I've returned to look at this.
> > > 
> > > If someone can wind up with a good implementation I will be happy.
> > > 
> > > > > Can't we ask ->child_reaper to create the non-daemonized
> > > > > kernel
> > > > > thread
> > > > > with the "right" ->nsproxy, ->fs, etc?
> > > > 
> > > > Eric, do you think this approach would be sufficient too?
> > > > 
> > > > Probably wouldn't be quite right for user namespaces but should
> > > > provide
> > > > what's needed for other cases?
> > > > 
> > > > It certainly has the advantage of not having to maintain a
> > > > plague
> > > > of
> > > > processes waiting around to execute helpers.
> > > 
> > > That certainly sounds attractive.  Especially for the case of
> > > everyone
> > > who wants to set a core pattern in a container.
> > > 
> > > I am fuzzy on all of the details right now, but what I do remember
> > > is
> > > that in the kernel the user mode helper concepts when they
> > > attempted
> > > to
> > > scrub a processes environment were quite error prone until we
> > > managed to
> > > get kthreadd(pid 2) on the scene which always had a clean
> > > environment.
> > > 
> > > If we are going to tie this kind of thing to the pid namespace I
> > > recommend simplying denying it if you are in a user namespace
> > > without
> > > an approrpriate pid namespace.  AKA simply not allowing thigns to
> > > be
> > > setup
> > > if current->pid_ns->user_ns != current->user_ns.
> > > 
> > Can't be handled by simple capability like CAP_SYS_USERMODEHELPER ?
> > 
> > User_ns check seems not to allow core-dump-cather in host will not
> > work if user_ns is used.
> 
> I don't think so but I'm not sure.
> 
> The approach I was talking about assumes the init process of the
> caller
> (say within a container, corresponding to ->child_reaper) is an
> appropriate template for umh thread execution.
> 
> But I don't think that covers the case where unshare has created
> different namespaces, like a mount namespace for example.
> 
> The current workqueue sub system can't be used to pre-create a thread
> to
> be used for umh execution so, either is needs changes or yet another
> mechanism needs to be implemented.
> 
> For uses other than core dumping capturing a reference to the struct
> pid
> of the environment init process and using that as an execution
> template
> should be sufficient and takes care of environment existence problems
> with some extra checks, not to mention eliminating the need for a
> potentially huge number of kernel threads needing to be created to
> provide execution templates.
> 
> Where to store this and how to access it when needed is another
> problem.
> 
> Not sure a usermode helper capability is the right thing either as I
> thought one important use of user namespaces was to allow unprivileged
> users to perform operations they otherwise can't.
> 
> Maybe a CAP_SYS_USERNSCOREDUMP or similar would be sensible ....
> 
> Still an appropriate execution template would be needed and IIUC we
> can't trust getting that from within a user created namespace
> environment.

Perhaps, if a struct cred could be captured at some appropriate time
that could be used to cater for user namespaces.

Eric, do you think that would be possible to do without allowing users
to circumvent security?

> 
> > 
> > Thanks,
> > -Kame
