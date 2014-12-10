Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933125AbaLJXVV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 18:21:21 -0500
Date: Wed, 10 Dec 2014 18:21:14 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: David Howells <dhowells@redhat.com>
cc: Jeff Layton <jeff.layton@primarydata.com>, ikent@redhat.com,
        =?ISO-8859-15?Q?David_H=E4rdeman?= <david@hardeman.nu>,
        linux-nfs@vger.kernel.org, SteveD@redhat.com
Subject: Re: [PATCH 00/19] gssd improvements
In-Reply-To: <32108.1418227382@warthog.procyon.org.uk>
Message-ID: <alpine.OSX.2.19.9992.1412101744200.92934@planck.local>
References: <20141210093405.23ffc328@tlielax.poochiereds.net> <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu> <20141209080923.2708eb4f@tlielax.poochiereds.net> <4639bc17bcb236c23cfaf2bc57d98b67@hardeman.nu> <20141209095813.163ac2bb@tlielax.poochiereds.net>
 <20141209195530.GA27798@hardeman.nu> <20141210065240.77a23160@tlielax.poochiereds.net> <33fa16f69b18ed67e3fd595b95497941@hardeman.nu> <20141210091734.3c612514@tlielax.poochiereds.net> <cdaf61315d77361a379e3eb1d4eaac1e@hardeman.nu>
 <32108.1418227382@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 10 Dec 2014, David Howells wrote:

> Jeff Layton <jeff.layton@primarydata.com> wrote:
>
> > > This thread might be interesting:
> > > https://lkml.org/lkml/2014/11/24/885
> > >
> >
> > Nice. I wasn't aware that Ian was working on this. I'll take a look.
>
> I'm not sure what the current state of this is.  There was some discussion
> over how best to determine which container we need to run in - and it's
> complicated by the fact that the mounter may run in a different container to
> the program that triggered the mount due to mountpoint propagation.
>
> David

The specific problem of how to run /sbin/request-key in the caller's
"container" for idmap and gssd (and other friends) became more generally a
problem of how to solve the namespace (or more generally again, "context")
problem for some users of kmod's call_usermodehelper.  The nice thing about
call_usermodehelper is that you don't have to do a lot of work to set up a
process to get something done in userspace -- however it is sounding more
like we do need to work hard to set up context for some users.

The userspace work needs to be done within a context that currently exists
or once existed, so the questions are where do we get that context and how
do we keep it around until we need it?

I think there's agreement that the setup of that context should be basically
what's done in fork() for consistency and future work.  So we get LSM and
cgroups, etc.. in addition to namespaces.

There are two suggested approaches:

1) Anytime we think we're going to later need to upcall with a context we
fork and keep a thread around to do that work.  For NFS, that would look
like forking a thread for every mount at mount time.  The user of this API
would be responsible for creating/maintaining the thread and passing it
along for work.

2) Specify that a usermodehelper should attempt to use a context rather than
the default root context.  The context used would be taken from the "init"
process of the current pid_namespace.  Either that init_process itself could
be asked to fork/execve or when the pid_namespace is created a separate
helper thread is reserved.

I lean toward the second approach because I think it most closely matches
the context transistions that we have today, and can be more generally
applied.  I'm pecking away at getting a rough implementation, which I plan
on asking Ian to review initially.

Ben
