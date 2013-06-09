Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f173.google.com ([209.85.220.173]:44613 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab3FIHfR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Jun 2013 03:35:17 -0400
Received: by mail-vc0-f173.google.com with SMTP id ht10so219765vcb.4
        for <linux-nfs@vger.kernel.org>; Sun, 09 Jun 2013 00:35:16 -0700 (PDT)
MIME-Version: 1.0
Date: Sun, 9 Jun 2013 13:05:16 +0530
Message-ID: <CAEfL3KnfRWof4-6UAWTwXcH7XWSQuUR5ry_pg4qdyhBB6dt+5g@mail.gmail.com>
Subject: why does nfsd write not use splice
From: Sandeep Joshi <sanjos100@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there a reason as to why the nfsd server does not use splice in the
write calls - nfsd_vfs_write() ?  Is there some structural limitation
or is it just something nobody got around to implementing ?

I have looked at the source back to the 2.6.x kernels and it seems
only nfsd_vfs_read() has ever used splice/sendfile.
http://lxr.linux.no/linux+v3.9.5/fs/nfsd/vfs.c

TIA
-Sandeep
