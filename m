From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS _write_ Performance became horrible overnight
Date: Fri, 16 Jul 2010 16:08:02 -0400
Message-ID: <20100716200802.GA13077@fieldses.org>
References: <AANLkTinaHi1bZYRwI-jXiv_xPhQyvTUGmzBrfP-JRYs3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Igor Chudov <ichudov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41660 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754803Ab0GPUIc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Jul 2010 16:08:32 -0400
In-Reply-To: <AANLkTinaHi1bZYRwI-jXiv_xPhQyvTUGmzBrfP-JRYs3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 12, 2010 at 10:37:48AM -0500, Igor Chudov wrote:
> Hello,
> 
> I would like to apologize in advance if, for any reason, my question
> is inappropriate for this mailing list. Please let meknow if that is
> the case.
> 
> This seems to be a very odd problem that I have isolated to NFS.
> 
> I have two NFS servers. Server A and server B. They serve unrelated
> shares.
> 
> Server A is actually two servers using DRBD to stay in sync.
> 
> I also have a number of NFS clients.
> 
> Both servers worked great up to about last night.
> 
> Somehow, NFS writes became extremely slow over Server A, for all
> clients, but not for Server B.
> 
> I have no idea, yet, what changed, but wanted to ask here if anyone
> ever had a similar problem (NFS performance going to shit overnight).
> 
> Some data points:
> 
> 1) From any client, reading files over NFS is fast
> 2) From any client, writing to NFS on Server A is VERY SLOW
> 3) From any client, writing to Samba shares on Server A is fast.
> 4) From any client, writing to NFS on Server B is fast.
> 5) When logged on to Server A, copying a file from local A filesystem
> to itself is fast.

How are you measuring those exactly?  (E.g. are you including the time
to do a sync after writing?)

--b.

> 
> IOW, everything is fast, EXCEPT for NFS writes to server A.
> 
> Any ideas what might cause this sudden deterioration of Server A?
> 
> Thank you!!!!!!!!!!!
> 
> i
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
