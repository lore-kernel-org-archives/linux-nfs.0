From: Bernhard Busch <bbusch@biochem.mpg.de>
Subject: NFS mount problem (2000 NFS filesystems) of linux clients to
 a solaris server
Date: Thu, 08 Mar 2007 13:42:37 +0100
Message-ID: <45F004BD.1070500@biochem.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: NFS@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi



I tried to mount 2000 filesystems from a
Sun Solaris Fileserver with the ZFS Filesystem
via NFS on Linux Clients.

Reason: Sun Solaris ZFS is a hierarchical filesystem
        with a separate filesystem for a specific user
        with quota support. We have approximately
        2000 User and pool-folders.


It is possible to export these 2000 filesystems on the server (sun solaris)
and  to  mount these 2000 nfs filesystem on sgi and solaris
clients without any problems.


On Linux Clients (SLES10, Suse10.2)  i get =

error messages like the following ones:

nfs bindresvport: Address already in use
nfs bindresvport: Address already in use
nfs bindresvport: Address already in use
mount: solaris10-02:/fs/DISK/disk1998: can't read superblock
mount: solaris10-02:/fs/DISK/disk1999: can't read superblock
mount: solaris10-02:/fs/DISK/disk2000: can't read superblock



Any help?


Bernhard

-- =

Dr. Bernhard Busch
Max-Planck-Institut f=FCr Biochemie
Rechenzentrum
Am Klopferspitz 18a
D-82152 Martinsried
Tel: +49(89)8578-2582
Fax: +49(89)8578-2479
Email bbusch@biochem.mpg.de



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
