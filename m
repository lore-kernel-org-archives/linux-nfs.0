From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Client performance questions
Date: Mon, 10 Dec 2007 18:10:26 -0500
Message-ID: <1197328226.25938.7.camel@heimdal.trondhjem.org>
References: <0a15723c4b267d4eb8b5ad05800315c0@swip.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Fredrik Lindgren <fli-FpffG6+3qsA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:41596 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbXLJXKe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 18:10:34 -0500
In-Reply-To: <0a15723c4b267d4eb8b5ad05800315c0-FpffG6+3qsA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mon, 2007-12-10 at 22:52 +0100, Fredrik Lindgren wrote:
> Hello
> 
> We have a mail-application running on a set of Linux machines using NFS
> for the storage. Recently iowait on the machines has started to become
> a problem, and it seems that they can't quite keep up. Iowait figures of
> 50% or above are not uncommon during peak hours.

Have you tried increasing the value
in /proc/sys/fs/nfs/nfs_congestion_kb ?

Cheers
  Trond

