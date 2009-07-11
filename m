Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:55610 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751426AbZGKWt4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 Jul 2009 18:49:56 -0400
Subject: Re: How to monitor Linux NFS client load?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Andrey Borzenkov <arvidjaar@mail.ru>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <1247352267.7281.2.camel@heimdal.trondhjem.org>
References: <200907112103.27082.arvidjaar@mail.ru>
	 <1247352267.7281.2.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Sat, 11 Jul 2009 18:49:52 -0400
Message-Id: <1247352592.7281.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, 2009-07-11 at 18:44 -0400, Trond Myklebust wrote:
> On Sat, 2009-07-11 at 21:03 +0400, Andrey Borzenkov wrote:
> > I am grateful for any hints how can we monitor Linux NFS client and get 
> > real-life numbers of what happens inside. Thank you!
> 
> See the nfs-iostat utility in the nfs-utils package:
> 
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=tools/nfs-iostat/nfs-iostat.py;h=9626d42609b9485c7fda0c9ef69d698f9fa929fd;hb=HEAD

Oh, and recent versions of 'sar' (from the 'sysstat' package) should
also have support for NFS monitoring.

Trond

