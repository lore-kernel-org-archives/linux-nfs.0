From: "calculix-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org" <calculix-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>
Subject: [NFS] Portmapper problem,
	no access the server after update to debian squeeze
Date: Fri, 05 Feb 2010 20:15:49 +0100
Message-ID: <4B6C6E65.1000706@online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:55556 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343Ab0BERAx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Feb 2010 12:00:53 -0500
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NdRY2-0005Lv-U4
	for linux-nfs@vger.kernel.org; Sat, 06 Feb 2010 04:00:51 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear NFS-Team,
Since I updated my server from Debian-Lenny to Squeeze I am not able 
anymore to mount, ssh, etc to my server.  I have gone through the 
nfs-howto, followed the troubleshouting process with no success.
I can reach the server with ping without any problems. Only mount, ssh, 
sftp etc. does not work. My portmapper seams not to allow the access.

Please help!

Thanks
Peter

******** Here is my /etc/exports
# /etc/exports: the access control list for filesystems which may be 
exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) 
hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/data/PUBLIC    192.168.178.27(rw,sync,no_subtree_check)
******** End of /etc/exports

******** Here is my /etc/hosts.allow
# /etc/hosts.allow: list of hosts that are allowed to access the system.
#                   See the manual pages hosts_access(5) and 
hosts_options(5).
#
# Example:    ALL: LOCAL @some_netgroup
#             ALL: .foobar.edu EXCEPT terminalserver.foobar.edu
#
# If you're going to protect the portmapper use the name "portmap" for the
# daemon name. Remember that you can only use the keyword "ALL" and IP
# addresses (NOT host or domain names) for the portmapper, as well as for
# rpc.mountd (the NFS mount daemon). See portmap(8) and rpc.mountd(8)
# for further information.
#
ALL:192.168.178.0/255.255.255.0(rw,sync)
******** End of /etc/hosts.allow

******** My /etc/hosts.deny is empty

******** Here is the output of rpcinfo -p localhost from the server
   Program Vers Proto   Port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  59341  status
    100024    1   tcp  52100  status
    100021    1   udp  43350  nlockmgr
    100021    3   udp  43350  nlockmgr
    100021    4   udp  43350  nlockmgr
    100021    1   tcp  56947  nlockmgr
    100021    3   tcp  56947  nlockmgr
    100021    4   tcp  56947  nlockmgr
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100005    1   udp  51709  mountd
    100005    1   tcp  36097  mountd
    100005    2   udp  51709  mountd
    100005    2   tcp  36097  mountd
    100005    3   udp  51709  mountd
    100005    3   tcp  36097  mountd
******* End of rpcinfo -p localhost

******* Here is the output of rpcinfo -p 192.168.178.32 from the client
rpcinfo: Portmapper kann nicht erreicht werden: RPC: Fehler des 
entfernten Systems - Verbindungsaufbau abgelehnt
******* This seams to be my problem, but what to do?

------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

