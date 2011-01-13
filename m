Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51752 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016Ab1AMVBm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Jan 2011 16:01:42 -0500
Subject: Re: nfsv4 + readdir == too many requests
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: NFS list <linux-nfs@vger.kernel.org>
In-Reply-To: <4D2F5FE1.6050509@desy.de>
References: <4D2F5FE1.6050509@desy.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 13 Jan 2011 16:01:02 -0500
Message-ID: <1294952462.3038.29.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-01-13 at 21:26 +0100, Tigran Mkrtchyan wrote: 
> 
> By running intensive tests I notice that readdir oration over nfsv4.1
> asks for
> file attributes in readdir (attr_request) and later on for each file. To
> me it looks like
> broken.
> 
> This 2.6.37 + pnfs-all-latests :
> 
> git://linux-nfs.org/~bhalevy/linux-pnfs.git
> 378978453b64bf895de8cd0e68dbcd9e9c0155ce
> 
> 100% reproducible.

1) What makes you think this is broken, and not just a case of the
attribute cache timing out and/or the directory changing?
2) Can you produce a testcase that proves brokenness?
3) Can you reproduce on a non-pnfs-all-latests kernel?

Readdir shouldn't be affected by the stuff in Benny's tree, but I'm
always wary of tests on out-of-mainline trees.

Cheers
   Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

