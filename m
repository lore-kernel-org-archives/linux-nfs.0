Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28568 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758168Ab3JQSc2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:32:28 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
Date: Thu, 17 Oct 2013 18:32:27 +0000
Message-ID: <1382034747.3216.8.camel@leira.trondhjem.org>
References: <525D899F.5010604@candelatech.com>
	  <52601FED.6070708@candelatech.com>
	 <1382033137.3216.3.camel@leira.trondhjem.org>
	 <52602835.4000701@candelatech.com>
In-Reply-To: <52602835.4000701@candelatech.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-17 at 11:11 -0700, Ben Greear wrote:
+AD4- On 10/17/2013 11:05 AM, Myklebust, Trond wrote:
+AD4- +AD4- On Thu, 2013-10-17 at 10:35 -0700, Ben Greear wrote:
+AD4- +AD4APg- On 10/15/2013 11:29 AM, Ben Greear wrote:
+AD4- +AD4APgA+- Is 'umount -f' supposed to always work, even if the file server
+AD4- +AD4APgA+- goes away?
+AD4- +AD4APgA+-
+AD4- +AD4APgA+- I have a user's system that just hangs forever in this case.
+AD4- +AD4APgA+-
+AD4- +AD4APgA+- Could be local changes we have made, but I'm curious about
+AD4- +AD4APgA+- the expected behaviour before I go digging too deep...
+AD4- +AD4APg-
+AD4- +AD4APg- Any input on this?  I don't mind trying to fix it, but I
+AD4- +AD4APg- would like to know how it is supposed to work.
+AD4- +AD4- 
+AD4- +AD4- 'umount -f' has always been iffy. It just kills any pending RPC calls
+AD4- +AD4- +AF8-before+AF8- trying to unmount. Since the unmount itself can trigger
+AD4- +AD4- writeback flushes (and hence more RPC calls), the trace you are seeing
+AD4- +AD4- is indeed possible.
+AD4- 
+AD4- I tried 'umount -f -l', and that also does not work.
+AD4- 
+AD4- Any ideas on how to fix this properly?

'umount -f -l' should normally work to at least hide the gruesome
details of your hanging superblock.

I'm guessing that you're falling afoul of the path revalidation that
Chuck alluded to. There should already be a fix for that problem with
the path+AF8-umountat() patches that went into Linux 3.12-rc1. Are those
failing to help?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
