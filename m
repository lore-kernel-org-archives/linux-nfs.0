From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Wed, 24 Nov 2004 11:05:26 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4B57@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CX2SN-0001ou-J8
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 11:05:35 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CX2SK-0007s9-LW
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 11:05:35 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
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

> However now the tar extraction goes very fast but stops 1 or=20
> 2  or  and=20
> restart fast -> there are some hangs. Here with a 16MB=20
> journal I got 15=20
> hangs of 1-2 seconds, with a 128 MB I get only 3 hangs but=20
> they last 4or=20
> 5 seconds. I checked at a momment of an hang on the nfs server with=20
> iostat, and disk utilisation goes from a few % to  316 % in=20
> the exemple=20
> below (for 128 MB journal withing the 4 seconds hangs it goes=20
> to 4700 % !)
> Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s    rkB/s=20
>    wkB/s=20
> avgrq-sz avgqu-sz   await  svctm  %util
> /dev/emcpowerl2
>              0.00 150.67 97.33 224.00  768.00 3018.67   384.00 =20
> 1509.33    11.78    33.33   19.79   9.83 316.00
>=20
> Maybe it hangs because the journal commits on the SP ! ?

i'll leave that to NFS performance experts.  in general, increasing the
size of the journal means that the physical file system can handle a
higher transaction rate, so you are going in the right direction.  but i
don't have any specific knowlege about journal sizing best practices.

> Well, finally, is this safer in terms of performances to externalize=20
> journal than using async export ?

neil recommends mirroring the journal, but imho, that may not be
necessary.  if the journal disk goes bad, you can just fsck the RAID5
array and replace the journal disk.  otherwise, yes, you should use the
"sync" export option and a separate journal disk for best data integrity
and good performance.

> And is it possible to externalize a journal on an already=20
> existing ext3 FS or do we need to reformat it ?

i'm just guessing, but i think you can do this.  you should be able to
disable journaling on the existing FS, then re-enable it with the new
journal device.  naturally you should back up your file system before
trying anything.

> jehan procaccia wrote:
>=20
> > Lever, Charles wrote:
> >
> >>
> >> btw, it is fairly well understood that RAID-5 and NFS=20
> servers don't mix
> >> well.  RAID-5's weakest point is that it doesn't handle=20
> small random
> >> writes very well, and that's exactly what is required of it when
> >> handling NFS traffic that consists mostly of metadata changes (file
> >> creates, deletes, and so on).  neil explained clearly how=20
> to make the
> >> best use of a RAID-5 with NFS: do your local file system journaling
> >> somewhere else.
> >> =20
> >>
> > No, not yet, but  if it is safer and increase performances maybe I=20
> > should do it !
> >
> > Perhaps it's not the place to talk about ext3 here, but if=20
> someone on=20
> > the list did already put their journal on a separate device, please=20
> > confirm me those points:
> > From what I read on man mkefs for ext3 FS I can create a=20
> journal on a=20
> > separate FS :
> > mke2fs -O journal_dev external-journal
> > creates the journal FS, on which device ? -> internal scsi=20
> drive of my=20
> > server or better placed on the dell/EMC SP ?
> >
> > mke2fs -J device=3D/dev/external-journal /dev/emcpower
> > Format the FS and use the external journal just create=20
> above, but what=20
> > is the recommended size of the external journal ?  when journal is=20
> > internal it is said  the size of the journal must be at least 1024=20
> > filesystem blocks
> > (in my case blocks a 4K size) so journal is at least 4 Mb,=20
> but should=20
> > it be bigger ?
> >
> > Finally, can I "externalize" an already internal journal from=20
> > production FS  (convert journal from inside to outside without=20
> > reformating the FS ) ?
> >
> > thanks.
> >
> >
> >> when trying your workload locally on the NFS server,=20
> realize that there
> >> are some optimizations that local file systems make, like=20
> caching and
> >> coalescing metadata updates, that the NFS protocol does=20
> not allow.  this
> >> affects especially workloads with lots of metadata change=20
> operations,
> >> because the NFS protocol requires each metadata update to reside on
> >> permanent storage before the NFS server replies to the client,
> >> effectively serializing the workload with storage activity.
> >> =20
> >>
> >
> >
> >
> > -------------------------------------------------------
> > SF email is sponsored by - The IT Product Guide
> > Read honest & candid reviews on hundreds of IT Products=20
> from real users.
> > Discover which products truly live up to the hype. Start=20
> reading now.=20
> > http://productguide.itmanagersjournal.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs
>=20
>=20
>=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
