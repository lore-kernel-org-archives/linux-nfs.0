From: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Text based mount options ignoring the preferred rwsize?
Date: Tue, 08 Sep 2009 17:47:32 +0100
Message-ID: <4AA68AA4.7090606@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:48204 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750881AbZIHRQR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2009 13:16:17 -0400
Received: from cassini.mpc.local ([172.16.15.37] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43)
	id 1Ml3qu-0006VP-5E
	for linux-nfs@vger.kernel.org; Tue, 08 Sep 2009 17:47:32 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've noticed a difference in the rsize used when mounting a file system 
  between using text and binary mount options.

The client is running a CentOS5 based distro with a 2.6.32-rc8 kernel

The server has a preferred rsize of 128kb and maximum rsize of 512kb

When I use mount.nfs from CentOS5/RHEL5 nfs-utils (based on v1.0.9) and 
don't give any rsize option, it mounts the file system with a rsize of 
128kb. This uses binary mount options

But, when using mount.nfs from nfs-utils 1.2.0, the file system is 
mounted with an rsize of 512kb

Looking at the nfs-utils and kernel source, it appears that for binary 
options, rsize is set to 0 if not given by mount.nfs, and the kernel 
eventually, in this case, increases this to preferred size.

But for text mount options, if not set by mount.nfs, the default size is 
  set to NFS_MAX_FILE_IO_SIZE in the kernel, which, in this case, gets 
reduced to the server maximum size.

Should the kernel be setting rsize (and wsize) to 0 by default?

Thanks

James Pearson
