From: "Pascal A. Dupuis" <Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org>
Subject: [NFS] troubles with nohide -- crossmnt
Date: Thu, 7 Feb 2008 22:36:05 +0100
Message-ID: <20080207213605.GB3034@example.org>
Reply-To: Pascal.Dupuis-s1sOSHjJPfVpcTqYljSg7g@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53753 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762405AbYBGVgo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 16:36:44 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JNEQB-0004OI-Fq
	for linux-nfs@vger.kernel.org; Fri, 08 Feb 2008 08:36:39 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'd like to export two filesystems, mounted on one another. The setup is :

some partition mounted as /home/user  (parent)
another one            as /home/user/archive  (child)

The export file contains:
/home/user/archive	192.168.1.10(rw,subtree_check,fsid=0) 
/home/user           	192.168.1.10(rw,subtree_check,fsid=0,crossmnt) 

I tried:
-setting the 'nohide' option on the child
-setting the crossmnt on the parent
-permuting the order 

Whatever case I try, on the client I ALWAYS see the child directory,
and not the parent. Any clue ?

Both systems are linux-2.6.24, debian SID, nfs-kernel-package for the
server, nfsv4 compiled as a module.

TIA

Pascal Dupuis 

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

