Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:36090 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755378Ab0LBS1M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 13:27:12 -0500
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB2IA4oW014111
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 13:10:10 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 87EE772AD67
	for <linux-nfs@vger.kernel.org>; Thu,  2 Dec 2010 12:44:55 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB2Hit3Q097892
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 12:44:55 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB2His6j014394
	for <linux-nfs@vger.kernel.org>; Thu, 2 Dec 2010 10:44:54 -0700
Subject: Re: [PATCH] NFS client has troubles with fileid with bit 31 (or
	bit 63) set
From: Frank Filz <ffilzlnx@us.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: ffilz@us.ibm.com, NFS List <linux-nfs@vger.kernel.org>
In-Reply-To: <1291259596.6609.109.camel@heimdal.trondhjem.org>
References: <1291251786.5075.6.camel@KPMH461.ibm.com>
	 <1291253786.6609.90.camel@heimdal.trondhjem.org>
	 <1291258912.5075.10.camel@KPMH461.ibm.com>
	 <1291259596.6609.109.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Thu, 02 Dec 2010 09:44:50 -0800
Message-Id: <1291311890.5075.23.camel@KPMH461.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Wed, 2010-12-01 at 22:13 -0500, Trond Myklebust wrote:
> I'm suggesting it should rather match the compat_ulong_t, since that is
> what 64-bit kernels will need to deal with if running a 32-bit
> userspace. For 64-bit kernels that have no 32-bit userspace emulation
> layer, why would we care about returning a truncated 32-bit fileid?
> 
> Conversely, if running a 32-bit kernel, then 'unsigned long' will
> directly match the types used by fs/readdir.c:filldir()

Ah, got it now... Sorry for denseness...

Hmm, what would be ideal is for nfs_compat_user_ino64() to know if it's
value will be passed to compat_filldir or filldir. If we use
compat_ulong_t when CONFIG_COMPAT is defined, and enable_ino64 = 0, it
will always reduce the fileid to 32 bits, even if being passed to
filldir on a 64 bit machine which is prepared to take a 64 bit fileid.
On the other hand, if enable_ino64 = 1, then fileids >= 2^32 will cause
an error if a 32 bit user space application is being invoked.

With enable_ino64 = 1 on a machine otherwise enabled for 64 bit inode
numbers, it will definitely work like any local file system with 64 bit
inode numebers.

With enable_ino64 = 0, it will always force fileid into 32 bits if there
is any 32 bit user space, which I suppose is good behavior.

I will submit a revised patch.

Thanks

Frank

