From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 07/13] RFC: pnfs: full mount/umount infrastructure
Date: Mon, 13 Sep 2010 16:39:30 +0200
Message-ID: <4C8E37A2.4090103@panasas.com>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com> <1283450419-5648-8-git-send-email-iisaman@netapp.com> <20100910235858.GB11231@infradead.org> <1284163679.14078.106.camel@heimdal.trondhjem.org> <4C8E0A03.3020500@panasas.com> <20100913142851.GA10170@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:39173 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751208Ab0IMOjd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 10:39:33 -0400
In-Reply-To: <20100913142851.GA10170@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2010-09-13 16:28, Christoph Hellwig wrote:
> On Mon, Sep 13, 2010 at 01:24:51PM +0200, Benny Halevy wrote:
>> However, on the longer run I'd like us to consider formalizing
>> the kABI for non-GPLed layout drivers.
> 
> No.  Non-GPLed drivers will have a very hard way to stand against the
> derived work clauses for some specificly written new code anyway, and
> if you haven't noticed yet there's no kABI in mainline anyway.  
> 
>> I think that this is a great selling point as it fully materializes the
>> extensibility of the layout-type / layout-driver design model.
> 
> Drinking again?
> 

Heh, just water :-)

I guess I'll have to agree to disagree.

Benny
