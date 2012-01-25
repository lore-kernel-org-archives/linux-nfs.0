Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:38639 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753927Ab2AYPSY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 10:18:24 -0500
Message-ID: <4F201D30.8010606@panasas.com>
Date: Wed, 25 Jan 2012 17:18:08 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. von Balzac" <jhm.balzac@gmail.com>, <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 - Linux server, FreeBSD client
References: <CAG+vHK+OUSdEc5L=_oeq4Y9iwseusspPTG=jwUvoOQd5587O9Q@mail.gmail.com> <20120125143449.GB17873@fieldses.org>
In-Reply-To: <20120125143449.GB17873@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/25/2012 04:34 PM, J. Bruce Fields wrote:
> Also, "fsid=0" tricks aren't necessary any more: if you just leave out
> that line, then v4 clients will be able to mount /exp/freebsd/* just as
> v2/v3 clients would.
> 

I suspected this, but have been using fsid=0 since forever and the :/ mounts.
I'll check it out

I know it's not your expertise, but is it also true for pnfs. (Benny's tree)
Or like before pnfs export must have the fsid=0 set?

What about multiple SBs / FSs exporting pnfs should that work? I guess I should
try it.

Thanks
Boaz
