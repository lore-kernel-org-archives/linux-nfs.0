From: "J. R. Okajima" <hooanon05-/E1597aS9LR3+QwDJ9on6Q@public.gmane.org>
Subject: Re: [PATCH 10/12] NFS: Simplify nfs_wb_page()
Date: Fri, 12 Mar 2010 13:22:07 +0900
Message-ID: <6155.1268367727@jrobl>
References: <20100125221544.16750.70574.stgit@localhost.localdomain> <20100125221545.16750.19154.stgit@localhost.localdomain> <16839.1268247109@jrobl> <1268249482.3096.76.camel@localhost.localdomain> <1268252300.3096.81.camel@localhost.localdomain> <22120.1268282756@jrobl> <1268317582.3354.9.camel@localhost.localdomain>
Cc: linux-nfs@vger.kernel.org, Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	Jens Axboe <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, linux-fsdevel@vger.kernel.org,
	Christoph Hellwig <hch@lst.de>,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mtoichi11.ns.itscom.net ([219.110.2.181]:35195 "EHLO
	mtoichi11.ns.itscom.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753020Ab0CLEW6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Mar 2010 23:22:58 -0500
In-Reply-To: <1268317582.3354.9.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond Myklebust:
> Oops... Yes, that needs to be fixed, and we should probably make
> nfs_set_page_tag_locked() safe too.
>
> How about the following? I can't seem to find any further dereferences
> of req->wb_context after the nfs_clear_request().

It passed all of my local tests successfully.
Thank you.


J. R. Okajima
