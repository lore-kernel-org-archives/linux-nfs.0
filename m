Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35998 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbJHU0j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 16:26:39 -0400
MIME-Version: 1.0
In-Reply-To: <1444290669-5252-13-git-send-email-sagig@mellanox.com>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
	<1444290669-5252-13-git-send-email-sagig@mellanox.com>
Date: Thu, 8 Oct 2015 23:26:39 +0300
Message-ID: <CAJ3xEMjiNA6+yzggVBKC5ff0huri0KJOYoLx=FfAfs3HDO=VpA@mail.gmail.com>
Subject: Re: [PATCH v3 12/26] xprtrdma: Port to new memory registration API
From: Or Gerlitz <gerlitz.or@gmail.com>
To: Sagi Grimberg <sagig@mellanox.com>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 8, 2015 at 10:50 AM, Sagi Grimberg <sagig@mellanox.com> wrote:
> Instead of maintaining a fastreg page list, keep an sg table
> and convert an array of pages to a sg list. Then call ib_map_mr_sg
> and construct ib_reg_wr.
>
> Note that the next step would be to have NFS work with sg lists
> as it maps well to sk_frags (see comment from hch
> http://marc.info/?l=linux-rdma&m=143677002622296&w=2).


I don't see the point to keep the 2nd paragraph in the upstream git log
forever, it deserves to be after the --- line such that when the maintainer
uses git am this stays out, so apply this in the respin you'd be doing
to address Chuck's comments.

Or.
