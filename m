From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c
	(157)
Date: Thu, 14 Aug 2008 15:29:20 -0400
Message-ID: <20080814192920.GG23859@fieldses.org>
References: <20080814152421.GA8056@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	netdev@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33544 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752986AbYHNT3V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Aug 2008 15:29:21 -0400
In-Reply-To: <20080814152421.GA8056@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 14, 2008 at 05:24:21PM +0200, Frank van Maarseveen wrote:
> There are not many reports of this but it seems related to stopping the
> NFS server. I'm seeing them occasionally on system shutdown right after
> 
> 	nfsd: last server has exited 
> 	nfsd: unexporting all filesystems 
> 
> kernels: 2.6.25, 2.6.26

A couple minutes with grep wasn't enough for me to figure out what
sk_forward_alloc was or why this assertion should be failing, so I'm
cc'ing netdev in hopes they might have some hints!

--b.
