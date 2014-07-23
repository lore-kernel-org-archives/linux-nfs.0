Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43656 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755382AbaGWQNw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 12:13:52 -0400
Received: by mail-ie0-f176.google.com with SMTP id tr6so1170851ieb.21
        for <linux-nfs@vger.kernel.org>; Wed, 23 Jul 2014 09:13:51 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 23 Jul 2014 09:13:51 -0700
Message-ID: <CAB7xdikp2ab=oqQKz+DVLh0D5G9aB7EMd4XWttLh3qFE8Fp9qA@mail.gmail.com>
Subject: how to setup pNFS
From: sheng qiu <herbert1984106@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

i am trying to set up pNFS server and client. is there any document
can help that?
i tried to follow the
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Setup_Instructions, but
i did not have /proc/fs/nfsd/pdfs_dlm_device entry.

echo "/dev/sdc:192.168.0.1,192.168.0.2" >/proc/fs/nfsd/pnfs_dlm_device


so i cannot follow the above step.


any help?


THanks!
