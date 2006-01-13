From: "Edwards, Scott (GE Healthcare)" <J.Scott.Edwards@ge.com>
Subject: RE: NFS hangs for 15 seconds after exportfs -r
Date: Fri, 13 Jan 2006 16:07:55 -0600
Message-ID: <C664ABFF405D6A458806C03AA2E0FF6B06CBC738@MKEMLVEM01.e2k.ad.ge.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExX65-0007r2-Jb
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 14:08:37 -0800
Received: from ext-ch1gw-6.online-age.net ([64.37.194.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ExX64-0006PT-0p
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 14:08:37 -0800
Received: from int-ch1gw-4.online-age.net (int-ch1gw-4 [3.159.232.68])
	by ext-ch1gw-6.online-age.net (8.13.4/8.13.5/20051111-SVVS-TLS-DNSBL) with ESMTP id k0DM7xDa016939
	for <nfs@lists.sourceforge.net>; Fri, 13 Jan 2006 17:07:59 -0500
Received: from cinmlef09.e2k.ad.ge.com (localhost [127.0.0.1])
	by int-ch1gw-4.online-age.net (8.12.9/8.12.3/990426-RLH) with ESMTP id k0DM7tvP002489
	for <nfs@lists.sourceforge.net>; Fri, 13 Jan 2006 17:07:59 -0500 (EST)
To: "Neil Brown" <neilb@suse.de>
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
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
