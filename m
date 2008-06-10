From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Tue, 10 Jun 2008 17:37:56 -0400
Message-ID: <1213133876.20459.91.camel@localhost>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	<20080604203504.62730951@tleilax.poochiereds.net>
	<1213124088.20459.16.camel@localhost>
	<20080610151357.150b6f69@tleilax.poochiereds.net>
	<1213127909.20459.48.camel@localhost>
	<20080610161352.4e588653@tleilax.poochiereds.net>
	<1213130012.20459.58.camel@localhost>
	<20080610170154.68e2e6fb@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, linux-nfs@vger.kernel.org,
	Daniel J Blueman <daniel.blueman@gmail.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080610170154.68e2e6fb@tleilax.poochiereds.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-10 at 17:01 -0400, Jeff Layton wrote:

> In practice, I think the thread generally runs immediately (at least
> with current scheduler behavior), so we're probably not terribly
> vulnerable to this race. Still, we shouldn't rely on that...

In the code I showed you, the 'kthread' task is put to sleep, then
kthread_run() calls wake_up_process() on it, but the current task isn't
scheduled out. Rather, it continues to run, so in almost all UP cases,
the race is not only possible, it is actually rather likely if
nfs_alloc_client() fails.

> For lockd and the nfs4 callback thread, we'll also need to deal with
> the fact that svc_exit_thread() doesn't get called if this happens. So
> we'll need to call svc_exit_thread from the *_down() functions too
> (I presume that's OK).

These *_up()/*_down() functions are getting very complex. Any chance we
could hide some of this complexity in some helpers? Looking at the NFSv4
callback code and lockd, it seems that there might be a couple of
opportunities for merging code.

> nfsd is a bigger problem since it exits on a signal. For that, perhaps
> we should declare a completion variable and have svc_set_num_threads()
> wait until nfsd() has actually run before continuing.

nfsd doesn't use kthreads, does it?
