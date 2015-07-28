Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37730 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbbG1J2k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jul 2015 05:28:40 -0400
Received: by wibud3 with SMTP id ud3so150450887wib.0
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2015 02:28:39 -0700 (PDT)
Subject: Re: [PATCH RESEND 0/4] Use max_sge_rd device capability
To: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com
References: <20150727230906.10102.88491.stgit@build2.ogc.int>
Cc: infinipath@intel.com, sagig@mellanox.com, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55B74B4B.8000000@dev.mellanox.co.il>
Date: Tue, 28 Jul 2015 12:28:43 +0300
MIME-Version: 1.0
In-Reply-To: <20150727230906.10102.88491.stgit@build2.ogc.int>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/28/2015 2:09 AM, Steve Wise wrote:
> Resending because I forgot to cc linux-rdma :(
>
> Some devices were not setting this capability, so fix those devices,
> and svcrdma to use max_sge_rd.  Also remove rdma_cap_read_multi_sge()
> since it isn't needed.
>
> These patches were originally part of:
>
> http://www.spinics.net/lists/linux-rdma/msg27436.html
>
> They really aren't part of iSER/iWARP at all, so I've split
> them out.
>
> Bruce: This hits svcrdma, but I suggest they get merged via Doug's tree
> to avoid any merge problems.
>
> ---

Looks good,

Reviewed-by: Sagi Grimberg <sagig@mellanox.com>
