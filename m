From: "Paul Cunningham" <paulcunningham@sprintmail.com>
Subject: Re Questions about NFS over TCP
Date: Wed, 23 Apr 2003 09:36:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <002e01c3099d$4d98f090$0b01a8c0@PAULSDESKTOP>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from swan.mail.pas.earthlink.net ([207.217.120.123])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198KQZ-0005tS-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 06:36:47 -0700
Received: from user163.net137.nc.sprint-hsd.net ([63.162.203.163] helo=PAULSDESKTOP)
	by swan.mail.pas.earthlink.net with smtp (Exim 3.33 #1)
	id 198KQ1-0004fs-00
	for nfs@lists.sourceforge.net; Wed, 23 Apr 2003 06:36:13 -0700
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> I've just started experimenting with NFS over TCP and have a few
> questions:
>
> The Linux NFS-HOWTO states that:
>
> > The disadvantage of using TCP is that it is not a stateless
> > protocol like UDP. If your server crashes in the middle of a
> > packet transmission, the client will hang and any shares will
> > need to be unmounted and remounted.
>
> I take this to mean that any client that is not actively accessing data
> on the server at the time of a crash will be OK after the server
> reboots?
>
I have not used nor tested Linux's NFS over TCP implementation.  I have
spent lots of time developing and testing NFS over TCP for one of the
commercial UNIX flavors.

As a Linux advocate I truly hope this is not the case.  It has been a couple
of
years but two mount options come to mind, hard and intr.  hard: means do not
give up. You should be able to reboot the server, pull the ethernet cable
for a
month, or any other nasty thing you can thing of, right in the middle of a
read/write etc.  When the server comes back on-line, the read/write or
whatever was happening at that point in time will continue.  This could be a
serious problem except for the intr option.  Some process is hanging around
waiting for the read/write to complete.  The server is terminal
(decommissioned
and nobody told you).  Send a signal and the process should return a EINTR.

Check the man pages
man mount
man nfs

Paul Cunningham




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
