Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e36.co.us.ibm.com ([32.97.110.154]:57139 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbaGaTtl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2014 15:49:41 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Thu, 31 Jul 2014 13:49:40 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 3E04D3E4003F
	for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2014 13:49:38 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s6VHjqAa9109764
	for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2014 19:45:52 +0200
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6VJnbQf005104
	for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2014 13:49:37 -0600
Date: Thu, 31 Jul 2014 14:49:36 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Ben Greear <greearb@candelatech.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Killing process in D state on mount to dead NFS server.
Message-ID: <20140731194936.GB29395@us.ibm.com>
References: <53DA8443.407@candelatech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53DA8443.407@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ben Greear [greearb@candelatech.com] wrote:
> So, this has been asked all over the interweb for years and years, but
> the best answer I can find is to reboot the system or create a fake NFS
> server somewhere with the same IP as the gone-away NFS server.
> 
> The problem is:
> 
> I have some mounts to an NFS server that no longer exists (crashed/powered down).
> 
> I have some processes stuck trying to write to files open on these mounts.
> 
> I want to kill the process and unmount.
> 
> umount -l will make the mount go a way, sort of.  But process is still hung.
> umount -f complains:
>   umount2:  Device or resource busy
>   umount.nfs: /mnt/foo: device is busy
> 
> kill -9 does not work on process.
> 
> 
> Aside from bringing a fake NFS server back up on the same IP, is there any
> other way to get these mounts unmounted and the processes killed without
> rebooting?

You don't need a fake NFS server, you just need a fake or real server
with that IP address.  A popular way is to alias that IP on the NFS
client itself.

See the second popular answer below:
http://stackoverflow.com/questions/40317/force-unmount-of-nfs-mounted-directory

Regards, Malahal.

