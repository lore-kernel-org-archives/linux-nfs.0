Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:52826 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753495AbaIIOiC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 10:38:02 -0400
Received: by mail-vc0-f171.google.com with SMTP id id10so17277739vcb.30
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 07:38:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140909054929.GA12459@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-4-git-send-email-hch@lst.de>
	<CAHQdGtQ5--A4_NJpJZ=VEkomCbFYM=6AitSEdexShvBk=aJsPQ@mail.gmail.com>
	<20140909054929.GA12459@lst.de>
Date: Tue, 9 Sep 2014 07:38:00 -0700
Message-ID: <CAHQdGtQ7pEK4QCPHMfys1YW+StYcMJeOP2oXnSrn3G6A-8CBuA@mail.gmail.com>
Subject: Re: [PATCH 03/19] pnfs: force a layout commit when encountering busy
 segments during recall
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 8, 2014 at 10:49 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Mon, Sep 08, 2014 at 05:37:42PM -0700, Trond Myklebust wrote:
>> Why wouldn't it make more sense to call pnfs_layoutcommit_inode()
>> unconditionally before the call to pnfs_mark_matching_lsegs_invalid()?
>
> It would minimally reduce the latency, but otherwise be not very different.
> The downside is that we'll now need two i_lock roundtrips per recall.
>
> But if this is your preference I can easily fix it up.

Please do. It would make the code a little easier on the eye.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
