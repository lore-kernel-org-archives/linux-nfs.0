From: "Pascal A. Dupuis" <Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org>
Subject: [NFS] Mapping ?
Date: Tue, 12 Feb 2008 20:40:41 +0100
Message-ID: <20080212194040.GA16370@example.org>
Reply-To: Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:52551 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764020AbYBLTlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 14:41:31 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JP10M-0001ox-Qa
	for linux-nfs@vger.kernel.org; Wed, 13 Feb 2008 06:41:23 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

next batch of problems. 
Server setup: I created a /srv/nfsv4 dir, then mounted 3 dir there
using the bind option: "/backup on /srv/nfsv4/backup type bind
(rw,bind)" and so on. The /etc/exports contains ONE dir:
/srv/nfsv4	   192.168.1.2(root_squash,rw,sync,fsid=0,crossmnt,subtree_check)

rpc.imapd running, /etc/idmapd.conf minimalistic as explained in the
nfs-howto

On the client side, mounting immediatly results in the following
message: rpc.idmapd[3299]: nss_getpwnam: name '0' does not map into domain 'localdomain' 
 
Then,
`ls -al the_mounted_dir`
drwxr-xr-x  7 nobody  nogroup 4096 2007-11-28 10:07 backup
So far so good, but ...
`ls -al the_mounted_dir/backup`
kernel: fsid 0:13: expected fileid 0x2, got 0x802a

The file /etc/nsswitch.conf contains "passwd:         compat"

Both server and client running Debian testing, with the package as
nfs-kernel-server/lenny uptodate 1:1.1.1-12
Kernel is 2.6.24.2.

Any idea ?

While at the subject, is there a simple way to map UID x on the server
onto UID y on the client ?

TIA

Pascal Dupuis

-- 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

