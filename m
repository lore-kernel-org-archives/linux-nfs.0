From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] pnfs code structure
Date: Tue, 01 Jun 2010 06:38:02 +0300
Message-ID: <4C04809A.1000503@panasas.com>
References: <AANLkTilqCahXkLmgu0EL0Vbje_VcH0msM5o5I2edGglG@mail.gmail.com>	<4BFEB2B5.3050006@panasas.com> <AANLkTinMn17Fwkd_mVSSWnTUc1mT5pjWNZPoajbab07T@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-pnfs <linux-nfs@vger.kernel.org>
To: quanli gui <gqlxj1987@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:12725 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752968Ab0FADiG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 May 2010 23:38:06 -0400
In-Reply-To: <AANLkTinMn17Fwkd_mVSSWnTUc1mT5pjWNZPoajbab07T-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May. 28, 2010, 5:55 +0300, quanli gui <gqlxj1987@gmail.com> wrote:
> the replication policy for the pnfs is that we want add some replication
> to the pnfs, to improve the performance of the pnfs, which is mentioned
> in the pnfs white-paper.

OK.  For that, multiple copies of the data should be maintained.
The way to do it is different for each layout type.

Benny

> 
> 2010/5/28 Benny Halevy <bhalevy@panasas.com <mailto:bhalevy@panasas.com>>
> 
>     Hi,
> 
>     [please note that the old pnfs@linux-nfs.org
>     <mailto:pnfs@linux-nfs.org> mailing list is deprecated
>     and we moved our pnfs discussions to linux-nfs@vger.kernel.org
>     <mailto:linux-nfs@vger.kernel.org>]
> 
>     I have very rough and informal design notes I took not too long ago:
>     http://linux-nfs.org/pipermail/pnfs/attachments/20100304/f90bede4/attachment.txt
> 
>     That said, I hope the code is clear enough to browse and get what it
>     does.
> 
>     What do you mean by "replication policy for the pnfs"?
> 
>     Benny
> 
>     On May. 27, 2010, 4:22 +0300, quanli gui <gqlxj1987@gmail.com
>     <mailto:gqlxj1987@gmail.com>> wrote:
>     > Our group want to experiment something on the pnfs, for example, the
>     > replication policy for the pnfs,and so on. So we want something about
>     > the pnfs development, for example, the pnfs code structure, the
>     key data
>     > structure for the pnfs. Who has the related things? Please help us.
>     >
>     >
>     >
>     > _______________________________________________
>     > NOTE: THIS LIST IS DEPRECATED.  Please use
>     linux-nfs@vger.kernel.org <mailto:linux-nfs@vger.kernel.org>
>     > instead.  (To subscribe to linux-nfs@vger.kernel.org
>     <mailto:linux-nfs@vger.kernel.org>: send "subscribe
>     > linux-nfs" in the body of a message to majordomo@vger.kernel.org
>     <mailto:majordomo@vger.kernel.org>.)
>     >
>     > pNFS mailing list
>     > pNFS@linux-nfs.org <mailto:pNFS@linux-nfs.org>
>     > http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
> 
