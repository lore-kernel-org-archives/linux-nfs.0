Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:10932 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034AbbDNOet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Apr 2015 10:34:49 -0400
Message-ID: <552D2586.902@Netapp.com>
Date: Tue, 14 Apr 2015 10:34:46 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] NFS: Add stubs for GETDEVICELIST
References: <1428680559-26705-1-git-send-email-Anna.Schumaker@Netapp.com> <20150413174538.GA22583@infradead.org>
In-Reply-To: <20150413174538.GA22583@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/13/2015 01:45 PM, Christoph Hellwig wrote:
> On Fri, Apr 10, 2015 at 11:42:39AM -0400, Anna Schumaker wrote:
>> d4b18c3e (pnfs: remove GETDEVICELIST implementation) removed the
>> GETDEVICELIST operation from the NFS client, but left a "hole" in the
>> nfs4_procedures array.  This caused /proc/self/mountstats to report an
>> operation named "51" where GETDEVICELIST used to be.  This patch adds
>> back stubs to fix mountstats.
> 
> The only thing we need here is the name, right?  Why not add a STUB
> macro that just fills out the name field?

Good idea.  I just sent a patch to do just that!

Anna
> 

