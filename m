From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: mtab and procs not in sync?
Date: Wed, 9 Jun 2004 10:48:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61130435E236@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY7Cx-0002Yr-Hw
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 10:49:51 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BY7Cx-0001rE-5p
	for nfs@lists.sourceforge.net; Wed, 09 Jun 2004 10:49:51 -0700
To: "James Pearson" <james-p@moving-picture.com>
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

i would guess that if seq_file is used, then /proc/mounts should be OK.

i was looking at a RHEL AS 2.1 system last week that used the single
page I/O model for /proc/mounts, and it was definitely busted.

> -----Original Message-----
> From: James Pearson [mailto:james-p@moving-picture.com]=20
> Sent: Wednesday, June 09, 2004 11:05 AM
> To: Lever, Charles
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] mtab and procs not in sync?
>=20
>=20
> On a 2.4.26 kernel on x86 I can get /proc/mounts to go over=20
> 4K (over 8K=20
> with about 100 automounted file systems).
>=20
> Having a quick look through the kernel code I can see=20
> seq_file used in=20
> relation to proc_mounts_operations (fs/proc/base.c) - however=20
> as I don't=20
> pretend to understand the code, I can't say this is the case ...
>=20
> If 2.4.X does use seq_file, then is it safe to say=20
> /proc/mounts doesn't=20
> suffer from a truncation problem?
>=20
> James Pearson
>=20
> Lever, Charles wrote:
> > as far as i can tell, the 4KB limit is common to x86 on 2.2 and 2.4.
> > 2.6 has replaced the old /proc read method with seq_file,=20
> so i believe
> > /proc/mounts on 2.6 kernels will not suffer from this problem.
> >=20
> > it's not a fixed number of mounts, because the length of=20
> each line in
> > /proc/mounts depends on what mount options are in effect. =20
> the limit is
> > the number of characters in the file.
> >=20
> >=20
> >>-----Original Message-----
> >>From: James Pearson [mailto:james-p@moving-picture.com]=20
> >>Sent: Wednesday, June 09, 2004 6:29 AM
> >>To: Lever, Charles
> >>Cc: nfs@lists.sourceforge.net
> >>Subject: Re: [NFS] mtab and procs not in sync?
> >>
> >>
> >>Do you know how many 'a lot of mounts' is?
> >>
> >>I believe there was a problem with /proc/mounts in 2.2=20
> >>kernels (limited=20
> >>to one page) - is there still a limit in 2.4 or 2.6 kernels?
> >>
> >>I currently symlink /proc/mounts to /etc/mtab on diskless=20
> machines to=20
> >>get round the issue that /etc/mtab can not trusted to be=20
> >>correct. I only=20
> >>have a maximum of a few 10's of mounts at any one time.
> >>
> >>James Pearson
> >>
> >>Lever, Charles wrote:
> >>
> >>>if there are a lot of mounts on the system, then=20
> >>
> >>/proc/mounts can be=20
> >>
> >>>truncated and not show all of them.
> >>>
> >>>however, if there are more mounts in /proc/mounts than in=20
> >>
> >>/etc/mtab,=20
> >>
> >>>there is probably a bug in mount.  not unheard of.
> >>>
> >>>
> >>>
> >>>>-----Original Message-----
> >>>>From: Phy Prabab [mailto:phyprabab@yahoo.com]
> >>>>Sent: Tuesday, June 08, 2004 2:21 PM
> >>>>To: nfs@lists.sourceforge.net
> >>>>Subject: [NFS] mtab and procs not in sync?
> >>>>
> >>>>
> >>>>Hello,
> >>>>
> >>>>Have run into a situation where mtab does not match=20
> /proc/mounts in=20
> >>>>that mtab has numerous entries that have expired off and=20
> >>
> >>removed, yet=20
> >>
> >>>>does not show that it has been removed from mtab.  Is this=20
> >>
> >>known and=20
> >>
> >>>>is there a fix?
> >>>>
> >>>>Kernel 2.4.21 and 23
> >>>>nfs-utils 1.06
> >>>>automount 4.1.2
> >>>>
> >>>>Thanks!
> >>>>Phy
> >>>>
> >>>>
> >>>>=09
> >>>>	=09
> >>>>__________________________________
> >>>>Do you Yahoo!?
> >>>>Friends.  Fun.  Try the all-new Yahoo! Messenger.=20
> >>>>http://messenger.yahoo.com/
> >>>>
> >>>>
> >>>>-------------------------------------------------------
> >>>>This SF.Net email is sponsored by: GNOME Foundation
> >>>>Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.=20
> >>>>GNOME Users and Developers European Conference, 28-30th=20
> >>
> >>June in Norway=20
> >>
> >>>>http://2004/guadec.org=20
> >>
> >>_______________________________________________
> >>
> >>>>NFS maillist  -  NFS@lists.sourceforge.net
> >>>>https://lists.sourceforge.net/lists/listinfo/nfs
> >>>>
> >>>
> >>>
> >>>
> >>>-------------------------------------------------------
> >>>This SF.Net email is sponsored by: GNOME Foundation
> >>>Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.=20
> >>>GNOME Users and Developers European Conference, 28-30th=20
> >>
> >>June in Norway=20
> >>
> >>>http://2004/guadec.org=20
> >>
> >>_______________________________________________
> >>
> >>>NFS maillist  -  NFS@lists.sourceforge.net
> >>>https://lists.sourceforge.net/lists/listinfo/nfs
> >>>
> >>
> >=20
> >=20
>=20
>=20


-------------------------------------------------------
This SF.Net email is sponsored by: GNOME Foundation
Hackers Unite!  GUADEC: The world's #1 Open Source Desktop Event.
GNOME Users and Developers European Conference, 28-30th June in Norway
http://2004/guadec.org
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
