Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:1933 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758121Ab3JQSm2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:42:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
Date: Thu, 17 Oct 2013 18:42:26 +0000
Message-ID: <1382035346.3216.15.camel@leira.trondhjem.org>
References: <525D899F.5010604@candelatech.com>
	   <52601FED.6070708@candelatech.com>
	  <1382033137.3216.3.camel@leira.trondhjem.org>
	  <52602835.4000701@candelatech.com>
	 <1382034747.3216.8.camel@leira.trondhjem.org>
	 <52602DD7.6050708@candelatech.com>
In-Reply-To: <52602DD7.6050708@candelatech.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-17 at 11:35 -0700, Ben Greear wrote:
+AD4- On 10/17/2013 11:32 AM, Myklebust, Trond wrote:
+AD4- +AD4- On Thu, 2013-10-17 at 11:11 -0700, Ben Greear wrote:
+AD4- +AD4APg- On 10/17/2013 11:05 AM, Myklebust, Trond wrote:
+AD4- +AD4APgA+- On Thu, 2013-10-17 at 10:35 -0700, Ben Greear wrote:
+AD4- +AD4APgA+AD4- On 10/15/2013 11:29 AM, Ben Greear wrote:
+AD4- +AD4APgA+AD4APg- Is 'umount -f' supposed to always work, even if the file server
+AD4- +AD4APgA+AD4APg- goes away?
+AD4- +AD4APgA+AD4APg-
+AD4- +AD4APgA+AD4APg- I have a user's system that just hangs forever in this case.
+AD4- +AD4APgA+AD4APg-
+AD4- +AD4APgA+AD4APg- Could be local changes we have made, but I'm curious about
+AD4- +AD4APgA+AD4APg- the expected behaviour before I go digging too deep...
+AD4- +AD4APgA+AD4-
+AD4- +AD4APgA+AD4- Any input on this?  I don't mind trying to fix it, but I
+AD4- +AD4APgA+AD4- would like to know how it is supposed to work.
+AD4- +AD4APgA+-
+AD4- +AD4APgA+- 'umount -f' has always been iffy. It just kills any pending RPC calls
+AD4- +AD4APgA+- +AF8-before+AF8- trying to unmount. Since the unmount itself can trigger
+AD4- +AD4APgA+- writeback flushes (and hence more RPC calls), the trace you are seeing
+AD4- +AD4APgA+- is indeed possible.
+AD4- +AD4APg-
+AD4- +AD4APg- I tried 'umount -f -l', and that also does not work.
+AD4- +AD4APg-
+AD4- +AD4APg- Any ideas on how to fix this properly?
+AD4- +AD4- 
+AD4- +AD4- 'umount -f -l' should normally work to at least hide the gruesome
+AD4- +AD4- details of your hanging superblock.
+AD4- +AD4- 
+AD4- +AD4- I'm guessing that you're falling afoul of the path revalidation that
+AD4- +AD4- Chuck alluded to. There should already be a fix for that problem with
+AD4- +AD4- the path+AF8-umountat() patches that went into Linux 3.12-rc1. Are those
+AD4- +AD4- failing to help?
+AD4- 
+AD4- I have not tried past 3.9.11 kernel yet.  I will go look for those patches
+AD4- you mention as well.  Did any of this go to -stable by chance?

Not as far as I know.

The commit identifier is 8033426e6bdb2690d302872ac1e1fadaec1a5581 (vfs:
allow umount to handle mountpoints without revalidating them) in case
you are interested.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
