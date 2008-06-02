From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC] nfsd: make nfs4xdr WRITEMEM safe against zero count
Date: Mon, 2 Jun 2008 12:49:09 -0400
Message-ID: <20080602164909.GE18887@fieldses.org>
References: <483E7DB8.1050705@panasas.com> <3C91B431-664C-4D9C-B85A-4152B4624168@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52087 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbYFBQtb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2008 12:49:31 -0400
In-Reply-To: <3C91B431-664C-4D9C-B85A-4152B4624168@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 29, 2008 at 12:24:58PM -0400, Chuck Lever wrote:
> By the way, here is a pointer to the old work:
>
>   http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=shortlog;h=drop-20070423
>
> The work in this snapshot is only partially complete.
>
> There are many many issues to fix up.  One of the bigger ones is that  
> the RPC layer still takes the BKL during XDR encoding and decoding.  But 
> I wanted to create something that could be fully or partially shared by 
> the client and server implementations, and that would be more rigorous 
> about static and dynamic type checking.
>
> In addition, the NFSv4 routines use a new style of managing the RPC  
> buffer that I wanted to adopt for the other in-kernel XDR routines, then 
> convert the RPC client to use only the new style when invoking XDR 
> routines.  I never got that far, but I still think it's a reasonable 
> goal.

To find something manageable to start with, what's the minimum first
step that that would achieve Benny's goal of replacing those server-side
xdr macros?

>From a quick glance at the patches: a kerneldoc comment for each xdr
encode/decode seems like overkill, since it's mostly boilerplate; could
we document those arguments just once with the definition of kxdrproc_t,
then refer to that comment as necessary?

Anyway, seems like good stuff to me.

--b.
