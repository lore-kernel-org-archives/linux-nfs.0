From: David Ford <david+cert@blue-labs.org>
Subject: NFS problems across reboot
Date: Thu, 04 Apr 2002 14:27:56 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CACA93C.5010304@blue-labs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Received: from 60.54.252.64.snet.net
	([64.252.54.60] helo=hotmale.boyland.org ident=kaliuser)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tCqB-0000YS-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Apr 2002 11:24:12 -0800
Received: from blue-labs.org (david@hb [10.0.0.6])
	(authenticated bits=0)
	by hotmale.boyland.org (8.12.2/8.12.2) with ESMTP id g34JNK0S001735
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NO)
	for <nfs@lists.sourceforge.net>; Thu, 4 Apr 2002 14:23:21 -0500
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

After rebooting my NFS server, the clients can no longer access the mounts.

A trimmed df shows:

james:/home/james            0         1         0   0% /home/james
james:/home/hnc              0         1         0   0% /home/hnc

# su - xyz
su: warning: cannot change directory to /home/james/x/xyz: Permission denied
bash: /home/james/x/xyz/.bash_profile: Permission denied

However:

# rpcinfo -p james
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100005    1   udp  10000  mountd
    100005    1   tcp  10000  mountd
    100005    2   udp  10000  mountd
    100005    2   tcp  10000  mountd
    100005    3   udp  10000  mountd
    100005    3   tcp  10000  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  10001  nlockmgr
    100021    3   udp  10001  nlockmgr
    100021    4   udp  10001  nlockmgr
    100024    1   udp  10002  status
    100024    1   tcp  10001  status

# umount /home/hnc
# mount /home/hnc

And the hnc mount is fine again.  After repeating with /home/james, that 
mount is also fine.

Why do I need to umount and remount?  This is pretty brutal when I need 
to shutdown services so the mounts aren't in use.

These are 2.4.18+ kernels with nfs utils from about a month ago.

David



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
