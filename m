Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:19445 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750805Ab2ADROf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jan 2012 12:14:35 -0500
Message-ID: <1325697256.18462.24.camel@lade.trondhjem.org>
Subject: Re: [PATCH 2/2] NFS: Cache state owners after files are closed
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 04 Jan 2012 12:14:16 -0500
In-Reply-To: <1ABF105B-C779-4CF7-9494-0AA775407718@oracle.com>
References: <20111206210723.5969.85159.stgit@degas.1015granger.net>
	 <20111206211348.5969.61933.stgit@degas.1015granger.net>
	 <1325692415.18462.6.camel@lade.trondhjem.org>
	 <1325692758.18462.10.camel@lade.trondhjem.org>
	 <CBB27FEB-BA9A-408E-85A7-A3F63F7B280B@oracle.com>
	 <1325693647.18462.15.camel@lade.trondhjem.org>
	 <1ABF105B-C779-4CF7-9494-0AA775407718@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-01-04 at 12:07 -0500, Chuck Lever wrote: 
> On Jan 4, 2012, at 11:14 AM, Trond Myklebust wrote:
> As you state above, on our client state owners actually pin resources.  They are more than a label and a counter.
> 
> If you prefer "GC last" I can change my patch (or you can).

Please do. It is slightly more efficient in the corner case I pointed
out, and should leave all other cases unaffected...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

