From: InsaneToucan <insanetoucan@gmail.com>
Subject: mounting tmpfs: permission denied
Date: Fri, 30 Mar 2007 15:16:41 -0600
Message-ID: <1c9889d10703301416s6c1a8b38h54d653036d9ed1cf@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1482005882=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXOSh-00065c-AC
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 14:16:43 -0700
Received: from wr-out-0506.google.com ([64.233.184.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HXOSh-0005op-1V
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 14:16:45 -0700
Received: by wr-out-0506.google.com with SMTP id i20so1407645wra
	for <nfs@lists.sourceforge.net>; Fri, 30 Mar 2007 14:16:41 -0700 (PDT)
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

--===============1482005882==
Content-Type: multipart/alternative;
	boundary="----=_Part_85969_2212863.1175289401181"

------=_Part_85969_2212863.1175289401181
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,

Some environment info [server]:

$ uname -a
Linux joz 2.6.20 #4 SMP Wed Mar 28 22:03:35 CDT 2007 x86_64 Dual Core AMD
Opteron(tm) Processor 870 AuthenticAMD GNU/Linux

nfs-utils v1.0.12

$ zgrep "NFS" /proc/config.gz
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_NFSD_TCP=y
CONFIG_ROOT_NFS=y
CONFIG_NFS_COMMON=y

$ cat /etc/exports
/pu 10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)
/tmpfs 10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)

$ cat /proc/mounts | grep /tmpfs
none /tmpfs tmpfs rw 0 0

For the client:

$ uname -a
Linux woa 2.6.20.2 #2 SMP Thu Mar 15 10:19:39 PDT 2007 x86_64 AMD
Opteron(tm) Processor 246 AuthenticAMD GNU/Linux

$ zgrep "NFS" /proc/config.gz
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
# CONFIG_NFS_V3_ACL is not set
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=y
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V3_ACL is not set
# CONFIG_NFSD_V4 is not set
CONFIG_NFSD_TCP=y
CONFIG_ROOT_NFS=y
CONFIG_NFS_COMMON=y

nfs-utils v1.0.12

The following fails on the client (after a exportfs -ra on the server):

$ mount -o ro 10.1.2.130:/tmpfs /a
mount: 10.1.2.130:/tmpfs failed, reason given by server: Permission denied

Some things I know:

- NFS is working properly, I'm able to mount /pu (the other export) on the
client without incident.
- It seems like both the server and client kernels (.20+) are patched with
the following patch: http://lkml.org/lkml/diff/2006/9/28/465/1

I'm not sure if I've just missed an option to mount or something deeper.

TIA

------=_Part_85969_2212863.1175289401181
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hello,<br><br>Some environment info [server]:<br><br>$ uname -a<br>Linux joz 2.6.20 #4 SMP Wed Mar 28 22:03:35 CDT 2007 x86_64 Dual Core AMD Opteron(tm) Processor 870 AuthenticAMD GNU/Linux<br><br>nfs-utils v1.0.12<br><br>
$ zgrep &quot;NFS&quot; /proc/config.gz<br>CONFIG_NFS_FS=y<br>CONFIG_NFS_V3=y<br># CONFIG_NFS_V3_ACL is not set<br># CONFIG_NFS_V4 is not set<br># CONFIG_NFS_DIRECTIO is not set<br>CONFIG_NFSD=y<br>CONFIG_NFSD_V3=y<br># CONFIG_NFSD_V3_ACL is not set
<br># CONFIG_NFSD_V4 is not set<br>CONFIG_NFSD_TCP=y<br>CONFIG_ROOT_NFS=y<br>CONFIG_NFS_COMMON=y<br><br>$ cat /etc/exports<br>/pu <a href="http://10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)">10.1.2.0/255.255.255.0(async,no_subtree_check,rw,no_root_squash)
</a><br>/tmpfs <a href="http://10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)">10.1.2.0/255.255.255.0(ro,no_root_squash,no_subtree_check)</a><br><br>$ cat /proc/mounts | grep /tmpfs<br>none /tmpfs tmpfs rw 0 0
<br><br>For the client:<br><br>$ uname -a<br>Linux woa <a href="http://2.6.20.2">2.6.20.2</a> #2 SMP Thu Mar 15 10:19:39 PDT 2007 x86_64 AMD Opteron(tm) Processor 246 AuthenticAMD GNU/Linux<br><br>$ zgrep &quot;NFS&quot; /proc/config.gz
<br>CONFIG_NFS_FS=y<br>CONFIG_NFS_V3=y<br># CONFIG_NFS_V3_ACL is not set<br># CONFIG_NFS_V4 is not set<br># CONFIG_NFS_DIRECTIO is not set<br>CONFIG_NFSD=y<br>CONFIG_NFSD_V3=y<br># CONFIG_NFSD_V3_ACL is not set<br># CONFIG_NFSD_V4 is not set
<br>CONFIG_NFSD_TCP=y<br>CONFIG_ROOT_NFS=y<br>CONFIG_NFS_COMMON=y<br><br>nfs-utils v1.0.12<br><br>The following fails on the client (after a exportfs -ra on the server):<br><br>$ mount -o ro 10.1.2.130:/tmpfs /a<br>mount: 
10.1.2.130:/tmpfs failed, reason given by server: Permission denied<br><br>Some things I know:<br><br>- NFS is working properly, I&#39;m able to mount /pu (the other export) on the client without incident.<br>- It seems like both the server and client kernels (.20+) are patched with the following patch: 
<a href="http://lkml.org/lkml/diff/2006/9/28/465/1">http://lkml.org/lkml/diff/2006/9/28/465/1</a><br><br>I&#39;m not sure if I&#39;ve just missed an option to mount or something deeper.<br><br>TIA<br>

------=_Part_85969_2212863.1175289401181--


--===============1482005882==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============1482005882==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1482005882==--
