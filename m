From: Jeff Garzik <jeff@garzik.org>
Subject: Re: major NFSv4 client regression (-rc7)
Date: Thu, 10 Jan 2008 16:04:20 -0500
Message-ID: <47868854.8030303@garzik.org>
References: <20080110204119.GA714@havoc.gtf.org> <1199998294.13775.8.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55328 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757238AbYAJVEZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jan 2008 16:04:25 -0500
In-Reply-To: <1199998294.13775.8.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> This looks as if it might be the same issue that was reported as bug
> 9712 in bugzilla (http://bugzilla.kernel.org/show_bug.cgi?id=9712).
> 
> The fix is attached. Please could you confirm that it fixes the hang?


Indeed, it looks fixed here, thanks...

	Jeff (now running 2.6.24-rc7-trond1-gfd0b45df-dirty)






