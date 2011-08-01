Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:49314 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703Ab1HANyf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2011 09:54:35 -0400
Received: by pzk37 with SMTP id 37so11542821pzk.1
        for <linux-nfs@vger.kernel.org>; Mon, 01 Aug 2011 06:54:34 -0700 (PDT)
Date: Mon, 1 Aug 2011 14:54:34 +0100
Message-ID: <CAA4Z2ZR47Lfb_=172VUd-Qop7NiC3ewVAgUepn0WD=PDTr9k-A@mail.gmail.com>
Subject: using non contiguous memory in nfs_idmap_new()
From: Adrien Kunysz <adk@acunu.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear linux-nfs,

I have a box that has recently been victim of an OOM caused by
nfs_idmap_new() attempting to allocate a large amount of contiguous
memory. This problem has been reported previously here [0] and I
understand the real fix is to use CONFIG_NFS_USE_NEW_IDMAPPER. However
I was wondering whether using non contiguous memory instead would be a
valid workaround, especially considering the new ID mapper is not
enabled by default. I have actually written a patch to that effect as
I don't see any specific reason why that struct would need to be in
contiguous memory.

So before I do anything stupid with that patch,
a) is there any good reason to use kzalloc() instead of vzalloc() in
nfs_idmap_new()?
b) would you consider a patch that would make the function use vzalloc()?

Thanks,
Adrien Kunysz

[0] http://www.spinics.net/lists/linux-nfs/msg22248.html
