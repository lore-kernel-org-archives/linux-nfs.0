Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34472 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751808Ab1ECPvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 May 2011 11:51:13 -0400
Subject: Re: pNFS and ipv6
Content-Type: text/plain; charset=us-ascii
From: Dros Adamson <dros@netapp.com>
In-Reply-To: <4DC01F1A.9060305@desy.de>
Date: Tue, 3 May 2011 11:50:55 -0400
Cc: NFS list <linux-nfs@vger.kernel.org>
Message-Id: <D8F5F85C-06A1-4B93-8EDE-BA134488B616@netapp.com>
References: <4DC01F1A.9060305@desy.de>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Yes, I'm actually working on that right now!

-dros

On May 3, 2011, at 11:28 AM, Tigran Mkrtchyan wrote:

> 
> Dear friends,
> 
> are there plans to support IPv6 with pNFS ?
> 
> fs/nfs/nfs4filelayoutdev.c:325
> 
>        /* Currently only support ipv4 address */
>        if (in4_pton(buf, rlen, (u8 *)&ip_addr, '-', &ipend) == 0) {
>                dprintk("%s: Only ipv4 addresses supported\n", __func__);
>                goto out_free;
>        }
> 
> 
> Regards,
>   Tigran.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

