From: David Meleedy <david.meleedy@analog.com>
Subject: Intermittent RHE3-u3 client mount failures to Netapp fileserver
Date: Tue, 14 Dec 2004 19:21:13 -0500
Message-ID: <200412150021.iBF0LDNQ000848@jetcar.spd.analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CeMuv-00071i-I1
	for nfs@lists.sourceforge.net; Tue, 14 Dec 2004 16:21:21 -0800
Received: from nwd2mail2.analog.com ([137.71.25.51])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CeMut-0001tj-Cc
	for nfs@lists.sourceforge.net; Tue, 14 Dec 2004 16:21:21 -0800
Received: from nwd2mhb1.analog.com (nwd2mhb1.analog.com [137.71.5.12])
	by nwd2mail2.analog.com (8.12.10/8.12.10) with ESMTP id iBF0LIm5024760
	for <nfs@lists.sourceforge.net>; Tue, 14 Dec 2004 19:21:18 -0500
Received: from jetcar.spd.analog.com ([10.64.82.61])
	by nwd2mhb1.analog.com (8.9.3 (PHNE_28810+JAGae91741)/8.9.3) with ESMTP id TAA01891
	for <nfs@lists.sourceforge.net>; Tue, 14 Dec 2004 19:21:13 -0500 (EST)
To: nfs@lists.sourceforge.net
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


I have been trying to troubleshoot this problem on Redhat Enterprise 3
WS update 3, both iX86 and amd64 versions.  I have already sent this
to the automounter mailing list, and I suspect they don't have a
solution because it is more nfs related.

The problem is that intermittently, a previously mounted directory that
had been mounted with the automounter, and then unmounted becomes
unavailable.  The amount of time of unavailability seems to be related
to the --timeout=60 option specified to the automount program.

I don't believe the routing equipment is at fault because using the
same network ports, we have had Redhat 8 clients working just fine.

client info
===========
Red Hat Enterprise Linux WS release 3 (Taroon Update 3)
kernel: 2.4.21-20.EL
nfs-utils: 1.0.6-31EL
mount: 2.11y-31.1
autofs: 4.1.3-12

server info
===========
aflac> version
NetApp Release 6.4.2: Mon Sep 15 12:35:28 PDT 2003


This is the client rpc info:
alfalfa-56: rpcinfo -p alfalfa
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  32768  status
    100024    1   tcp  32768  status
    100007    2   udp    816  ypbind
    100007    1   udp    816  ypbind
    100007    2   tcp    819  ypbind
    100007    1   tcp    819  ypbind
    391002    2   tcp  32769  sgi_fam
    100011    1   udp    711  rquotad
    100011    2   udp    711  rquotad
    100011    1   tcp    731  rquotad
    100011    2   tcp    731  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100021    1   tcp  32770  nlockmgr
    100021    3   tcp  32770  nlockmgr
    100021    4   tcp  32770  nlockmgr
    100005    1   udp    728  mountd
    100005    1   tcp    744  mountd
    100005    2   udp    728  mountd
    100005    2   tcp    744  mountd
    100005    3   udp    728  mountd
    100005    3   tcp    744  mountd
    100001    3   udp    725  rstatd
    100001    2   udp    725  rstatd
    100001    1   udp    725  rstatd

This is the server rpc info:

alfalfa-57: rpcinfo -p aflac
   program vers proto   port
    100011    1   udp   4049  rquotad
    100021    4   tcp   4045  nlockmgr
    100021    3   tcp   4045  nlockmgr
    100021    1   tcp   4045  nlockmgr
    100021    4   udp   4045  nlockmgr
    100021    3   udp   4045  nlockmgr
    100021    1   udp   4045  nlockmgr
    100024    1   tcp   4047  status
    100024    1   udp   4047  status
    100005    3   tcp   4046  mountd
    100005    2   tcp   4046  mountd
    100005    1   tcp   4046  mountd
    100005    3   udp   4046  mountd
    100005    2   udp   4046  mountd
    100005    1   udp   4046  mountd
    100003    4   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   udp   2049  nfs
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper

The automounter is configured as follows:
/etc/sysconfig/autofs:
LOCALOPTIONS="-DSITE=nwd_ -DARCH=iX86 -DOSREL=redhat3"
DAEMONOPTIONS="--timeout=60 --verbose --debug"

/etc/auto.master

a typical entry:
/cpd            /etc/auto.cpd

I have also tried:
/cpd            /etc/auto.cpd -vers=2
(that didn't seem to fix the problem)

I am now trying:
/cpd		/etc/auto.cpd -nolock

auto.cpd is a script that returns a mount point, e.g.

alfalfa-72: /etc/auto.cpd gnu
aflac,aflac-171:/vol/vol1/cpd/${SITE}${ARCH}_${OSREL}/&


These are the kind of messages I am seeing:
============================================================================
Dec 12 06:00:37 alfalfa kernel: nfs warning: mount version older than kernel
Dec 12 06:00:37 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:37 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:37 alfalfa kernel: nfs_read_super: get root inode failed
Dec 12 06:00:37 alfalfa automount[1617]: >> mount: wrong fs type, bad option, 
ba
d superblock on aflac:/vol/vol1/cpd/nwd_local,
Dec 12 06:00:37 alfalfa automount[1617]: >>        or too many mounted file 
syst
ems
Dec 12 06:00:37 alfalfa automount[1617]: mount(nfs): nfs: mount failure 
aflac:/v
ol/vol1/cpd/nwd_local on /cpd/local
Dec 12 06:00:37 alfalfa automount[1617]: failed to mount /cpd/local
Dec 12 06:00:37 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:37 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:37 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:37 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:37 alfalfa kernel: nfs_read_super: get root inode failed
Dec 12 06:00:40 alfalfa kernel: nfs warning: mount version older than kernel
Dec 12 06:00:40 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:40 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:40 alfalfa kernel: nfs_read_super: get root inode failed
Dec 12 06:00:40 alfalfa automount[1625]: >> mount: wrong fs type, bad option, 
ba
d superblock on aflac:/vol/vol1/cpd/nwd_local,
Dec 12 06:00:40 alfalfa automount[1625]: >>        or too many mounted file 
syst
ems
Dec 12 06:00:40 alfalfa automount[1625]: mount(nfs): nfs: mount failure 
aflac:/v
ol/vol1/cpd/nwd_local on /cpd/local
Dec 12 06:00:40 alfalfa automount[1625]: failed to mount /cpd/local
Dec 12 06:00:40 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:40 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:40 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:40 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:40 alfalfa kernel: nfs_read_super: get root inode failed
Dec 12 06:00:40 alfalfa kernel: nfs warning: mount version older than kernel
Dec 12 06:00:40 alfalfa kernel: RPC: Can't bind to reserved port (98).
Dec 12 06:00:40 alfalfa kernel: nfs_get_root: getattr error = 5
Dec 12 06:00:40 alfalfa kernel: nfs_read_super: get root inode failed
Dec 12 06:00:40 alfalfa automount[1761]: >> mount: wrong fs type, bad option, 
ba
d superblock on aflac:/vol/vol1/cpd/nwd_local,
Dec 12 06:00:40 alfalfa automount[1761]: >>        or too many mounted file 
syst
ems
Dec 12 06:00:40 alfalfa automount[1761]: mount(nfs): nfs: mount failure 
aflac:/v
ol/vol1/cpd/nwd_local on /cpd/local
Dec 12 06:00:40 alfalfa automount[1761]: failed to mount /cpd/local
============================================================================

The reason I am trying "vers=2", and "nolock" nfs options to fix
this is because of this article -- so far vers=2 did not fix the problem:

http://support.trittontechnologies.com/kbarticles/nas_asap/T4133-1015.htm

I was wondering if anyone here has some better ideas of things I could
try, or if anyone knows what is going wrong here.

Thanks,

-Dave

________________________________________________________________________
David Meleedy				Analog Devices, Inc.
David.Meleedy@analog.com		Three Technology Way
Phone: 781 461 3494			Norwood, MA  02062-9106  USA




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
