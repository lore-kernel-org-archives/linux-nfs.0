Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:46341 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758112Ab3JQSFk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Oct 2013 14:05:40 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Ben Greear <greearb@candelatech.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: 'umount -f /mnt/foo' fails if server IP is gone.
Date: Thu, 17 Oct 2013 18:05:38 +0000
Message-ID: <1382033137.3216.3.camel@leira.trondhjem.org>
References: <525D899F.5010604@candelatech.com>
	 <52601FED.6070708@candelatech.com>
In-Reply-To: <52601FED.6070708@candelatech.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-10-17 at 10:35 -0700, Ben Greear wrote:
+AD4- On 10/15/2013 11:29 AM, Ben Greear wrote:
+AD4- +AD4- Is 'umount -f' supposed to always work, even if the file server
+AD4- +AD4- goes away?
+AD4- +AD4-
+AD4- +AD4- I have a user's system that just hangs forever in this case.
+AD4- +AD4-
+AD4- +AD4- Could be local changes we have made, but I'm curious about
+AD4- +AD4- the expected behaviour before I go digging too deep...
+AD4- 
+AD4- Any input on this?  I don't mind trying to fix it, but I
+AD4- would like to know how it is supposed to work.

'umount -f' has always been iffy. It just kills any pending RPC calls
+AF8-before+AF8- trying to unmount. Since the unmount itself can trigger
writeback flushes (and hence more RPC calls), the trace you are seeing
is indeed possible.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
