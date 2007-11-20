From: Stefanovich <sklopp@gmail.com>
Subject: Files getting out of sync between client/server
Date: Tue, 20 Nov 2007 13:13:34 -0800
Message-ID: <d29a314c0711201313u4e986db3j27b3da95df2bd718@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.235]:7790 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbXKTVNn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2007 16:13:43 -0500
Received: by nz-out-0506.google.com with SMTP id s18so1727088nze
        for <linux-nfs@vger.kernel.org>; Tue, 20 Nov 2007 13:13:34 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a problem that when uploading files to our NFS server. The
problem occurs when we overwrite a file using ftp. What happens is
that on the server the file is uploaded and updated correctly, however
on our nfs clients the file itself doesn't update, it actually retains
the information from the previous version of the file. I have tried to
remount the clients when this occurs but that doesn't fix the problem.
So far the only way I have found to correct this issue is to
physically reboot the client machines. Just wondering if anyone knows
why this might be happening, and any idea on a fix or what I am doing
wrong?
