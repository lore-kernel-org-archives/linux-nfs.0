Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:41793 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752094AbcADTBS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 14:01:18 -0500
Subject: Re: [PATCH v2 1/3] NFSD: Don't pass filehandle to
 nfs4_preprocess_stateid_op()
To: Christoph Hellwig <hch@infradead.org>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1450472727-19893-2-git-send-email-Anna.Schumaker@Netapp.com>
 <20151220154507.GA18236@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <568AC17B.1040109@Netapp.com>
Date: Mon, 4 Jan 2016 14:01:15 -0500
MIME-Version: 1.0
In-Reply-To: <20151220154507.GA18236@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/20/2015 10:45 AM, Christoph Hellwig wrote:
> On Fri, Dec 18, 2015 at 04:05:24PM -0500, Anna Schumaker wrote:
>> This reverts commit 3679e4c1ef1c00ea30d15b9ae59089b44dfe4137.
>>
>> We either pass the current_fh or save_fh from the cstate structure, and
>> not some generic filehandle.  Let's just add a flag to pick between these
>> two filehandles instead.
>>
>> Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> I don't really find this much cleaner to be honest.

Okay, I'll drop this patch.

> 
>>  fs/nfs/objlayout/Makefile |  0
> 
> how did this end up in the diffstat, btw?

My git trees just really wanted to make sure that it's there?  This change should go away when I remove the patch.

Anna
> 

