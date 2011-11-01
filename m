Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:60834 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753101Ab1KACmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 22:42:04 -0400
Date: Mon, 31 Oct 2011 22:42:00 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Silence compiler warning
Message-ID: <20111101024200.GA4382@umich.edu>
References: <20111101013720.GA4237@umich.edu>
 <1320114622.10028.36.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320114622.10028.36.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  On Mon, 2011-10-31 at 21:37 -0400, Jim Rees wrote: 
  > I think this is still needed, isn't it?  I haven't tried compiling
  > nfs-for-next but I don't see a fix for it in there.
  
  AFAICS, this is a bogus warning: if lo is uninitialised, we will
  automatically exit with a return value of NFS4ERR_NOMATCHING_LAYOUT.

Yes, the warning is bogus.  I just want the damn compiler to shut up so I
can see if there are any real warnings.
