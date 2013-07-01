Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60914 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751108Ab3GAPBI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 11:01:08 -0400
Date: Mon, 1 Jul 2013 11:01:05 -0400
To: drankye <drankye@yahoo.com.cn>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: What's the status of SPKM3/LIPKEY for NFS4 on Linux
Message-ID: <20130701150105.GC19945@fieldses.org>
References: <1372664858.77543.YahooMailNeo@web15903.mail.cnb.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1372664858.77543.YahooMailNeo@web15903.mail.cnb.yahoo.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 01, 2013 at 03:47:38PM +0800, drankye wrote:
> 
> 
> Hi all, 
>  
> About 2 years ago, it was asked “when will we be able to use
> LIPKEY on NFS4 on Linux?”. Ref. http://permalink.gmane.org/gmane.linux.nfs/35560.
> There Trond replied as below:
> “
> We're likely to drop the requirement that SPKM3/LIPKEY be a
> mandatory
> security mechanism for NFSv4 in the revised RFC3530 (a.k.a.
> RFC3530bis)
> that is being drafted.
>  
> The reason is that the SPKM3 mechanism (on which LIPKEY
> relies) appears
> to contain inherent security flaws that are difficult to
> fix. The IETF
> security group have therefore pretty much killed it as an
> option.
> Other alternatives to SPKM3 are being discussed, but I'm not
> aware of
> anything that replaces LIPKEY.
> “
> I’m wondering today what’s the status of SPKM3/LIPKEY
> support for NFS4 on Linux. Does anyone know that? Is SPKM3/LIPKEY dropped from
> NFS4 or available now with the inherent security flaws being fixed?

It's gone.  (The kernel code was removed by
1e7af1b8062598a038c04dfaaabd038a0d6e8b6a "J. Bruce Fields
<bfields@redhat.com>".)

And my understanding is that the flaws were inherent to the
specification and not fixable in implementation.

--b.

>  
> Thank you very much for your update. 
>  
> Regards,
> Kai
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
