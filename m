From: Allard Hoeve <allard-DW70C6hi67U@public.gmane.org>
Subject: [NFS] NFSv3 + SVN + Apache2 gives stale filehandles and FORBIDDEN
	responses
Date: Tue, 20 May 2008 16:07:39 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0805201425430.18549@office2.c1.internal>
Reply-To: Allard Hoeve <allard-DW70C6hi67U@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:34253 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755483AbYETOH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2008 10:07:58 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JySVQ-0000nZ-AN
	for linux-nfs@vger.kernel.org; Wed, 21 May 2008 00:07:56 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hello all,

I'm currently experiencing the following on Debian Etch (nfsv3, 2.6.24.2):

http://linux-nfs.org/pipermail/nfsv4/2008-April/008423.html

It is properly summarized by J. Bruce Fields at:

http://linux-nfs.org/pipermail/nfsv4/2008-April/008452.html

I can reproduce this easily.

Let's assume three hosts:

* Host A is where development happens, this has a separate checkout
* Host B is where the checkout gets updated (shellserver) on an NFS mount
* Host C is where the webserver resides, Apache serves from the an NFS
    mount that points to the same server as B's NFS mount points to

This setup is easily created if you have two hosts and access to an SVN 
server.

To reproduce:

1) I update the testfile on host A and commit it.
2) I update the checkout with svn commit on host B.
3) No I test the file on host C:
    a) I try to access the file on host C through the webserver: permission
       denied (stale NFS handle)
    b) I try to stat the file: cannot stat 'test': Stale NFS file handle
4) A simple 'cat test' gives me the new contents of 'test' and solves the
     problem. The file is now 'stat'-able and downloadable through the
     webserver.

Where should I start to solve the problem? From the threads above, I seem 
to understand that fixing this in userspace (Apache2 / stat) would require 
some work and that the solution lies in the NFS client? This would require 
me hacking the NFS kernel code.  *shivers* :)

Or maybe there already is someone working on the problem? *crosses 
fingers*. I could test patches, etc if you'd like.x

Thanks for your time,

Regards,

Allard Hoeve

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

