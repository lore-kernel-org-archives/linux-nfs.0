Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35510 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751912AbdBZAZI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 25 Feb 2017 19:25:08 -0500
Received: by mail-io0-f193.google.com with SMTP id v13so2592657iov.2
        for <linux-nfs@vger.kernel.org>; Sat, 25 Feb 2017 16:23:33 -0800 (PST)
Subject: Re: some problems about permission of subdirectory
To: houlinfei <hou.linfei@h3c.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <780a867d.53cc0e.15a75733ad0.Coremail.hou.linfei@h3c.com>
Cc: neilb@suse.com, SteveD@redhat.com,
        Kinglong Mee <kinglongmee@gmail.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <4ee0f1c3-0f80-6e66-9db3-3c1382cde6d6@gmail.com>
Date: Sun, 26 Feb 2017 08:23:19 +0800
MIME-Version: 1.0
In-Reply-To: <780a867d.53cc0e.15a75733ad0.Coremail.hou.linfei@h3c.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/25/2017 21:26, houlinfei wrote:
> hi Kinglong, Bruce,
> Two suggestions all can resolve the problem,but when i use the way of mount --bind /root/hh/hh1 /root/hh/hh1 , and client has mount this nfs share. When i umount /root/hh/hh1.It will busy. when i umount share on client and stop nfsd on server. Then i can umount /root/hh/hh1. Why?

Yes, that's a old problem.

For each export entry, nfsd has some cache in kernel,each valid cache
has a reference to the export directory.
The umount operation finds that and report busy, after stop the service,
all cache will be dropped(no any reference to export entry), umount success.

I have try to fix the problem at 2015, 
http://www.spinics.net/lists/linux-nfs/msg52646.html

Ps, if someone think it's really a requirement, I will pick it up?

thanks,
Kinglong Mee
