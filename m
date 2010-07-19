From: Peng Yu <pengyu.ut@gmail.com>
Subject: on demaind nfs
Date: Sun, 18 Jul 2010 19:31:58 -0500
Message-ID: <AANLkTinokaOEBVHu5KMxofnnkN-0e5MsIfnf1zNPhVmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:51503 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757803Ab0GSAb7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Jul 2010 20:31:59 -0400
Received: by gwj18 with SMTP id 18so1772818gwj.19
        for <linux-nfs@vger.kernel.org>; Sun, 18 Jul 2010 17:31:58 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I've seen that an nfs filesystem can be mount on demand. Suppose, that
the nfs filesystems should be mounted on /local, say /local/nfs1 ...
/local/nfs10. If I don't access them for a while, then I will not see
them mounted (no such file system in df).

If I try to cd to /local/nfs1, then I will see it in df. I'm wondering
if any body can let me know how to mount nfs file system on demand.

-- 
Regards,
Peng
