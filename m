Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:57375 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751666Ab0IOHsD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Sep 2010 03:48:03 -0400
Received: by gwj17 with SMTP id 17so2608481gwj.19
        for <linux-nfs@vger.kernel.org>; Wed, 15 Sep 2010 00:48:02 -0700 (PDT)
Date: Wed, 15 Sep 2010 15:48:02 +0800
Message-ID: <AANLkTima6ASRztdzgm413VaBKLPEFt2SSa4JUkKQ9TqV@mail.gmail.com>
Subject: pNFS: trouble test with fscache
From: =?UTF-8?B?5a6r5YuQ?= <shadowinlife@gmail.com>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

S:

I want to get benchmark from pNFS+ fscache with iozone

But  iozone can't work well
/proc/fs/nfsfs/volumes   show that  the fsc is YES

I have open cachefiled and mount a ssd (ext3/user_xattr) on /var/fscache

When I use iozone to test read/re-read   it can't write page to the SSD DISK

/var/log/messages  show that  first it can write 4 pages successfully

after NFS: nfs_getpages_from_fscache: no page: -105

Then it won't write any page to fscache

If i use( cp /mnt/file  ./ )    The fscache works well

I confuse and have google many web page.  change source code to latest
one  But can't handle it.
I wish any help


Thanks


                                yours

                                GongMeng
