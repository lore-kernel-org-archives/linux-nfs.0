Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33740 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752574AbdBUNuT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Feb 2017 08:50:19 -0500
Received: by mail-oi0-f68.google.com with SMTP id 2so4928990oif.0
        for <linux-nfs@vger.kernel.org>; Tue, 21 Feb 2017 05:50:18 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: Re: some problems about permission of subdirectory
To: houlinfei <hou.linfei@h3c.com>, linux-nfs@vger.kernel.org
References: <65bb8731.b190.15a5fdf1b2a.Coremail.hou.linfei@h3c.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.com>,
        Steve Dickson <SteveD@redhat.com>
Message-ID: <29ccb0b1-97fd-1b0b-12c4-3bde03dcdad9@gmail.com>
Date: Tue, 21 Feb 2017 21:50:01 +0800
MIME-Version: 1.0
In-Reply-To: <65bb8731.b190.15a5fdf1b2a.Coremail.hou.linfei@h3c.com>
Content-Type: text/plain; charset=gbk
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/21/2017 16:52, houlinfei wrote:
> 
> hi everyone:
> I met a problem about subdirectory permission when client mount this subdirectory using nfs4. For example:
> the contents of the /etc/exports file is
> /root/hh *(ro,sync,insecure,no_subtree_check)
> /root/hh/hh1 *(rw,sync,insecure,no_subtree_check)
> and the two directory permission is 777. And the parent directory's export permission is read-only, the subdirectory's export permission is read-write.
> Then client mount /root/hh/hh1 on /mnt/yy using nfs4. But the /mnt/yy directory only can read.If client mount /root/hh/hh1 on /mnt/yy using nfs3, the /mnt/yy can write.

nfs3 gets the filehandle of /root/hh/hh1 from rpc.mountd before really mounting, 
so that, nfs3 do the later process with the filehandle of /root/hh/hh1,
with the second exports entry.
 
But, nfs4 get the filehandle by LOOKUP through nfsd step by step, 
at first, LOOKUP "/" as the pseudo filesystem with an pseudo exports entry,
second, LOOKUP "/root/" also use the pseudo export entry, 
next, LOOKUP "/root/hh/" will get a new export entry
for "/root/" use a pseudo export entry, but at last LOOKUP "/root/hh/hh1",
nfsd uses the export entry for "/root/hh/" that isn't a pseudo entry entry.

So that, nfsv3 client can write the directory, but nfsv4 client can't.

> Who know how to solve this problem about nfs4? Thanks very much~

Without change any codes of rpc.mountd and nfsd, there is a hacker method for it.
# chmod -x /root/hh/hh1
# chmod +t /root/hh/hh1
# setfattr -n "trusted.junction.nfs" -v "anything" /root/hh/hh1

Umount the nfs and remount as nfsv4.

Cc Bruce, Neil, Steve,

Is it needed adding an xattr as "junction.nfs" for fixing this problem?

thanks,
Kinglong Mee
