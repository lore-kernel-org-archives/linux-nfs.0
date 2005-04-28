From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: nested mounts -- supported?
Date: Thu, 28 Apr 2005 10:21:15 -0400
Message-ID: <17008.61787.345590.727206@segfault.boston.redhat.com>
References: <17008.3537.313570.647302@segfault.boston.redhat.com>
	<Pine.LNX.4.58.0504281551050.13323@wombat.indigo.net.au>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: autofs mailing list <autofs@linux.kernel.org>, nfs@lists.sourceforge.net
Return-path: <autofs-bounces@linux.kernel.org>
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0504281551050.13323@wombat.indigo.net.au>
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

==> Regarding Re: nested mounts -- supported?; Ian Kent <raven@themaw.net> adds:

raven> On Wed, 27 Apr 2005, Jeff Moyer wrote:
>> Hi, Ian,
>> 
>> I've got customers running 4.1.3 that complain about long mount times
>> when using nested mounts.  Basically, they have maps that look like so:
>> 
>> auto.master: /foo /etc/auto.foo /bar /etc/auto.bar
>> 
>> auto.foo baz localhost:/bar/baz/bat
>> 
>> auto.bar baz server:/export/baz
>> 
>> So what ends up happening is /bar/baz is an nfs mountpoint, and
>> /foo/baz/bat is a bind mount inside that nfs mountpoint.  Yuck.
>> 
>> The long timeouts are due to the fact that we are doing a wait_for_lock
>> before calling the mount binary.  Since this is a nested call, we are
>> essentially deadlocked (though the 4.1.3 code simply declared the lock
>> stale and overwrote it after 10 seconds).

raven> This is an unusual way to do things.

raven> The main thing to remember here is that the only reason that locking
raven> is in autofs at all is that mount(8)s' locking is (was)
raven> broken. That's easily demonstarted by putting 50 or so entries in a
raven> master map and getting rid of the lock calls. Often you will see
raven> mtab corruption.

raven> The corruption causes autofs to become very confused.

>> Anyway, is this sort of thing supported?  It seems to work, though I am
>> uneasy about the whole setup.

raven> I think this probably should be supported and probably will work if
raven> the locking in monnt(8) was fixed.

raven> However, if we find that fixed locking mount(8) can't do these
raven> mounts either then we're stuck.

>> Further, if this is something we strive to support, then we have to
>> consider that this won't work under 4.1.4.  The reason is that the
>> revamped locking code will not overwrite the old lock, and so nested
>> mounts will fail.  We will not hang, mind you, we will simply time out
>> waiting for the lock.

raven> Right.

raven> But will the work that's been done in autofs translate to a fix for
raven> the locking in mount(8). mount(8)s' locking is used only to update
raven> mtab so the mount call deadlock we see in autofs shouldn't
raven> happen. The locking code I have now was taken from mount in the
raven> first place so it might fit in fairly well. But I'm not sure what to
raven> propose as, given the locking code in mount(8), I can't actually
raven> work out what their requirements were in the first place
raven> (eg. exclusive lock, stagered delay, etc.).

The locking in mount is used to ensure that we don't corrupt /etc/mtab.  It
is an exclusive lock, and it will timeout (leaving /etc/mtab inconsistent
with /proc/mounts).

raven> I'd like to get rid of the locking code altogether in autofs as it's
raven> just unwanted overhead layered on top of not working overhead. I'd
raven> be willing carry a patch for mount in the distribution with a big
raven> warning. Perhaps we could actually get a response from whoever
raven> maintains mount? I've only tried once without success.

This is the wrong thing to do.  The locking in autofs is used to serialize
access to mount.  Since autofs can perform many simultaneous mounts, we
increase the chance of starving one of the mount programs of the lock.  In
this case, we end up with an inconsistent mtab.

raven> Sorry to rant about this but it burned a lot of my time in the past.

Mount will work fine with nested mounts.  It doesn't take the mtab lock
until it needs to update the mtab file.  Of course, this discussion is all
academic as you point out in your follow-up.

-Jeff
