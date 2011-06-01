Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12336 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759549Ab1FATwX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 15:52:23 -0400
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        Weston Andros Adamson <dros@netapp.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Date: Wed, 01 Jun 2011 15:52:06 -0400
In-Reply-To: <4DE697C4.7020309@panasas.com>
References: <1306898310-9229-1-git-send-email-dros@netapp.com>
				<4DE5D287.603@panasas.com>
				<09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>
				<4DE65202.2010502@panasas.com>
			 <BANLkTi=Bwuuar76phVyEguB1Amqn4Q70Fw@mail.gmail.com>
			 <4DE68B59.3030402@panasas.com>
		 <1306955827.3873.60.camel@lade.trondhjem.org>
		 <4DE69333.4020302@panasas.com>
	 <1306957138.3873.75.camel@lade.trondhjem.org>
	 <4DE697C4.7020309@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306957926.3873.77.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-01 at 22:49 +0300, Boaz Harrosh wrote: 
> On 06/01/2011 10:38 PM, Trond Myklebust wrote:
> > 
> > There is no distinction between the MDS's idea of the wsize and the DS's
> > idea of the wsize. The DS has to support the same wsize as the MDS,
> > since the client has no way of querying the wsize from the DS (GETATTR
> > maxwrite is not on the allowed set of DS operations)...
> > 
> 
> OK I did not know that. Good god how broken is that?
> 
> Any way you are probably right. But then the check properly belongs in
> files-layout driver. Surly it has nothing to do with objects, and blocks

It belongs in the 'files' layout and in the generic (i.e. v2/v3/v4)
code.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

