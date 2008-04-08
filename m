From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Finding processes causing NFS traffic
Date: Tue, 08 Apr 2008 12:20:01 -0400
Message-ID: <1207671601.10273.4.camel@heimdal.trondhjem.org>
References: <200804081606.37951.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Christoph Bartoschek <bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:42786 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbYDHQUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 12:20:04 -0400
In-Reply-To: <200804081606.37951.bartoschek-eefaeeawk+jFLWzOrOlZPg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Tue, 2008-04-08 at 16:06 +0200, Christoph Bartoschek wrote:
> Hi,
> 
> is there a tool that shows me which processes cause NFS traffic?
> 
> Greetings
> Christoph

There is always systemtap.

  Trond

