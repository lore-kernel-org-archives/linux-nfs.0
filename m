Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p01c12o141.mxlogic.net ([208.65.145.64]:49879 "EHLO
	p01c12o141.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756263Ab0GAO3w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 10:29:52 -0400
Content-Type: text/plain; charset=US-ASCII
Subject: RE: mount - Fedora13 - Nfsv4.1 mode
Date: Thu, 1 Jul 2010 07:24:35 -0700
Message-ID: <A062FCC8662DA848949F7C3046B9BEAE01F3A6E1@us-email.terastack.bluearc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6D1@us-email.terastack.bluearc.com> <4C2CA404.601@panasas.com>
From: "Sandeep Joshi" <sjoshi@bluearc.com>
To: "Benny Halevy" <bhalevy@panasas.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I am using fedora version from SteveD's website

2.6.33.5-112.2.2.pnfs.fc13.x86_64

I guess I have to upgrade.

regards,
Sandeep


-----Original Message-----
From: Benny Halevy [mailto:bhalevy@panasas.com]
Sent: Thu 7/1/2010 7:19 AM
To: Sandeep Joshi
Cc: linux-nfs@vger.kernel.org
Subject: Re: mount - Fedora13 - Nfsv4.1 mode
 
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

