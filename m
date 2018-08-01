Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34002 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389692AbeHARGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 1 Aug 2018 13:06:49 -0400
Date: Wed, 1 Aug 2018 11:20:38 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 0/4] NFS/RDMA server patches for v4.19
Message-ID: <20180801152038.GB18338@fieldses.org>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180801143622.GF16651@fieldses.org>
 <A73AEC28-2A67-4EFB-8C42-0B0842F4DF4D@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A73AEC28-2A67-4EFB-8C42-0B0842F4DF4D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 01, 2018 at 11:14:14AM -0400, Chuck Lever wrote:
> > On Aug 1, 2018, at 10:36 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > But I'd rather not invest a lot of time trying to make NFSv2/v3 better,
> > the priority for older protocols is just to avoid regressions.
> 
> Fair 'nuf.
> 
> I'm not clear where NFSv4.0 fits here. I realize most of us would
> consider NFSv4.0 to be a "legacy protocol". Does the Linux server
> utilize the DRC for NFSv4.0 ?

If I remember correctly, it uses the DRC and decides whether to cache
particular compounds based on the mix of operation numbers making up the
compound.  (I wrote that code but haven't looked at it recently.)--b.
