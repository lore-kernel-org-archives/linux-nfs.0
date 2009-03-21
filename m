From: Maria McKinley <maria-3uEUQlRWSvdAfugRpC6u6w@public.gmane.org>
Subject: [NFS] problem with rpc.statd
Date: Fri, 20 Mar 2009 17:43:51 -0700
Message-ID: <49C43847.9080206@shadlen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:37494 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755441AbZCUApV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2009 20:45:21 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1LkpKr-0000F7-23
	for linux-nfs@vger.kernel.org; Sat, 21 Mar 2009 11:45:13 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello all,

I hope this is an appropriate place to post this, as I am running out of 
ideas.

I have a machine that I am attempting to boot over the network. I have
compiled a kernel for it, Debian Lenny Linux version 2.6.26, with nfs
file system and root file system support. For a complete rundown on how
I have created the setup, please see:

http://www.shadlen.org/~maria/pmwiki/Work/Gpxe

Things work well up until it is time to mount the file system from
fstab (ie, it mounts everything ro, makes it all the way through init 
and gives me a command prompt). The rw mount is not happening because 
rpc.statd never starts. If I try to start rpc.statd by hand, it 
complains that: Opening /var/run/rpc.statd.pid failed: Read-only file 
system. Since I am mounting the root directory over nfs, it makes sense 
for this file to be read-only until rpc.statd starts and  Is there any 
way I can start statd without a pid file until I get the root file 
system mounted rw? Or something else to try?

I had a similar setup working with an earlier version of nfs-common, but 
it broke when I upgraded recently. Currently using nfs-common 
1:1.1.2-6lenny1

thank you for any direction anyone can point me, as I am about at my 
wit's end...

cheers,
maria

------------------------------------------------------------------------------
Apps built with the Adobe(R) Flex(R) framework and Flex Builder(TM) are
powering Web 2.0 with engaging, cross-platform capabilities. Quickly and
easily build your RIAs with Flex Builder, the Eclipse(TM)based development
software that enables intelligent coding and step-through debugging.
Download the free 60 day trial. http://p.sf.net/sfu/www-adobe-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

