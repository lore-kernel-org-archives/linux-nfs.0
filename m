From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: Re: Broken umount -f
Date: Wed, 15 Jan 2003 13:59:40 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C77EC@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YthU-0003Yh-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 11:59:48 -0800
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




> Message: 1
> From: "Cole, Timothy D." <tdcole@northropgrumman.com>
> To: 'Scott Mcdermott' <smcdermott@questra.com>, =
nfs@lists.sourceforge.net
> Subject: RE: [NFS] Re: broken umount -f
> Date: Wed, 15 Jan 2003 10:46:42 -0800
>=20
> > -----Original Message-----
> > From: Scott Mcdermott [mailto:smcdermott@questra.com]
> > Sent: Wednesday, January 15, 2003 12:24
> > To: nfs@lists.sourceforge.net
> > Subject: Re: [NFS] Re: broken umount -f
> >=20
> > User saving his mail spool, sees "nfs server not responding, still
> > trying" and decides to try killing his MUA.  Too bad it works and =
now
> > his spool is a steaming pile of ASCII.
>=20
> That's possible with non-NFS filesystems too -- just normally a =
smaller
> window of opportunity.  It doesn't require a filesystem hang in any =
case --
> most mailbox operations are not a single atomic write().  Imagine =
someone
> killing the MUA in the middle of deleting a large mail from a ~40MB =
mail
> spool on any filesystem, local or remote.
>=20
> Also consider the nointr case -- process hangs, user can't kill it, =
user
> naively closes the terminal window.  Server comes back up.  SIGHUP is
> finally handled when the write() returns.  Process dies.  ASCII soup =
again.
>=20
> This is of course assuming that the NFS server _can_ come back up.  If =
not,
> totally unkillable processes are a pain-in-the-ssh.
>=20
> > `soft' and `intr' are evil and should be banned.
>=20
> Agreed WRT soft's evil-ness, anyway.  But hard,intr seems to be a =
pretty
> good combination, as far as safety from data corruption, and from a
> standpoint of not having to reboot-and-kill-week-long-simulations just
> because a few unrelated (but important) processes got wedged by a
> recalcitrant NFS server.
>=20
	Thinking about it, having non-intr won't save you in any way shape for
	form.

	If the nfs server pauses for some reason and you have non-intr and the=20
	user hits ctrl-c or something similir, it will just wait for the server =
to come
	back and then take the ctrl-c and abruptly kill the program, if the=20
	operation(s) takes any amount of time you will still have corrupted =
files.

					Roger


-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
