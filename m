From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: nfsprog support
Date: Thu, 15 Apr 2004 23:31:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404152331.47440.bernd-schubert@web.de>
References: <200404151750.53209.bernd-schubert@web.de> <200404152040.06227.bernd-schubert@web.de> <1082057977.7141.31.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BEESo-0002C6-2t
	for nfs@lists.sourceforge.net; Thu, 15 Apr 2004 14:32:02 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BEESn-0001oM-B8
	for nfs@lists.sourceforge.net; Thu, 15 Apr 2004 14:32:01 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1082057977.7141.31.camel@lade.trondhjem.org>
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

=2D----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thursday 15 April 2004 21:39, Trond Myklebust wrote:
> P=E5 to , 15/04/2004 klokka 11:39, skreiv Bernd Schubert:
> > nfsprog=3Dn	Use  an  alternate  RPC  program number to contact the
> > 			NFS daemon on the remote host.
> > 			This option is useful for hosts that can run multiple NFS servers.=20
> > The default value  is 100003 which is the standard RPC NFS daemon progr=
am
> > number.
>
> So, just out of curiosity... Why would anyone prefer to do this rather
> than just having the NFS servers run on different ports, and then using
> the 'port=3D' option?
>
> AFAICS, the only difference there is that you get somewhat dubious extra
> support in the form of a separate portmapper entry for each NFS daemon.
> However given that you still have to feed the NFS client the special
> "nfsprog" number, is there really any benefit to doing this over just
> fixing a set of alternate port numbers that your "mount" can probe?
>

Hello Trond,

as I wrote, we want to use NFSv3 for knfs and userspace nfs, just take a=20
look at the following rpcinfo tables:

Only the kernel nfs daemon is running:

beno:/home/bernd/src/unfs3/unfs3-0.9.8# /etc/init.d/nfs-kernel-server start
Exporting directories for NFS kernel daemon...done.
Starting NFS kernel daemon: nfsd mountd.
beno:/home/bernd/src/unfs3/unfs3-0.9.8# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp    679  sgi_fam
    100024    1   udp    795  status
    100024    1   tcp    798  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100021    1   tcp  32774  nlockmgr
    100021    3   tcp  32774  nlockmgr
    100021    4   tcp  32774  nlockmgr
    100005    1   udp    931  mountd
    100005    1   tcp    934  mountd
    100005    2   udp    931  mountd
    100005    2   tcp    934  mountd
    100005    3   udp    931  mountd
    100005    3   tcp    934  mountd


Now I start the unfs3 daemon on port 2050:

beno:/home/bernd/src/unfs3/unfs3-0.9.8# ./unfsd -n 2050
beno:/home/bernd/src/unfs3/unfs3-0.9.8# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    391002    2   tcp    679  sgi_fam
    100024    1   udp    795  status
    100024    1   tcp    798  status
    100003    2   udp   2049  nfs
    100003    2   tcp   2049  nfs=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D> here the old (knfsd) information disappeared
    100021    1   udp  32775  nlockmgr
    100021    3   udp  32775  nlockmgr
    100021    4   udp  32775  nlockmgr
    100021    1   tcp  32774  nlockmgr
    100021    3   tcp  32774  nlockmgr
    100021    4   tcp  32774  nlockmgr
    100005    2   udp    931  mountd
    100005    2   tcp    934  mountd
    100003    3   udp   2050  nfs
    100003    3   tcp   2050  nfs
    100005    1   udp    938  mountd
    100005    3   udp    938  mountd
    100005    1   tcp    939  mountd
    100005    3   tcp    939  mountd

You can see that the previous program: 100003  vers: 3  nfs information hav=
e disappeared.

As I expected, mounting on port 2049 with nfsvers=3D3 now fails:

beno:/home/bernd/src/unfs3/unfs3-0.9.8# mount -t nfs -o port=3D2049,nfsvers=
=3D3 localhost:/home /mnt/test1
NFSv3 not supported!
mount: wrong fs type, bad option, bad superblock on localhost:/home,
       or too many mounted file systems

Of course it also works if one only runs the knfsd or if one specifies nfsv=
ers=3D2.


On port 2050 with unfsd it works, of course:

beno:/home/bernd/src/unfs3/unfs3-0.9.8# mount -t nfs -o port=3D2050,nfsvers=
=3D3 localhost:/home /mnt/test2
beno:/home/bernd/src/unfs3/unfs3-0.9.8#


What you suggested is our current workaround, cNFS runs NFSv2=20
and kNFS runs NFSv3. However, as I wrote, with unfs3 we would like to=20
run NFSv3 for both. AFAIK this only works by running one of the daemons
on another rpc-program number.


Thanks,
	Bernd
=2D----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAfv8/C8BUnAF+ydYRAiDsAKCBJYDiAci7FmYGnTj5PhyFVUoYRACdHaWz
S5qjzka+YxqNM0th9Bd0QYI=3D
=3DX8lX
=2D----END PGP SIGNATURE-----


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
