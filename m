Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56102 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759710Ab3EORsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 13:48:06 -0400
Date: Wed, 15 May 2013 13:48:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
Message-ID: <20130515174806.GO16811@fieldses.org>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net>
 <20130513162528.1942.64673.stgit@seurat.1015granger.net>
 <20130515160424.GK16811@fieldses.org>
 <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com>
 <20130515171601.GL16811@fieldses.org>
 <20130515173916.GM16811@fieldses.org>
 <D8763141-7185-499B-ADFA-659F9992269C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D8763141-7185-499B-ADFA-659F9992269C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 01:42:58PM -0400, Chuck Lever wrote:
> 
> On May 15, 2013, at 1:39 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > By the way, have you looked at SP4_MACH_CRED at all yet?  It's a
> > selfish question (I could use something to test against), but I
> > think it's also what you want if you want krb5i-protected 4.1 state.
> 
> I asked about that recently and was told SP4_MACH_CRED was going the
> way of the do do

Do you remember who said that?  Is the discussion on line somewhere?

> (or did I misunderstand the response from the floor?).
> 
> I'm certainly open to exploring other solutions, but I do want to be
> practical about it.  Will it be supported on other servers besides
> Linux?  Does SP4_MACH_CRED help for NFSv4.0?

I haven't tested other servers.  It's a 4.1-only feature.

--b.
