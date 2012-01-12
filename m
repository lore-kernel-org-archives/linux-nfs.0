Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45315 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755630Ab2ALVpg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2012 16:45:36 -0500
Message-ID: <1326404734.10529.3.camel@lade.trondhjem.org>
Subject: Re: [PATCH-v2 7/9] pnfsblock: alloc short extent before submit bio
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Peng Tao <bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, mdw@umich.edu, honey@citi.umich.edu,
        Peng Tao <peng_tao@emc.com>, Benny Halevy <bhalevy@tonian.com>
Date: Thu, 12 Jan 2012 16:45:34 -0500
In-Reply-To: <1326381528-2232-8-git-send-email-bergwolf@gmail.com>
References: <1326381528-2232-1-git-send-email-bergwolf@gmail.com>
	 <1326381528-2232-8-git-send-email-bergwolf@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-01-12 at 23:18 +0800, Peng Tao wrote: 
> As discussed earlier, it is better for block client to allocate memory for
> tracking extents state before submitting bio. So the patch does it by allocating
> a short_extent for every INVALID extent touched by write pagelist and for
> every zeroing page we created, saving them in layout header. Then in end_io we
> can just use them to create commit list items and avoid memory allocation there.

Ditto

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

