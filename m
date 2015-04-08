Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:49590 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014AbbDHSN2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2015 14:13:28 -0400
Message-ID: <55256FC3.1060707@Netapp.com>
Date: Wed, 8 Apr 2015 14:13:23 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] mountstats: Resync NFSv4 Operations List
References: <1428511647-14920-1-git-send-email-Anna.Schumaker@Netapp.com> <1428511647-14920-2-git-send-email-Anna.Schumaker@Netapp.com> <20150408175754.GA16208@infradead.org>
In-Reply-To: <20150408175754.GA16208@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/08/2015 01:57 PM, Christoph Hellwig wrote:
> On Wed, Apr 08, 2015 at 12:47:26PM -0400, Anna Schumaker wrote:
>> We've added several operations and removed GETDEVICELIST,  Let's keep
>> the Nfsv4ops list up to date with the kernel.
> 
> Please keep GETDEVICELIST, as newer mountstats should handle older
> kernels as well.
> 
Fair enough.  I'm also working on a patch to add GETDEVICELIST back into the client.

Anna
