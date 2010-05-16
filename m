From: jupiter.hce@gmail.com
Subject: Disable NFS client cache.
Date: Sun, 16 May 2010 12:50:55 +1000
Message-ID: <20100516025055.GC3872@gmail.com>
Reply-To: jupiter.hce@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:65497 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751369Ab0EPCwi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 15 May 2010 22:52:38 -0400
Received: by pwi10 with SMTP id 10so1249031pwi.19
        for <linux-nfs@vger.kernel.org>; Sat, 15 May 2010 19:52:38 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

Could you please advice how to disable NFS client cache in mount
command?

I have an application to use NFS over FUSE, if I keep typing "ls" in
the same directory, the client NFS only sent GETATT, no more READDIR,
all directory contents displayed on screen came from NFS cache. That
caused many problems and I'd like to disable NFS client cache. But it
did not work when I add "-o noac" option to mount. Also I don't want
NFS GETATT retransmission during file copy. Appreciate your advice and
sample examples to mount.

Thank you.


