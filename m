Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:36071 "EHLO
        mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751667AbdGIK1a (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Jul 2017 06:27:30 -0400
Received: by mail-it0-f51.google.com with SMTP id m68so13405415ith.1
        for <linux-nfs@vger.kernel.org>; Sun, 09 Jul 2017 03:27:30 -0700 (PDT)
MIME-Version: 1.0
From: John <firecanyonarch@gmail.com>
Date: Sun, 9 Jul 2017 06:27:29 -0400
Message-ID: <CA+Z6pJYtuce1GWRw-kB3P9kraDObP0qTjZmE4hSr5PoOoCcyyA@mail.gmail.com>
Subject: NFS still exports non-mountpoints with mountpoint= option /etc/exports
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In reading man exports, it seems that the 'mountpoint=' option would
be of use to me exporting mounts from an external HDD on my NFS
server.  I am finding that despite the fact that the export I defined
is not a mountpoint, it is still exported.  My distro is Arch Linux
running the distro provided nfs-utils-2.1.1-4.  Perhaps I do not have
the syntax correct or one of the other options I am defining is
overriding?

Example:
 % cat /etc/exports
 /srv/nfs      10.1.10.0/24(ro,fsid=root,no_subtree_check)
 /srv/nfs/ATV4 10.1.10.0/24(ro,no_subtree_check,insecure,mountpoint=/srv/nfs/ATV4)

I have /srv/nfs/ATV4 bind mounted to the actual /mnt/nas/ATV4 on the
external media.

On my filesystem, /srv/nfs/ATV4 is literally an empty directory:
 % mountpoint /srv/nfs/ATV4
 /srv/nfs/ATV4 is not a mountpoint

% showmounts -e
 Export list for test:
 /srv/nfs           10.1.10.0/24
 /srv/nfs/ATV4      10.1.10.0/24
