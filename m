From: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
Subject: Re: questions for exportfs
Date: Fri, 17 Oct 2003 13:23:32 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031017132308.4900.KAKMY@mvh.biglobe.ne.jp>
References: <20030623152823.6981.KAKMY@mvh.biglobe.ne.jp> <16131.34681.2156.480079@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAMFL-000428-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Oct 2003 21:29:52 -0700
Received: from rcpt-expgw.biglobe.ne.jp ([202.225.89.166])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1AAMBh-0001kk-03
	for nfs@lists.sourceforge.net; Thu, 16 Oct 2003 21:26:05 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16131.34681.2156.480079@gargle.gargle.HOWL>
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


On Thu, 3 Jul 2003 11:31:37 +1000
Neil Brown <neilb@cse.unsw.edu.au> wrote:

> On Monday June 23, kakmy@mvh.biglobe.ne.jp wrote:
> > hello,
> >=20
> > I'm having 2 question for doing of exportfs command on linux.
> > Please, reply question.
> >=20

=2E.. cut

> > 2. While a nfs client is mounting shared directory with wild card
> > type (or other type except MCL_FQDN), modified options
> > don't reflect to a client even if options of mounted entry is=20
> > modified by exportfs.
> > But in MCL_FQDN type this go well.
> >=20
> > show the example
>=20
> (very clear example cut out).
>=20
> >=20
> > What reason would exportfs not immediately reflect modified options
> > with wild card type (or other type except MCL_FQDN) to client ?
> >=20
>=20
> Again, bad code.
>=20
> >=20
> > Can I deal with the following ?
> >=20
> > In function exports_update of utils/exportfs/exportfs.c:
> > (1)Find entry that belong entry with modified options
> > in exportlist of type except FQDN from exportlist of
> > FQDN type,
> > (2)Set modified options to that entry.
> > (3)After that reflect it client by original update code.
> >=20
>=20
> uhm... something like that.
> The following patch fixes both the problems, has been commited to the
> nfs-utils CVS on sourceforge and will be in the next release of
> nfs-utils.
> Thankyou very much for your helpful report.
>=20
> NeilBrown
>=20
>=20

=2E.. cut other explanation


The above patch for question no. 2 has a case where it will fail.
This occurs when these are multiple entries of the same type
for the same path that match a given client.

System: GNU-Debian/Linux=20
Architecture: i386
Package: nfs-utils-1.0.5-1


sample:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
cat /etc/netgroup

netg-hosts1 (nfsclient1,,)
netg-hostsall (,,)


=3D=3Dserver

# exportfs -vo rw @netg-hosts1:/nfspub
exporting @netg-hosts1:/nfspub
# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
# exportfs -v
/nfspub         @netg-hosts1(rw,wdelay,root_squash)
/share1         <world>(rw,wdelay,root_squash)
#


=3D=3Dclient1

# mount -t nfs nfsserver:/nfspub /pub1
# touch /pub1/tmp1-1
# ls -l /pub1
total 0
-rw-r--r--    1 nobody   nogroup         0 Oct 10  2003 tmp1-1
#


=3D=3Dserver

#
# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/nfspub nfsclient1.test.co.jp(rw,root_squash,sync,wdelay) # xxx.xx.x.xx
# exportfs -vo rw,no_root_squash @netg-hosts1:/nfspub
exporting @netg-hosts1:/nfspub
reexporting nfsclient1.test.co.jp:/nfspub to kernel
#
# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/nfspub nfsclient1.test.co.jp(rw,no_root_squash,sync,wdelay) # xxx.xx.x.xx
# exportfs -v
/nfspub         @netg-hosts1(rw,wdelay,no_root_squash)
/share1         <world>(rw,wdelay,root_squash)
#


=3D=3Dclient1

# touch /pub1/tmp1-2
# ls -l /pub1
total 0
-rw-r--r--    1 nobody   nogroup         0 Oct 10  2003 tmp1-1
-rw-r--r--    1 root     root            0 Oct 10  2003 tmp1-2
#


=3D=3Dserver

# exportfs -vo rw @netg-hostsall:/nfspub
exporting @netg-hostsall:/nfspub
# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/nfspub nfsclient1.test.co.jp(rw,no_root_squash,sync,wdelay) # xxx.xx.x.xx
# exportfs -v
/nfspub         @netg-hostsall(rw,wdelay,root_squash)
/nfspub         @netg-hosts1(rw,wdelay,no_root_squash)
/share1         <world>(rw,wdelay,root_squash)
#


=3D=3Dclient2

# mount -t nfs nfsserver:/nfspub /pub1
# touch /pub1/tmp2-1
# ls -l /pub1
total 0
-rw-r--r--    1 nfsnobod nfsnobod        0 Oct 10 17:20 tmp1-1
-rw-r--r--    1 root     root            0 Oct 10 17:21 tmp1-2
-rw-r--r--    1 nfsnobod nfsnobod        0 Oct 10 17:26 tmp2-1
#


=3D=3Dserver

# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/nfspub nfsclient2.test.co.jp(rw,root_squash,sync,wdelay) # xxx.xx.x.xx
/nfspub nfsclient1.test.co.jp(rw,no_root_squash,sync,wdelay) # xxx.xx.x.xx
# exportfs -vo rw,root_squash @netg-hosts1:/nfspub
exporting @netg-hosts1:/nfspub
# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/nfspub nfsclient2.test.co.jp(rw,root_squash,sync,wdelay) # xxx.xx.x.xx
/nfspub nfsclient1.test.co.jp(rw,no_root_squash,sync,wdelay) # xxx.xx.x.xx
# exportfs -v
/nfspub         @netg-hosts1(rw,wdelay,root_squash)
/nfspub         @netg-hostsall(rw,wdelay,root_squash)
/share1         <world>(rw,wdelay,root_squash)
#


=3D=3Dclient1

# touch /pub1/tmp1-3
# ls -l /pub1
total 0
-rw-r--r--    1 nobody   nogroup         0 Oct 10 17:20 tmp1-1
-rw-r--r--    1 root     root            0 Oct 10  2003 tmp1-2
-rw-r--r--    1 root     root            0 Oct 10  2003 tmp1-3
-rw-r--r--    1 nobody   nogroup         0 Oct 10  2003 tmp2-1
#
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D


When we execute the exportfs command at the first place, it registers
an entry data on an exportlist by each type. And new or modified entry
data is registered as the last entry of the exportlist.
When the exportfs checks whether the entry an nfs client belongs to is
modified, the exportfs searches the entry data from the head of it.
In the case where there are multiple entries that match a given client,
an absolute entry data is registered before a modified entry data on the
exportlist. And the exportfs finds absolute entry data earlier than modifie=
d
entry data. And so the exportfs decides not to update the nfs client.

This problem can be resolved by registering new or modified data ahead.
I think that the following patch works good.
(This patch always reflects modified entry data an nfs client.)

And this pacth resolves the following problem too.


On Wed, 09 Jul 2003 20:20:32 +0900
fumihiko kakuma <kakmy@mvh.biglobe.ne.jp> wrote:
subject: [NFS] exporfs no keep sequence of etab entry

> Hello,
>=20
> When we added a entry by exportfs command or changed it,
> the sequence of entry of etab file becomes, except added or
> changed entry, reverse the last time.
>=20
> Therefore the priority of entry applied nfs client isn't kept.
> This occures on all entry type.


Does the following patch have any problems ?

patch:

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D
--- nfs-utils-1.0.5.orig/support/export/export.c        Fri Sep 26 10:08:08=
 2003
+++ nfs-utils-1.0.5/support/export/export.c     Tue Oct 14 18:12:04 2003
@@ -129,7 +129,7 @@
                xlog(L_FATAL, "unknown client type in export_add");

        epp =3D exportlist + type;
-       while (*epp && slen < strlen((*epp)->m_export.e_path))
+       while (*epp && slen <=3D strlen((*epp)->m_export.e_path))
                epp =3D &((*epp)->m_next);
        exp->m_next =3D *epp;
        *epp =3D exp;
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D

--=20
fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
