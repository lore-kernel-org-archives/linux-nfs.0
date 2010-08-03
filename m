From: Yudong Gao <stgyd@umich.edu>
Subject: Write delegation
Date: Mon, 2 Aug 2010 17:17:26 -0700
Message-ID: <AANLkTi=2KYZ-8qaXMG=C_s617q3k1Ocs7h1gyd8=RpY6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62724 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013Ab0HCARr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2010 20:17:47 -0400
Received: by ywh1 with SMTP id 1so1413257ywh.19
        for <linux-nfs@vger.kernel.org>; Mon, 02 Aug 2010 17:17:46 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am looking at the delegation implementation in the source code of
NFS 4.1 in kernel 2.6.32.15. I can find the code for read delegation,
which is working and can serve the read requests locally. But I can
never find the code about write delegation, which is supposed to cache
the write update locally. I try to look at the functions including
nfs_writepage(s), nfs_file_flush() but none of them checks or uses the
write delegation.

Is write delegation currently implemented in NFS 4.1?

Thanks!

best,

Yudong
