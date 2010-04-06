From: gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
Subject: nfs + Reiser4
Date: Tue, 06 Apr 2010 19:52:21 +0200
Message-ID: <op.vaq49joctxpshh@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:58621 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757309Ab0DFSTs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Apr 2010 14:19:48 -0400
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NzDNJ-0007pa-KI
	for linux-nfs@vger.kernel.org; Wed, 07 Apr 2010 04:19:45 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am having serious headaches using nfs between a reiser4 server and arm  
client.
Both on 2.6.29 vintage kernels.

Files are constantly getting out of sync.

Example :

boot ARM via nfs
edit lighttpd.conf on ARM
check edit is visible on server. OK

reboot ARM
check file : reverted to an earlier state.
check server: edited version still showing.


This is just one example of serious userablity issues. I have also seen a  
revert 10s later reopening the same file on the ARM.

Is this possibly related to R4 + nfs ?

TIA.

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

