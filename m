From: Jonas Jonsson <jonas@websystem.se>
Subject: Problem with NFS4,
 Error: state recovery failed on NFSv4 server 192.168.0.1 with error
 121
Date: Sun, 16 Sep 2007 19:45:00 +0200
Message-ID: <358c6ad3a55609518d1dfa15ef1f2bd2@imap.u7.se>
Reply-To: jonas@websystem.se
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWy3k-0000Cw-H2
	for nfs@lists.sourceforge.net; Sun, 16 Sep 2007 10:37:28 -0700
Received: from gonzzor.campus.luth.se ([130.240.199.196] helo=bender.u7.se)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IWy3n-0004oJ-T7
	for nfs@lists.sourceforge.net; Sun, 16 Sep 2007 10:37:33 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


I've been trying to install an NFS4 server for sometime now.



I have a machine running Gentoo AMD64 stable with kernel

gentoo-sources-2.6.22-r5.



I have compiled the server with these nfs related options



jonas@bender /mnt $ cat /boot/config-2.6.22-gentoo-r5-1 | grep NFS

CONFIG_NFS_FS=m

CONFIG_NFS_V3=y

# CONFIG_NFS_V3_ACL is not set

CONFIG_NFS_V4=y

CONFIG_NFS_DIRECTIO=y

CONFIG_NFSD=m

CONFIG_NFSD_V3=y

# CONFIG_NFSD_V3_ACL is not set

CONFIG_NFSD_V4=y

CONFIG_NFSD_TCP=y

CONFIG_NFS_COMMON=y



I have these modules loaded

jonas@bender /mnt $ lsmod

Module                  Size  Used by

nfs                   254744  0 

nfsd                  255848  17 

exportfs                5632  1 nfsd

lockd                  69040  3 nfs,nfsd

sunrpc                172936  12 nfs,nfsd,lockd



I have nfs-utils-1.1.0 installed



I have rpc.idmapd, rpc.statd, rpc.mountd running

jonas@bender /mnt $ ps uax | grep rpc

nobody   23084  0.0  0.0   3736   680 ?        Ss   18:00   0:00

/sbin/rpc.statd

root     23114  0.0  0.0   8056   884 ?        Ss   18:00   0:00

/usr/sbin/rpc.mountd

root     23120  0.0  0.0      0     0 ?        S<   18:00   0:00 [rpciod/0]

root     23124  0.0  0.0      0     0 ?        S<   18:00   0:00 [rpciod/1]

root     23192  0.0  0.2  17836  2368 ?        Ss   18:00   0:00

/usr/sbin/rpc.idmapd



I have this in my /etc/exports

/tmp    192.168.0.0/24(sync,ro,no_subtree_check,nohide,fsid=root)



If I mount it on the same machine

jonas@bender /mnt $ sudo mount -t nfs4 bender:/ /mnt/nfs



I can do an normal ls -la in the directory if I'm not standing in it

jonas@bender /mnt $ ls nfs

But If I cd to nfs then do an ls it doesn't work

jonas@bender /mnt/nfs $ ls

Then the ls process hangs and the syslog starts to flodd with

Error: state recovery failed on NFSv4 server 192.168.0.1 with error 121



This occurs if I try to read a file also.



Sometimes, not very often I get lines like this, seems to come when I kill

-9 the ls process.

Error: state recovery failed on NFSv4 server 192.168.0.1 with error 2



I have tried with some different kernels and version of nfs-utils but all

of them gives the same error.



The server machine is running ResierFS on top of LVM on top of RAID5. But I

have tried with a external USB stick and it's the same problem.



Any help on solving this problem is very appreciated.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
