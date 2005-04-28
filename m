From: Ian Kent <raven@themaw.net>
Subject: Re: nested mounts -- supported?
Date: Thu, 28 Apr 2005 16:38:20 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0504281551050.13323@wombat.indigo.net.au>
References: <17008.3537.313570.647302@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: autofs mailing list <autofs@linux.kernel.org>, nfs@lists.sourceforge.net
Return-path: <autofs-bounces@linux.kernel.org>
To: Jeff Moyer <jmoyer@redhat.com>
In-Reply-To: <17008.3537.313570.647302@segfault.boston.redhat.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://hera.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 27 Apr 2005, Jeff Moyer wrote:

> Hi, Ian,
> 
> I've got customers running 4.1.3 that complain about long mount times when
> using nested mounts.  Basically, they have maps that look like so:
> 
> auto.master:
> /foo	/etc/auto.foo
> /bar	/etc/auto.bar
> 
> auto.foo
> baz	localhost:/bar/baz/bat
> 
> auto.bar
> baz	server:/export/baz
> 
> So what ends up happening is /bar/baz is an nfs mountpoint, and
> /foo/baz/bat is a bind mount inside that nfs mountpoint.  Yuck.
> 
> The long timeouts are due to the fact that we are doing a wait_for_lock
> before calling the mount binary.  Since this is a nested call, we are
> essentially deadlocked (though the 4.1.3 code simply declared the lock
> stale and overwrote it after 10 seconds).

This is an unusual way to do things.

The main thing to remember here is that the only reason that locking is 
in autofs at all is that mount(8)s' locking is (was) broken. That's easily 
demonstarted by putting 50 or so entries in a master map and getting rid 
of the lock calls. Often you will see mtab corruption.

The corruption causes autofs to become very confused.

> 
> Anyway, is this sort of thing supported?  It seems to work, though I am
> uneasy about the whole setup.

I think this probably should be supported and probably will work if the 
locking in monnt(8) was fixed.

However, if we find that fixed locking mount(8) can't do these mounts 
either then we're stuck.

> 
> Further, if this is something we strive to support, then we have to
> consider that this won't work under 4.1.4.  The reason is that the revamped
> locking code will not overwrite the old lock, and so nested mounts will
> fail.  We will not hang, mind you, we will simply time out waiting for the
> lock.

Right.

But will the work that's been done in autofs translate to a fix for the 
locking in mount(8). mount(8)s' locking is used only to update mtab so the 
mount call deadlock we see in autofs shouldn't happen. The locking code I 
have now was taken from mount in the first place so it might fit in fairly 
well. But I'm not sure what to propose as, given the locking code in 
mount(8), I can't actually work out what their requirements were in the 
first place (eg. exclusive lock, stagered delay, etc.).

I'd like to get rid of the locking code altogether in autofs as it's just 
unwanted overhead layered on top of not working overhead. I'd be willing 
carry a patch for mount in the distribution with a big warning. Perhaps we 
could actually get a response from whoever maintains mount? I've only 
tried once without success.

Sorry to rant about this but it burned a lot of my time in the past.

Ian
