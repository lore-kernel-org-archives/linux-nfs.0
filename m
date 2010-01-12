From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] Create shared API to access on-disk NSM data
Date: Tue, 12 Jan 2010 07:25:33 -0500
Message-ID: <4B4C6A3D.8070009@RedHat.com>
References: <20100108180144.452.14970.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55663 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392Ab0ALMZi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jan 2010 07:25:38 -0500
In-Reply-To: <20100108180144.452.14970.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/08/2010 01:13 PM, Chuck Lever wrote:
> The goal of these patches is to replace duplicate code in statd and
> sm-notify that accesses the local NSM state number and the on-disk
> monitor and notify lists.  This change allows us to fix bugs and add
> IPv6 support in one place instead of two.
> 
> There should be little behavioral change, since the new code in
> libnsm.a is by and large copied from existing code in statd and
> sm-notify.  Some error checking is enhanced.  The sync(2) system call
> done after an NSM state number update is removed, since the update is
> already performed with POSIX file system calls that are all
> synchronous with permanent storage.
> 
> ---
> 
> Chuck Lever (3):
>       statd: Use the new nsm_ file.c calls in rpc.statd
>       statd: Use the new nsm_ file.c calls in sm_notify
>       libnsm.a: Introduce common routines to handle persistent storage
Committed...

steved.
