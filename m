From: "Kris Kelley" <skunk@simdesk.com>
Subject: NFS weirdness - one of two clients breaks on two of three mounts
Date: Thu, 28 Mar 2002 18:21:13 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <001601c1d6b7$a23fe460$4801010a@IATDev.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Received: from [12.105.143.15] (helo=simdesk.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qk9G-0007Xv-00
	for <nfs@lists.sourceforge.net>; Thu, 28 Mar 2002 16:21:42 -0800
To: <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I am having a doozy of a problem, one that is really showing my lack of
NFS expertise.  I need help!

The set-up:

The clients are two linux servers, named mx-two and mx-three.  They run
Red Hat 7.1, with the base versions of the kernel (2.4.2) and mount
(2.10r).  nfs-utils is not installed, since these are only clients, and
I do not use file locking over NFS.

The server that both clients mount to is a Windows 2000 Server running
Hummingbird Maestro 7.0.  I know this is somewhat unorthodox, but before
today we had not experienced any trouble that couldn't be otherwise
explained.

The clients each have three separate shares mounted, using NFS version 2
via UDP with these options:  rsize=4096,wsize=4096,hard,intr

Today, mx-two has had two of its three mounts hang on several occasions,
and its always been the same two mounts.  While those mounts were
hanging (and causing the associated processes to freeze indefinitely),
the mounts on mx-three, along with the remaining mount on mx-two, were
experiencing a lot less trouble.

The first time this happened was at 9 AM this morning.  I saw these logs
on mx-two:

   Mar 28 08:58:44 mx-two kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 09:00:38 mx-two last message repeated 3 times
   Mar 28 09:02:34 mx-two kernel: nfs:
      task 30994 can't get a request slot
   Mar 28 09:03:27 mx-two kernel: nfs:
      task 34669 can't get a request slot
   Mar 28 09:04:00 mx-two kernel: nfs:
      task 36090 can't get a request slot
   Mar 28 09:04:27 mx-two kernel: nfs:
      task 36477 can't get a request slot
   Mar 28 09:13:13 mx-two kernel: nfs:
      task 44698 can't get a request slot

The "can't get a request slot" errors continued for about 45 minutes, at
which point the problem seemingly cleared up by itself:

   Mar 28 09:43:15 mx-two kernel: nfs: server 10.1.1.24 OK
   Mar 28 09:43:22 mx-two last message repeated 19 times

mx-three's logs were somewhat more benign:

   Mar 28 09:16:32 mx-three kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 09:16:34 mx-three kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 09:16:34 mx-three kernel: nfs: server 10.1.1.24 OK
   Mar 28 09:16:36 mx-three kernel: nfs: server 10.1.1.24 OK
   Mar 28 09:18:05 mx-three kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 09:18:05 mx-three kernel: nfs: server 10.1.1.24 OK
   Mar 28 09:42:13 mx-three kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 09:42:37 mx-three kernel: nfs: server 10.1.1.24 OK

The problem resurfaced starting at 9:58 AM, with mx-two saying the NFS
server was not responding, and the "can't get a request slot" errors
beginning to pile up.  This continued for nearly an hour and a half, and
eventually I saw this error in the logs:

   Mar 28 11:25:00 mx-two kernel: nfs_statfs: statfs error = 512

Immediately after this, I tried rebooting the machine.  Interestingly,
not only did the hung shares (/nfsmount2 and /nfsmount3) have trouble
unmounting, but the one good share (/nfsmount1) also had trouble
unmounting.  I saw these logs during the shutdown process:

   Mar 28 11:26:01 mx-two kernel: nfs:
      task 27416 can't get a request slot
   Mar 28 11:26:08 mx-two kernel: nfs:
      task 27655 can't get a request slot
   Mar 28 11:26:32 mx-two umount: Cannot MOUNTPROG RPC: RPC:
      Port mapper failure - RPC: Timed out
   Mar 28 11:26:32 mx-two umount: umount2: Device or resource busy
   Mar 28 11:26:32 mx-two umount: umount: /nfsmount2: device is busy
   Mar 28 11:26:42 mx-two kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 11:27:32 mx-two umount: Cannot MOUNTPROG RPC: RPC:
      Port mapper failure - RPC: Timed out
   Mar 28 11:27:32 mx-two umount: umount2: Device or resource busy
   Mar 28 11:27:32 mx-two umount: umount: /nfsmount3: device is busy
   Mar 28 11:27:43 mx-two kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 11:28:32 mx-two umount: Cannot MOUNTPROG RPC: RPC:
      Port mapper failure - RPC: Timed out
   Mar 28 11:28:33 mx-two umount: umount2: Device or resource busy
   Mar 28 11:28:33 mx-two umount: umount: /nfsmount1: device is busy
   Mar 28 11:28:33 mx-two netfs: Unmounting NFS filesystems:  failed
   Mar 28 11:29:32 mx-two kernel: nfs:
      task 28525 can't get a request slot
   Mar 28 11:30:35 mx-two kernel: nfs:
      task 28713 can't get a request slot

At this point I gave up and just hit the power button.  When the machine
came back alive, the NFS shares failed to mount:

   Mar 28 11:35:45 mx-two mount: mount: RPC: Timed out
   Mar 28 11:36:06 mx-two mount: mount: RPC: Timed out
   Mar 28 11:36:06 mx-two netfs: Mounting NFS filesystems:  failed

I remounted the shares manually soon after the start-up process was
complete.

Meanwhile, mx-three had virtually no trouble during this 1.5-hour-long
period, logging only a few time-outs at about the time I was rebooting
mx-two:

   Mar 28 11:32:31 mx-three kernel: nfs:
      server 10.1.1.24 not responding, still trying
   Mar 28 11:32:32 mx-three last message repeated 2 times
   Mar 28 11:32:32 mx-three kernel: nfs: server 10.1.1.24 OK
   Mar 28 11:32:33 mx-three kernel: nfs: server 10.1.1.24 OK
   Mar 28 11:32:34 mx-three kernel: nfs: server 10.1.1.24 OK

This whole entire cycle repeated itself several times during the day.

Sometimes I was able to work around the problem by "remounting", that
is, mounting the same shares at the same mount points, hiding the old,
hung mounts.  While this did not clear up processes that were trying to
access those mounts at the time, it did allow newer processes to see the
shares properly.  On one occasion, the problem seemed to be cleared up,
the same way it did at 9:43 AM, and the hung processes cleared out.
Three other times, however, I ended up rebooting mx-two to clean up the
broken mounts.  All the while, mx-three reported time-outs, and
occasionally a "can't get a request slot" error, but did not have
extended long-term problems the way mx-two did.  And during the times
these errors were piling up, that one mount on mx-two still seemed to
behave itself.

On one occasion, while mx-two was thrashing about, I tried unmounting
one of the affected shares from mx-three.  I got an RPC time-out but the
share still unmounted.

These machines stay fairly busy during the day, as both SMTP and IMAP
servers, and they share the load fairly equally (balanced behind a
common, outside IP).  The network admin was trying different settings on
the firewall, but the problem persisted through several configuration
changes, and he is convinced that is not a firewall issue.

mx-three's installation is more recent, but the relevant software
(kernel, mount, email software packages) running on both is exactly the
same.

As I write this, NFS has been behaving itself for about an hour and a
half now.  At one point I tried switching mx-two's mounts to TCP, and
they are still mounted that way (using NFS version 2).  Otherwise, I
have not changed anything on the server or the clients.

This set-up has been in place for several months now, with nothing of
this nature happening before.  Again, I am very inexperienced at
troubleshooting NFS, so I would greatly welcome any pointers on where to
start digging to find the root of this problem.  Thank you!

---Kris Kelley


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
