Return-Path: <htejun@gmail.com>
Sender: Tejun Heo <htejun@gmail.com>
Date: Sat, 2 May 2015 22:03:10 -0400
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Shawn Bohrer <shawn.bohrer@gmail.com>, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org,
        mayoff@rgmadvisors.com, fsorenso@redhat.com
Subject: Re: NFS Freezer and stuck tasks
Message-ID: <20150503020310.GH1949@htj.duckdns.org>
References: <20150304220027.GB20242@sbohrermbp13-local.rgmadvisors.com>
 <alpine.OSX.2.19.9992.1505011631390.946@planck.local>
 <alpine.OSX.2.19.9992.1505011708000.656@planck.local>
 <20150501191741.17bed93c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150501191741.17bed93c@tlielax.poochiereds.net>
List-ID: <linux-nfs.vger.kernel.org>

Hey, Jeff.

On Fri, May 01, 2015 at 07:17:41PM -0400, Jeff Layton wrote:
> > Sorry for the noise, and self-reply..  Looks like there's additional context
> > here: http://marc.info/?t=136761512100007&r=1&w=2
> > 
> > Due to a number of locking problems the answer to this problem is likely to
> > be "don't do that" for now.

Unfortunately, cgroup freezer is currently inherently broken.  As it
currently stands, the situation is - if it works for certain use
cases, great; otherwise, don't do that.

...
> My memory is vague, but Tejun (cc'ed) and I discussed this a couple of
> years or so ago and the tentative idea at the time was to teach the
> NFS and RPC code to return a particular error akin to ERESTARTSYS
> (EFREEZE?) when a freeze event comes in and we haven't yet sent an RPC
> call.

The idea is that freezing should be essentially identical to how
SIGSTOP is handled when viewed from kernel side.

> The idea was to teach the ptrace layer to watch for this error and
> freeze at that point and then to reissue the syscall after resume. All
> of that's a non-trivial task though, as knowledge of this would need to
> be plumbed all the way through the stack down to the RPC layer.

So, if nfs can abort and return to userland on sigpending, the task
will be able to finish quckly; otherwise, it'd have to wait till nfs
finishes.

Thanks.

-- 
tejun
