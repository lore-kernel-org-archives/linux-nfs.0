Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f46.google.com ([209.85.216.46]:44356 "EHLO
	mail-vn0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbbGBXX2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 19:23:28 -0400
Received: by vnbg129 with SMTP id g129so7172592vnb.11
        for <linux-nfs@vger.kernel.org>; Thu, 02 Jul 2015 16:23:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1435877253-1497-1-git-send-email-mchen@cs.stonybrook.edu>
References: <1435877253-1497-1-git-send-email-mchen@cs.stonybrook.edu>
Date: Thu, 2 Jul 2015 19:23:27 -0400
Message-ID: <CAHQdGtSkQmk7_z4ckXvefONjUQu6DVxui_q66RYdq-Tc7D_GKQ@mail.gmail.com>
Subject: Re: [PATCH] nfs: avoid nfs_wait_on_seqid() for NFSv4.1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Ming Chen <mchen@cs.stonybrook.edu>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        ezk@fsl.cs.stonybrook.edu
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 2, 2015 at 6:47 PM, Ming Chen <mchen@cs.stonybrook.edu> wrote:
>
> seqid, introduced in NFSv4.0, requires state-changing operations be performed
> synchronously, and thus limits parallelism. NFSv4.1 supports "unlimited
> parallelism" by using sessions and slots; seqid is no longer used and must be
> ignored by NFSv4.1 server. However, the current nfs client always call
> nfs_wait_on_seqid() no matter the version is 4.0 or 4.1.

Please see commit 63f5f796af613 ("NFSv4.1: Allow parallel
OPEN/OPEN_DOWNGRADE/CLOSE") which first appeared in Linux-4.0.

Cheers
  Trond
