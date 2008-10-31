From: "lioupayphone" <lioupayphone@gmail.com>
Subject: why there is no "s_export_op" in nfs_super_block?
Date: Fri, 31 Oct 2008 08:56:20 +0800
Message-ID: <200810310856000017530@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
To: "linux-nfs" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:25694 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbYJaA43 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Oct 2008 20:56:29 -0400
Received: by ti-out-0910.google.com with SMTP id b6so437855tic.23
        for <linux-nfs@vger.kernel.org>; Thu, 30 Oct 2008 17:56:27 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, linux-nfs
	
	i have a question about NFS. 
	say, i have three different machines, Machine-1 is a NFS Server who exported its directory "/home/pub" to Machine-2, which mounted "mount -t nfs Machine-1:/home/pub /mnt/pub/".

	i want Machine-2 to be a NFS Server which exports its directory "/mnt/pub" to Machine-3, permission denied when i execute "mount -t nfs Machine-2:/mnt/pub/ /mnt/" on Machine-3.
	( btw : all the three machines are of linux 2.6.17-1, a little old kernel :-) )

	i browsed the code of 2.6.17-1 and found check_export() in fs/nfsd/exports.c , who told me there are two reasons for that :
	
	/* There are two requirements on a filesystem to be exportable.
	 * 1:  We must be able to identify the filesystem from a number.
	 *       either a device number (so FS_REQUIRES_DEV needed)
	 *       or an FSID number (so NFSEXP_FSID needed).
	 * 2:  We must be able to find an inode from a filehandle.
	 *       This means that s_export_op must be set.
	 */

	i think if i set "/home/pub Machin-2(sync,root_squash,fsid=1)" and "/mnt/pub Machine-2(sync,root_squash,fsid=2)" individually in "/etc/exports" of Machine-1 and Machine-2, the requirement-1 will be meet.
	but nfs_fill_super() failed to register its s_export_op. why? i am puzzled. thank you for your suggestions and explanations. :-)

 				
Best Regards!
lioupayphone

