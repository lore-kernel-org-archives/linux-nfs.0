Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dragon.async.com.br ([208.70.149.241]:36067 "EHLO
	dragon.async.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757513AbcCURzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 13:55:13 -0400
Date: Mon, 21 Mar 2016 14:55:00 -0300
From: Christian Robottom Reis <kiko@acm.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Finding and breaking client locks
Message-ID: <20160321175500.GA5118@async.com.br>
References: <20160321143914.GA6397@anthem.async.com.br>
 <20160321131906.05ec478b@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160321131906.05ec478b@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 21, 2016 at 01:19:06PM -0400, Jeff Layton wrote:
> On Mon, 21 Mar 2016 11:39:14 -0300
> Christian Robottom Reis <kiko@acm.org> wrote:
> 
> > Hello there,
> > 
> >     I run a diskless network where every user NFS mounts pretty much
> > everything including /home and /var/mail. It's often the case that a
> > misbehaved client will leave a locked file stuck on the server -- today
> > it is a file in a user's mail/ directory.
> > 
> > Is there a way to query what files are being held locked by clients? I'm
> > sure the kernel knows, as it is able to enforce the lock, but it isn't
> > obvious how to extract that information -- lsof is documented to and
> > indeed does not return any information pertaining NFS client locks, and
> > I'm not clear whether /proc/locks (on the server side obviously) does or
> > not.
> 
> /proc/locks will generally show you all of the locks being held
> (assuming the filesystem's ->lock routine records the locks).

Great -- I couldn't find that documented elsewhere; perhaps that's
obvious if that's how locking in the filesystem layer always works (i.e.
for the locking operation to fail on an inode it must be recorded in
/proc/locks).

I wonder, is there a tool which parses /proc/locks and grabs the
filenames from the inode and device information? That would already be
quite interesting to help preemptively debug locking problems.

> It's not really possible to match those up with a particular client
> though.

Because the NFS server doesn't track which client requested a lock, and
instead just passes the request through to the filesystem, I assume?

Perhaps there is nowhere scalable to record that today?

> > A related question is whether it is possible to break a client lock
> > without rebooting the server (or restarting the NFS services).
> > 
> > Does anyone have any insight to share? Thanks,
> 
> I assume you're using NFSv3? What happens when the client "misbehaves"?
> Are the clients dropping offline or do you have applications that are
> just sitting on the lock and not releasing it?

In the situation which happened today my guess (because it's a mbox
file) is that a client ran something like mutt and the machine died
somewhere during shutdown. It's my guess because AIUI the lock doesn't
get stuck if the process is simply KILLed or crashes.

> If the clients are just going away without unlocking first, then you
> could consider using NFSv4, which has a lease-based locking. If the
> client goes away for a while (90s or so), then it'll lose its lock.

That's quite interesting -- and by client do you actually mean "client
application" or client in the sense of the machine itself?

> Alternately, there is the /proc/fs/nfsd/unlock_ip interface. Supposedly
> you can echo an address into there and it'll forcibly drop all of the
> locks that that that client holds. I've not used that so YMMV there.

Oh! That's a very interesting, and I now see it documented here:

    http://people.redhat.com/rpeterso/Patches/NFS/NLM/004.txt

I've never seen it mentioned elsewhere. It doesn't seem to work:

    kiko@chorus:~$ grep 9178074 /proc/locks 
    2: POSIX  ADVISORY  READ  2491 09:04:9178074 0 EOF
    kiko@chorus:~$ echo "192.168.99.14" | sudo tee /proc/fs/nfsd/unlock_ip 
    192.168.99.14
    kiko@chorus:~$ grep 9178074 /proc/locks 
    2: POSIX  ADVISORY  READ  2491 09:04:9178074 0 EOF

(Where .14 is holding the lock -- I have tested and releasing it does
make the lock entry disappear)

Also, if unlock_ip does work, that seems to not jive with the assertion
above that the kernel doesn't track what locks are held by a given
client. Surely if unlock_ip works for a given IP, somewhere that is
tracked?

Thanks,
-- 
Christian Robottom Reis | [+55 16] 3376 0125   | http://async.com.br/~kiko
CEO, Async Open Source  | [+55 16] 9 9112 6430 | http://launchpad.net/~kiko
