Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:56716 "EHLO
        mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753709AbcKRSz5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2016 13:55:57 -0500
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS Server prevents access to files on different scenarios (lock problem?)
Date: Fri, 18 Nov 2016 19:55:50 +0100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <201611172132.47523.ulrich.gemkow@ikr.uni-stuttgart.de> <201611172234.20638.ulrich.gemkow@ikr.uni-stuttgart.de> <20161118165828.GA5424@fieldses.org>
In-Reply-To: <20161118165828.GA5424@fieldses.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201611181955.51758.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Bruce,

On Friday 18 November 2016, J. Bruce Fields wrote:
> On Thu, Nov 17, 2016 at 10:34:20PM +0100, Ulrich Gemkow wrote:
> > Hello Bruce,
> > 
> > thanks...
> > 
> > On Thursday 17 November 2016, J. Bruce Fields wrote:
> > > On Thu, Nov 17, 2016 at 09:32:47PM +0100, Ulrich Gemkow wrote:
> > > > Hello,
> > > > 
> > > > we use Linux NFS clients with a Linux NFS server in an configuration
> > > > where NFS mounts are done on client boot _and_ on user login in a
> > > > session; umounts are done on users logout from the session.
> > > > 
> > > > We see occasionally several different problems which all may have
> > > > the same root cause:
> > > > 
> > > > - When a client accesses a file which was accessed before
> > > >   from the same client in a previous session the server
> > > >   prevents access to the file until a timeout happens.
> > > > 
> > > >   The timeout has a duration of about 1-3 minutes.
> > > >   In this case the "blocked" file can not even be deleted
> > > >   on the server.
> > > > 
> > > >   --> What causes this timeout? I found nothing in the
> > > >       server code which has such a timeout How can I debug what
> > > >       the server is waiting for or why he is blocking access
> > > >       to the file?
> > > > 
> > > > - Sometimes client processes hang in the middle of a session
> > > >   on some file. After a timeout the file is accessible again.
> > > >   The timeout can take 1 upto several minutes. The file is
> > > >   also blocked on the server, it cannot be accessed.
> > > > 
> > > > I think all theses problemes are caused by something like
> > > > dangling locks or another invalid state on the server.
> > > > 
> > > > The clients show no network error like dropped packets
> > > > or something like this.
> > > > 
> > > > --> How can I debug such hangs?
> > > > 
> > > > We use Linux NFS server and client from vanilla kernel 4.4.31
> > > > with sec=sys.
> > > > 
> > > > Can anyone help? Does "a bell ring"?
> > > 
> > > The lease period is 90 seconds by default, and there are several cases
> > > where you can end up waiting for a lease period.
> > 
> > I found the 90sec lease time period but the timeout is sometimes
> > much longer than 90 sec, often up to 3minutes or longer. Is there
> > something which may cause these longer delays (I played with the
> > 90sec constant and it did not help :-)
> 
> A delegation is the only thing that I can think of that would prevent a
> file from being deleted on the server (by that you mean, not even a "rm
> blockfiled" run from a terminal on the server works?)  Delegations
> should definitely be forcibly revoked after the lease period passes.
> Note that you need to reboot (well, restart the nfs server) after
> changing the lease period, or the change will not take effect.

Thanks for this hint, I will disable delegations. But - the timeout
is for sure longer than 90 seconds in many cases. Can the reason be
a bad interaction between dropped tcp-connections (which may require
some time to be noticed) and the nfs server state(s)?

> > > For example, if the client held some delegations that it didn't return
> > > on unmount, and then it denied knowledge of them when the server tried
> > > to recall them, then the server would have to wait a lease period to
> > > forcibly remove them.  But, the client should be returning delegations
> > > on unmount, so I don't see how this happens.
> > > 
> > > For locks and opens and other state, again the client should be
> > > returning them on unmount.  And anyway the server isn't going to
> > > forcibly remove those ever, unless the entire client goes away
> > > completely, e.g. in a client crash or network partition.
> > > 
> > > So, I don't know.  Are you sure there aren't client crashes or network
> > > problems?
> > 
> > It happens that clients crash
> 
> I'm not sure what you mean there--do you mean clients are involved in
> all of these cases, or some of them?

Cause for the client reboots are impatient users which switch power
off-and-on when a hang happens. So the crashes (reboots) are not
directly related but the hangs happen often after such unwanted
reboots.

> > but IMHO the server should notice this by dropped connections. We have
> > no network problems in these cases.
> 
> By design, an NFS server won't drop locks on loss a TCP connection.
> They'll be dropped either:
> 
> 	- after a full lease period passes without the server hearing
> 	  anything from the client, or
> 	- if the client crashes and reboots; in this case the client
> 	  should inform the server that it just rebooted and that all
> 	  its old locks can be discarded.
> 
> > 
> > > Also I'd personally try to arrange things so you, say, just mount /home/
> > > on boot instead of automounting /home/bfields when bfields logs in.
> > > But, I don't know your situation.
> > 
> > Sure, we can do this. But we are in an unsecure environment and it
> > gives additional (required) security to use more specific mounts
> > (we make the export on the server when the user has authenticated
> > with our own daemon).
> > 
> > What I really miss is an option to disable locks in NFSv4. Maybe
> > you can point me to the right place in the source..?
> 
> Delegations can be turned off, by running this on the server before
> starting it:
> 
> 	echo 0 >/proc/sys/fs/leases-enable
> 
> There's no way to turn off file locks.
> 
> --b.
> 

Thanks again and best regards!

-Ulrich

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------
