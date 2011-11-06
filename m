Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:51123 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752089Ab1KFVTj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Nov 2011 16:19:39 -0500
Date: Sun, 6 Nov 2011 16:19:33 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: rpcbind -h
Message-ID: <20111106211933.GA2626@umich.edu>
References: <20111106155844.GA1790@umich.edu>
 <1320599727.26609.0.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320599727.26609.0.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  On Sun, 2011-11-06 at 10:58 -0500, Jim Rees wrote: 
  > Is there some good reason why the rpcbind '-h' option (bind to given
  > address) applies only to the udp listening socket and not to the tcp socket?
  > 
  > And is there any good reason why an nfs3 client not providing any services
  > would need to run rpcbind?
  
  Yes: lockd and statd...

Oh yeah, I forgot about those v3 relics.  How about if all my mounts are
nolock?  And what about the '-h' option?  It almost looks like a mistake,
but it's documented to work that way.
