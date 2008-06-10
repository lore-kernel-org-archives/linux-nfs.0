From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Move fs/nfs/iostat.h to include/linux
Date: Tue, 10 Jun 2008 14:58:28 -0400
Message-ID: <1213124308.20459.20.camel@localhost>
References: <20080606172037.14757.64893.stgit@manray.1015granger.net>
	 <20080606172216.14757.18706.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31389 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756868AbYFJS6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 14:58:31 -0400
In-Reply-To: <20080606172216.14757.18706.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-06-06 at 10:22 -0700, Chuck Lever wrote:
> The fs/nfs/iostat.h header has definitions that were designed to be
> exposed
> to user space.  Move the header under include/linux so user space can
> use
> the header in applications that read /proc/self/mountstats.

The correct way to do this is to move _only_ those parts which are
designed to be exposed to user space into include/linux, and leave the
#ifdef __KERNEL__ protected stuff where it is.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
