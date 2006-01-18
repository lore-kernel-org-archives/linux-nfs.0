From: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
Subject: Another hang problem - Jukebox error (was: NFS hangs for 15 seconds after exportfs -r)
Date: Wed, 18 Jan 2006 11:35:02 -0600
Message-ID: <C664ABFF405D6A458806C03AA2E0FF6B06CBC744@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EzHDP-00047M-D5
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 09:35:23 -0800
Received: from ext-nj2ut-13.online-age.net ([64.14.54.246])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EzHDO-0002Dt-Ru
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 09:35:23 -0800
Received: from int-nj2ut-5.online-age.net (int-nj2ut-5.online-age.net [3.159.237.74])
	by ext-nj2ut-13.online-age.net (8.13.5/8.13.5/20051114-SVVS-TLS-DNSBL) with ESMTP id k0IHZ3Am018417
	for <nfs@lists.sourceforge.net>; Wed, 18 Jan 2006 12:35:03 -0500
Received: from cinmlef06.e2k.ad.ge.com (localhost.localdomain [127.0.0.1])
	by int-nj2ut-5.online-age.net (8.11.6/8.11.6/20050510-SVVS) with ESMTP id k0IHZ3R15698
	for <nfs@lists.sourceforge.net>; Wed, 18 Jan 2006 12:35:03 -0500
To: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>,
	"Neil Brown" <neilb@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


We have discovered another hang problem, I am not sure if it's
related to the other one or not.

We have discovered that on boot up, the very first time the RTOS
tries to access NFS, it gets a JUKEBOX error and the RTOS waits
15 seconds before retrying.

We were capturing the packets with tcpdump and everytime the RTOS
tries to read the first file, Linux returns an JUKEBOX error=20
(10008).  One odd thing was that one time it sent back an OK reply
right after the Jukebox error, but by then it was too late the RTOS
had gotten the error.

I compared the nfs code from kernel 2.6.6 (our old kernel that
worked) and 2.6.9 (that causes the error) and discovered that there
was an addition of a JUKEBOX error from an EWOULDBLOCK in nfsproc.c.
I couldn't find a difference that would explain why we would be=20
getting an error when we didn't before (mostly because there were=20
so many changes I couldn't figure out which one could cause an=20
error).

I built a 2.6.6 kernel to test in place of the 2.6.9 but the
machine won't boot with it, it gets a kernel panic on boot.

I'm not sure where to look now.  Could anyone shed some light on
why we would be getting the JUKEBOX (EWOULDBLOCK?) error the first
time NFS is accessed?

Thanks
  -Scott


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net]On Behalf Of Edwards, Scott (GE
Healthcare)
Sent: Friday, January 13, 2006 3:08 PM
To: Neil Brown
Cc: nfs@lists.sourceforge.net
Subject: RE: [NFS] NFS hangs for 15 seconds after exportfs -r



Boy, am I ever embarrassed.  I completely misunderstood what was
happening.

We have a program that mounts and unmounts the CD and makes calls
to exportfs along the way to make sure it gets re-exported.  I knew
that it hung for 15 seconds both after you inserted a CD and ejected
a CD.  And we knew that if you took out the exportfs calls (all of
them) the delay went away.  I looked at the mount and unmount and
the mount only called exportfs once with the -r option so I thought
since it was only one call it would easier to chase down.  However,
when I started to try to run strace I found that there was no delay
after I did an exportfs -r.  Upon further investigation I discovered
the program does an unmount before it does a mount.  So when you
insert a CD it does the whole unmount sequence.  From there it was
quite obvious what was causing the delay: there is an "exportfs -f"
call before unmounting the CD.  Sure enough all I have to do is run
a "exportfs -f" from the command line and the RTOS hangs for 16 or
so seconds.

I then re-installed Fedora Core 2 on a system and discovered that
it has the same delay after a "exportfs -f" command, but that if
you follow the "exportfs -f" command immediately with a "exportfs
-a" command (which the program does) there is no delay.  I have no
idea why.

So I'm not sure what this means to us yet.  Perhaps we can just
leave out the "exportfs -f"...

Anyway, thanks for the help and sorry for the trouble.

-Scott


-----Original Message-----
From: Neil Brown [mailto:neilb@suse.de]
Sent: Thursday, January 12, 2006 5:33 PM
To: Edwards, Scott (GE Healthcare)
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS hangs for 15 seconds after exportfs -r


On Thursday January 12, J.Scott.Edwards@ge.com wrote:
>=20
> We have a strange problem with the 2.6.9 kernel and NFS hanging for =
=3D
> several seconds after upgrading.
>=20
> We have been running Fedora Core 2 for about two years on a system.  =
=3D
> This system has two processors, one running an RTOS and the other was =
=3D
> running the 2.6.6 kernel.  The RTOS is diskless and mounts a partition =
=3D
> on the Linux drive via NFS.  It also mounts the CD-ROM drive under =
it's =3D
> partition when a disc is mounted.  When the CD is mounted we run an =
=3D
> "exportfs -r" command to export the CD.  The system worked fine with =
=3D
> Fedora Core 2 and the 2.6.6 kernel.
>=20
> Lately we have been trying to upgrade to a newer version of Linux =
2.6.9 =3D
> kernel, with the RHEL clones (WhiteBox and CentOS).  On both of these =
=3D
> systems after a CD is inserted the RTOS hangs for around 15 seconds =
=3D
> waiting for NFS to reply.  We have tried removing "exportfs -r" and =
then =3D
> there is no perceivable delay.  However the reason that is in there is =
=3D
> so that the newly mounted CD is exported so we need to have that.
>=20
> Is this a known problem with the 2.6.9 Kernel?  I searched the =
archives =3D
> and found a couple of e-mails about the 2.6.9 kernel hanging after an =
=3D
> "exportfs -ra", but it hung completely and never came back.
>=20
> Any advice would be most appreciated.

Sounds weird, and doesn't ring any bells....

I suspect that mountd on the server would be implicated in the hang
somehow.=20
Can you get an 'strace' and maybe also an 'ltrace' of mountd when the
hang happens on the client and see if that shows anything interesting.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log =
files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_idv37&alloc_id=16865&op=3Dick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
