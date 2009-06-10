From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] NFS: Add acreg{min,max} and acdir{min,max} in
 milliseconds
Date: Wed, 10 Jun 2009 08:27:24 -0400
Message-ID: <1244636844.24750.23.camel@heimdal.trondhjem.org>
References: <200906091832.50633.agud@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, gud-OYTqUY/oFF8@public.gmane.org,
	"Uhlenkott, Jason" <juhlenko@akamai.com>
To: Amit Gud <agud@akamai.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:59907 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755757AbZFJM11 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jun 2009 08:27:27 -0400
In-Reply-To: <200906091832.50633.agud@akamai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-06-09 at 18:32 -0700, Amit Gud wrote:
> This patch adds 4 new NFS mount options(acdirminms, acdirmaxms, acregminms,
> acregmaxms) converting already existing one into a millisecond resolution
> instead of seconds.
> 
> Also, modifies the mountstats output to milliseconds instead of seconds.

Why, exactly, do you need to control cache timeouts down to the
millisecond level?

Trond

