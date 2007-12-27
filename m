From: Jeff Garzik <jeff@garzik.org>
Subject: Re: read-ahead in NFS server
Date: Wed, 26 Dec 2007 21:34:23 -0500
Message-ID: <47730F2F.3080900@garzik.org>
References: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-kernel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>
To: saeed bishara <saeed.bishara@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54521 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824AbXL0Ce3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Dec 2007 21:34:29 -0500
In-Reply-To: <c70ff3ad0712260351i6583aa8dpbf16ed606a634b1f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

saeed bishara wrote:
> Hi,
> my NFS server seems not to utilize the read-ahead feature, my exported
> dir is located on ext3 fs over sata disk. the sata controller can
> issue commands up to 1MB, also I modified the read ahead under the sys
> to 1MB. but when the client do reads in 32KB chunks (rsize), I can see
> in the server side that all IOs are ~32KB. my kernel version is
> 2.6.22.7.
> according to the nfsd code, the NFS server should utilize the
> read-ahead feature, but what should I do
> to make it work?

(linux-nfs added to cc)

I cannot speak for the NFS server code specifically, but 32kb sounds 
like a network read (or write) data size limit.

Are you using TCP?  Are you using NFSv4, or an older version?

	Jeff


