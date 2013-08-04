Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:30828 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590Ab3HDTUF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 4 Aug 2013 15:20:05 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: clientid is in use
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51FBDB14.4040801@uw.edu>
Date: Sun, 4 Aug 2013 15:20:00 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <BE9C4EAA-B835-4021-86C2-D91F66BFF7C8@oracle.com>
References: <51FBDB14.4040801@uw.edu>
To: Harry Edmon <harry@uw.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 2, 2013, at 12:15 PM, Harry Edmon <harry@uw.edu> wrote:

> Occasionally I am seeing the following in our kernel log on a NFS client:
> 
> [2321389.137595] NFS: Server enkf reports our clientid is in use
> [2321389.137615] NFS: state manager: lease expired failed on NFSv4 server enkf with error 1
> 
> The result is that the read of the file in question fails.   This occurs for multiple kernel versions on multiple machines.  Anyone have an idea how I should start debugging this?  How is the clientid calculated/assigned?

It depends on the kernel version.  You can look in fs/nfs/nfs4proc.c for the nfs4_proc_setclientid function.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




