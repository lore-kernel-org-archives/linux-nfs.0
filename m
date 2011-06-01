Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:49225 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759550Ab1FATte (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 15:49:34 -0400
Message-ID: <4DE697C4.7020309@panasas.com>
Date: Wed, 01 Jun 2011 22:49:24 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        Weston Andros Adamson <dros@netapp.com>, trond@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: filelayout should use nfs_generic_pg_test
References: <1306898310-9229-1-git-send-email-dros@netapp.com>			<4DE5D287.603@panasas.com>			<09816808-BA7B-4EAF-A18A-866B5A98BF25@netapp.com>			<4DE65202.2010502@panasas.com>		 <BANLkTi=Bwuuar76phVyEguB1Amqn4Q70Fw@mail.gmail.com>		 <4DE68B59.3030402@panasas.com>	 <1306955827.3873.60.camel@lade.trondhjem.org>	 <4DE69333.4020302@panasas.com> <1306957138.3873.75.camel@lade.trondhjem.org>
In-Reply-To: <1306957138.3873.75.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/01/2011 10:38 PM, Trond Myklebust wrote:
> 
> There is no distinction between the MDS's idea of the wsize and the DS's
> idea of the wsize. The DS has to support the same wsize as the MDS,
> since the client has no way of querying the wsize from the DS (GETATTR
> maxwrite is not on the allowed set of DS operations)...
> 

OK I did not know that. Good god how broken is that?

Any way you are probably right. But then the check properly belongs in
files-layout driver. Surly it has nothing to do with objects, and blocks

Thanks
Boaz
