Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:9414 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753494Ab1KACa0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 22:30:26 -0400
Subject: Re: [PATCH] Silence compiler warning
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 31 Oct 2011 22:30:22 -0400
In-Reply-To: <20111101013720.GA4237@umich.edu>
References: <20111101013720.GA4237@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320114622.10028.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-10-31 at 21:37 -0400, Jim Rees wrote: 
> I think this is still needed, isn't it?  I haven't tried compiling
> nfs-for-next but I don't see a fix for it in there.

AFAICS, this is a bogus warning: if lo is uninitialised, we will
automatically exit with a return value of NFS4ERR_NOMATCHING_LAYOUT.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

