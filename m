Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:33166 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757884Ab1ANQIP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 11:08:15 -0500
Subject: Re: 4.1 no-pnfs mount option?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Jim Rees <rees@umich.edu>
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20110114153846.GA21766@merit.edu>
References: <20110114151945.GA21629@merit.edu>
	 <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com>
	 <20110114153846.GA21766@merit.edu>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 14 Jan 2011 10:41:52 -0500
Message-ID: <1295019712.3576.1.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-01-14 at 10:38 -0500, Jim Rees wrote: 
> William A. (Andy) Adamson wrote:
> 
>   No mount option - just configure your machine to not load any pnfs
>   layoutdriver modules.
> 
> That works, thanks, but I was hoping for a way to have layout and non-layout
> mounts going on at the same time.

Different VMs?

Trond

