Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61205 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812Ab2AGI7U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jan 2012 03:59:20 -0500
Message-ID: <1325926751.4847.8.camel@lappy>
Subject: Re: Boot regression caused by commit 6829a048
From: Sasha Levin <levinsasha928@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: chuck.lever@oracle.com, linux@razik.name,
        Pekka Enberg <penberg@kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Date: Sat, 07 Jan 2012 10:59:11 +0200
In-Reply-To: <1325891801.11799.5.camel@lade.trondhjem.org>
References: <1325871176.4629.35.camel@lappy>
	 <1325874404.32470.6.camel@lade.trondhjem.org>
	 <1325892770.4847.1.camel@lappy>
	 <1325891801.11799.5.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-01-06 at 18:16 -0500, Trond Myklebust wrote:
> A simple fix would be either:
> 
> A) skip the root=/dev/root.

"/dev/root" is actually the name of the 9p device, I can't omit that part since then 9p won't boot.

> B) change mount_root to also test MINOR(ROOT_DEV), which should equal
> 255 if ROOT_DEV==Root_NFS 

I'll simply check if ROOT_DEV==Root_NFS then.

-- 

Sasha.

