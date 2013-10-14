Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57636 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756862Ab3JNRpl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Oct 2013 13:45:41 -0400
Date: Mon, 14 Oct 2013 13:45:40 -0400
To: Wangminlan <wangminlan@huawei.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Different sequence of "exportfs" produce different effects on
 nfs client mounts
Message-ID: <20131014174540.GA27747@fieldses.org>
References: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <3962238FD7EA0F41B1810E7ABEAFBC314CEF9ACF@szxema505-mbs.china.huawei.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 14, 2013 at 02:16:58AM +0000, Wangminlan wrote:
> 　　Hi,
> 　　         I’ve got a problem on the nfs exportfs command. I’m not sure if this is the right place to ask this, if not, can you please tell me where?
> 　　
> 　　         Here’s what I need:
> 　　1. I have a folder named /mnt/fs1 to be exported.
> 　　2. All the host in subnetwork 192.168.0.0/16 should be able access this folder, but their root should be squashed.
> 　　3. Some specified host in the same subnetwork can gain the root permission on the folder, for example: 192.168.0.21, 192.168.0.22.
> 　　
> 　　I’ve got a SLES11SP1 box as the nfs server, the nfs clients are SLES11SP1, too, and the protocol used between clients and server are NFSv3.
> 　　Here are the commands I used to do the export:
> 　　#exportfs –o rw,root_squash 192.168.0.0/16:/mnt/fs1 
> 　　#exportfs –o rw,no_root_squash 192.168.0.21:/mnt/fs1 
> 　　#exportfs –o rw,no_root_squash 192.168.0.22:/mnt/fs1
> 　　After this, everything works as expected.
> 　　
> 　　But, after the following operations:
> 　　#exportfs –u 192.168.0.0/16:/mnt/fs1              /* Delete this export */
> 　　# exportfs –o rw,root_squash 192.168.0.0/16:/mnt/fs1          /* And add it again */
> 　　Hosts on 192.168.0.21 and 192.168.0.22 doesn’t get root permission any more. when I tried to write a file, it complains about “Permission denied”.
> 　　
> 　　So, does the order of exportfs command has something to do the final result? Or am I doing something wrong?

That sounds like a bug.  The contents of
/proc/net/rpc/auth.unix.ip/content and /proc/net/rpc/nfsd.export/content
after getting the above "permission denied" might be interesting.
