From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: nfs-utils 1.0.5 break amd?
Date: 31 Jul 2003 19:32:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1059672742.21271.58.camel@ikarus>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19iHHu-0008Lh-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 10:32:26 -0700
Received: from localhost (localhost [127.0.0.1])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id 591C65C839
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 19:32:22 +0200 (MEST)
Received: from medoc.inf.ethz.ch ([127.0.0.1])
 by localhost (medoc [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 01704-01-3 for <nfs@lists.sourceforge.net>;
 Thu, 31 Jul 2003 19:32:21 +0200 (MEST)
Received: from ikarus (ikarus.inf.ethz.ch [129.132.10.58])
	by medoc.inf.ethz.ch (Postfix) with ESMTP id A90645C830
	for <nfs@lists.sourceforge.net>; Thu, 31 Jul 2003 19:32:21 +0200 (MEST)
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

Hi all,

After upgrading a RedHat 7.3 box with kernel 2.4.18-27.7xsmp from
nfs-utils 1.0.3 to 1.0.5, amd stopped working.

On the client (am-utils-6.0.7-4, nfs-utils-0.3.3-6.73), I issue:

ls /net/<fileserver>

With 1.0.3, I get the correct directory listing under /net/<fileserver>

With 1.0.5, I get:
ls: /net/<fileserver>: Input/output error


On the server, with 1.0.3, I'd see an entry for every export in
/etc/exports in /var/log/messages, mount refused or granted, according
to the export permissions. 
With 1.0.5, I get one single entry:
Jul 31 19:14:34 <fileserver> rpc.mountd: export request from <client>


For 1.0.5, the client reports the following errors in /var/log/messages:
Jul 31 19:24:04 <client> amd[1072]: No fs type specified (key =
"/defaults", map = ""root"")
Jul 31 19:24:04 <client> amd[1072]: get_nfs_version NFS(3,tcp) failed
for <fileserver>: : RPC: Program not registered
Jul 31 19:24:04 <client> amd[1072]: get_nfs_version: returning (3,udp)
on host <fileserver>
Jul 31 19:24:04 <client> amd[1072]: Using NFS version 3, protocol udp on
host <fileserver>
Jul 31 19:24:04 <client> amd[1072]: Flushed /net/<fileserver>; dependent
on <fileserver>
Jul 31 19:24:04 <client> amd[1072]: recompute_portmap: NFS version 3
Jul 31 19:24:04 <client> amd[1072]: Using MOUNT version: 3
Jul 31 19:24:04 <client> amd[1072]: get_nfs_version NFS(3,tcp) failed
for <fileserver>: : RPC: Program not registered
Jul 31 19:24:04 <client> amd[1072]: get_nfs_version: returning (3,udp)
on host <fileserver>
Jul 31 19:24:04 <client> amd[1072]: Using NFS version 3, protocol udp on
host <fileserver>
Jul 31 19:24:04 <client> amd[25799]: amfs_host_fmount: NFS version 3
Jul 31 19:24:04 <client> amd[25799]: host_fmount rpc failed: RPC: Remote
system error
Jul 31 19:24:04 <client> amd[1072]: /net/<fileserver>: mount
(amfs_auto_cont): Input/output error

Here is my /etc/sysconfig/nfs on the server:
# For more information on nfs tuning, please see the NFS-HOWTO
# http://nfs.sourceforge.net/nfs-howto/

# Pass any additional options for mountd.
# MOUNTD_OPTIONS=

# Pin mountd to a given port rather than random one from portmapper
# MOUNTD_PORT=

# Don't advertise TCP for mount.
MOUNTD_TCP=no

# NFS V3
MOUNTD_NFS_V3=yes

# NFS V2
MOUNTD_NFS_V2=yes

# The number of open file descriptors
#MOUNTD_OPEN_FILES=128

# Pass the number of instances of nfsd (8 is default; 16 or more
# might be needed to handle heavy client traffic)
NFSDCOUNT=32

# Increase the memory limits on the socket input queues for
# the nfs processes .. NFS  benchmark SPECsfs demonstrate a
# need for a larger than default size (64kb) .. setting
# TUNE_QUEUE to yes will set the values to 256kb.
TUNE_QUEUE="yes"
NFS_QS=262144


Any idea what could be wrong? TIA

Regards,
    Marc





-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
