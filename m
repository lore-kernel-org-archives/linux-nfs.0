Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41256 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754654Ab3LFScb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 13:32:31 -0500
Date: Fri, 6 Dec 2013 10:32:29 -0800
From: Greg KH <greg@kroah.com>
To: Weng Meiling <wengmeiling.weng@huawei.com>
Cc: stable@vger.kernel.org, bfields@fieldses.org, skinsbursky@parallels.com,
        linux-nfs@vger.kernel.org, lizefan@huawei.com, h.huangqiang@huawei.com
Subject: Re: [PATCH 3.4 2/9] nfsd: pass net to nfsd_init_socks()
Message-ID: <20131206183229.GA4379@kroah.com>
References: <1386136415-30976-1-git-send-email-wengmeiling.weng@huawei.com>
 <1386136415-30976-3-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386136415-30976-3-git-send-email-wengmeiling.weng@huawei.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 04, 2013 at 01:53:28PM +0800, Weng Meiling wrote:
> From: Stanislav Kinsbursky <skinsbursky@parallels.com>
> 
> commit db6e182c17cb1a7069f7f8924721ce58ac05d9a3 upstream.
> 
> Precursor patch. Hard-coded "init_net" will be replaced by proper one in
> future.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> [wengmeiling: backport to 3.4:
>  - adjust context
>  - one more parameter(int port) for nfsd_init_socks()]

This patch breaks the build, so I can't take it, sorry.

I took the first patch in the series, but had to stop here.

Care to fix this up and resend?

thanks,

greg k-h
