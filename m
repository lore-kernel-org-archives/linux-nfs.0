Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:42275 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbaIKPbS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Sep 2014 11:31:18 -0400
Received: by mail-qg0-f53.google.com with SMTP id q108so3788183qgd.12
        for <linux-nfs@vger.kernel.org>; Thu, 11 Sep 2014 08:31:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140911152058.GA6690@lst.de>
References: <1410362617-28018-1-git-send-email-hch@lst.de> <1410362617-28018-4-git-send-email-hch@lst.de>
 <CAKVebiVvenTsjwBTB1=-HO1w5=7WEKEpj6hQkQP9XQJcuWMgag@mail.gmail.com> <20140911152058.GA6690@lst.de>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 11 Sep 2014 23:30:50 +0800
Message-ID: <CAKVebiXPaxN5hayCYAdd22vThFk=c+Vf0nHmWAnNssMQzyiLPw@mail.gmail.com>
Subject: Re: [PATCH 3/9] pnfs: add return_range method
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 11, 2014 at 11:20 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Thu, Sep 11, 2014 at 09:54:42PM +0800, Peng Tao wrote:
>> It looks better to put return_range inside
>> pnfs_mark_matching_lsegs_invalid() to have it called every time a
>> range of layout segments all get freed. So that ld is sure to free
>> things up.
>
> Actually we specificly want to avoid that for cases like the internal
> new stateid handling in pnfs_layout_process, where we might allocate
> a new layout that overlaps an existing one, and where we need to keep
> the extents around.
>
It looks dangerous to have extents lurking around without matching
layout segments. One example is NFS4ERR_EXPIRED and
NFS4ERR_BAD_STATEID in nfs4_layoutget_done(), client needs to drop all
layout segments but may keep the layout header, in which case blocks
layout would still hold all extents at hand.
