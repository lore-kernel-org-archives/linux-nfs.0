From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Files getting out of sync between client/server
Date: Tue, 20 Nov 2007 16:45:49 -0500
Message-ID: <1195595149.7234.48.camel@heimdal.trondhjem.org>
References: <d29a314c0711201313u4e986db3j27b3da95df2bd718@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Stefanovich <sklopp@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:47041 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824AbXKTVpN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Nov 2007 16:45:13 -0500
In-Reply-To: <d29a314c0711201313u4e986db3j27b3da95df2bd718-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2007-11-20 at 13:13 -0800, Stefanovich wrote:
> Hi,
> 
> I have a problem that when uploading files to our NFS server. The
> problem occurs when we overwrite a file using ftp. What happens is
> that on the server the file is uploaded and updated correctly, however
> on our nfs clients the file itself doesn't update, it actually retains
> the information from the previous version of the file. I have tried to
> remount the clients when this occurs but that doesn't fix the problem.
> So far the only way I have found to correct this issue is to
> physically reboot the client machines. Just wondering if anyone knows
> why this might be happening, and any idea on a fix or what I am doing
> wrong?

Does the new file keep the same inode number as the previous one? If so,
then the problem is likely to be because you are keeping the file open
while the other client is writing to it. That is forbidden in the
close-to-open cache consistency model that most NFS clients implement.

Cheers
  Trond

