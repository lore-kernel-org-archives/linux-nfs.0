From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: RPC retransmission of write requests containing bogus data
Date: Fri, 17 Oct 2008 14:01:09 +0100
Message-ID: <1224248469.9053.119.camel@zakaz.uk.xensource.com>
References: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
	 <1224247725.7722.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49383 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYJQNBP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2008 09:01:15 -0400
In-Reply-To: <1224247725.7722.4.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-10-17 at 08:48 -0400, Trond Myklebust wrote:
> I don't see how this could be an RPC bug. The networking layer is
> supposed to either copy the data sent to the socket, or take a reference
> to any pages that are pushed via the ->sendpage() abi.
> 
> IOW: the pages are supposed to be still referenced by the networking
> layer even if the NFS layer and page cache have dropped their
> references.

The pages are still referenced by the networking layer. The problem is
that the userspace app has been told that the write has completed so it
is free to write new data to those pages.

Ian.


