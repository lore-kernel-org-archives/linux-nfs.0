From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: How to get the file path from file handle - NFS.
Date: Thu, 9 Sep 2010 12:01:06 -0400
Message-ID: <20100909160106.GE8597@fieldses.org>
References: <D3F292ADF945FB49B35E96C94C2061B90D1991A4@nsmail.netscout.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752101Ab0IIQB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Sep 2010 12:01:59 -0400
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90D1991A4-2s2rCY1e8UXHBhWB4kaBDUEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 09, 2010 at 08:24:40AM -0400, Tayade, Nilesh wrote:
> Hi,
> 
> I seek some pointers on how to obtain the file path from the file
> handle. The NFS protocol exchange the file handle between the Server and
> Client. 
> I want to extract the file path at client side from the available file
> handle. 
> 
> I went through some of the reference documents. It say- 
> The mapping exists in /var/nfs/fhpath or /etc/default/nfslogd files. And
> can be configured through /etc/nfs/nfslog.conf.
> http://docstore.mik.ua/orelly/networking_2ndEd/nfs/ch14_06.htm

Looks like a Solaris thing?  This isn't the right list for that.

--b.

> 
> But essentially I am looking forward extracting it through application C
> code (may be getting the pointer to the hash table etc.)- the reason
> being I want to avoid file open, read operations (on the nfslogd file)
> due to performance issue. 
> 
> Could someone please advice if it is possible to extract it through some
> structure? Can we directly try to read the mapping hash table at client
> side?
> 
> 
> --
> Thanks,
> Nilesh
> x46222
> Yahoo IM: nilesh_tayade85
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
