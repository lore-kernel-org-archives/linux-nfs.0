Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24136 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756342Ab1BCUKf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 15:10:35 -0500
Subject: Re: Client hangs in __mutex_lock_slowpath, network connection
 maxed out
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <4D4AEE47.8080504@rath.org>
References: <4D4AEE47.8080504@rath.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Feb 2011 15:10:11 -0500
Message-ID: <1296763811.3015.28.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-03 at 13:04 -0500, Nikolaus Rath wrote: 
> Hello,
> 
> I'm mounting an NFS4 volume from a kernel 2.6.32-27 server in a
> 2.6.37-020637rc2 client.

2.6.37-rc2 is known to have a number of NFS bugs (particularly in the
readdir code) which are fixed in the 2.6.37 release. Please upgrade.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

