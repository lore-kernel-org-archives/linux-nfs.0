From: Joshua Baker-LePain <jlb17-4+jYJfmkT58@public.gmane.org>
Subject: [NFS] simple NFSv4 setup
Date: Thu, 19 Nov 2009 15:11:58 -0500 (EST)
Message-ID: <alpine.LRH.2.00.0911191507420.8086@hogwarts.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49393 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754817AbZKSUcN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Nov 2009 15:32:13 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NBDfu-00028Z-Rb
	for linux-nfs@vger.kernel.org; Fri, 20 Nov 2009 07:32:18 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(I've tried this on both the CentOS and RHEL5 lists, so apologies if 
you've gotten this multiple times.)

I'm trying to setup a simple NFSv4 mount between two CentOS 5.4 x86_64 
hosts. On the server, I have this in /etc/exports:

/export         $CLIENT(ro,fsid=0)
/export/qb3     $CLIENT(rw,nohide)

/export is its own filesystem.  This results in the following
'exportfs -v' output:

/export/qb3     $CLIENT(rw,wdelay,nohide,root_squash,no_subtree_check,anonuid=65534,anongid=65534)
/export         $CLIENT(ro,wdelay,root_squash,no_subtree_check,fsid=0,anonuid=65534,anongid=65534)

ON $CLIENT, I mount via:

mount -t nfs4 $SERVER:/qb3 /usr/local/sge62/qb3

However:

$ touch /usr/local/sge62/qb3/foo
touch: cannot touch `/usr/local/sge62/qb3/foo': Read-only file system

I'd really rather not export the pseudo-root read-write, so how do I get 
this working?  I've tried putting the crossmnt option on /export (with and 
without using nohide on /export/qb3), and that doesn't help.  Any hints as 
to what I'm doing wrong would be appreciated.  Thanks.

-- 
Joshua Baker-LePain
QB3 Shared Cluster Sysadmin
UCSF

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

