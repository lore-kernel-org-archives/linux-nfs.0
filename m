From: Santiago <santi@mleads.com>
Subject: RedHat/Mandrake NFS - not playing nice
Date: Mon, 17 Feb 2003 09:41:20 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E5110B0.6000002@mleads.com>
Reply-To: santi@mleads.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [64.92.112.32] (helo=mail.hosting-advantage.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18koK2-0001XB-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Feb 2003 08:40:50 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello. I usually don't mail lists without joining. Maybe I won't after 
this either. Here is the problem:

Export filesytem (/var/www/html) from RedHat 7.3 to Mandrake 9.0 (mount 
point /tmp/test or /r/amanda/nitro-html) fails with:

[root@backup amanda]# mount 10.0.0.48:/var/www/html /r/amanda/nitro-html 
-t nfs
mount: 10.0.0.48:/var/www/html failed, reason given by server: 
Permission denied
[root@backup amanda]#

However, there are no problems mounting the exported dir (or any others) 
on other Redhat machines or debian machines (only unices handy).

The RedHat 7.3 is stock everything (stock nfs-utils, stock kernel 
(non-enterprise)).
The Mandrake 9.0 is stock distro with kernel 2.4.19-ac4 (custom) with 
NFS support compiled in.

/etc/exports:
/var/www/html 10.0.0.0/255.255.255.0(rw,no_root_squash)
#/var/lib/mysql/OldMaid 10.0.0.10/255.255.255.0(rw,no_root_squash)

rpcinfo -p (RedHat 7.3):
[root@chance proc]# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32768  status
     100024    1   tcp  32768  status
     391002    2   tcp  32769  sgi_fam
     100011    1   udp    740  rquotad
     100011    2   udp    740  rquotad
     100011    1   tcp    743  rquotad
     100011    2   tcp    743  rquotad
     100005    1   udp  32817  mountd
     100005    1   tcp  32940  mountd
     100005    2   udp  32817  mountd
     100005    2   tcp  32940  mountd
     100005    3   udp  32817  mountd
     100005    3   tcp  32940  mountd
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100021    1   udp  32818  nlockmgr
     100021    3   udp  32818  nlockmgr
     100021    4   udp  32818  nlockmgr
[root@chance proc]#

rpcinfo -p (Mandrake 9.0):
[root@backup amanda]# rpcinfo -p
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    710  rquotad
     100011    2   udp    710  rquotad
     100011    1   tcp    713  rquotad
     100011    2   tcp    713  rquotad
     100003    2   udp   2049  nfs
     100021    1   udp  33816  nlockmgr
     100021    3   udp  33816  nlockmgr
     100005    1   udp  33817  mountd
     100005    1   tcp  32805  mountd
     100005    2   udp  33817  mountd
     100005    2   tcp  32805  mountd
[root@backup amanda]#

I have read the howto and googled for mandrake-RH NFS interaction but 
not found anything of use to this problem. I have disabled ipchains and 
iptables on both boxes and verfified that nothing is present in the 
/etc/hosts.allow | /etc/hosts.deny files on either machine.

Like indicated above, the RH export works fine so long as I don't 
attempt to mount it on a Mandrake box.

TIA,

Santiago




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
