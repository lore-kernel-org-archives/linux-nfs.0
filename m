Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:24176 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755758Ab0GAOTv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 10:19:51 -0400
Message-ID: <4C2CA404.601@panasas.com>
Date: Thu, 01 Jul 2010 17:19:48 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Sandeep Joshi <sjoshi@bluearc.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: mount - Fedora13 - Nfsv4.1 mode
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com>
In-Reply-To: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

What version of the kernel are you using?
I sent a patchset that fixes this:
http://marc.info/?l=linux-nfs&m=127678603202678&w=2
That's in the latest linux-pnfs tree
at tag pnfs-all-2.6.35-rc3-2010-06-21

Benny

On Jul. 01, 2010, 0:15 +0300, "Sandeep Joshi" <sjoshi@bluearc.com> wrote:
> I am using  NFS 4.1 client with nfslayoutdriver loaded. (using Fedora 13)
> If I try to mount the same directory twice from client. I see two exchange id's
> being sent to server. I was expecting only one exchange id. 
> 
> Here are the steps that I am executing:
> 
> modprobe nfslayoutdriver
> mount -t nfs4 -o minorversion=1 <serv-ip-address>:/ /mnt/<dir>
> mount -t nfs4 -o minorversion=1 <serv-ip-address>:/ /mnt/<dir>
> 
> Is this expected behavior?
> 
> 
> regards,
> 
> Sandeep
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
