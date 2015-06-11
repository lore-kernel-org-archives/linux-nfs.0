Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:33795 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752264AbbFKJN0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2015 05:13:26 -0400
Received: by qgf75 with SMTP id 75so306511qgf.1
        for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2015 02:13:25 -0700 (PDT)
Message-ID: <5579512B.60009@gmail.com>
Date: Thu, 11 Jun 2015 17:13:15 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, kinglongmee@gmail.com
Subject: Re: [PATCH 1/2] nfs: Only update callback sequnce id when CB_SEQUENCE
 success
References: <556D8C66.8080203@gmail.com> <5578E67C.1030303@gmail.com> <20150611082028.GA11330@infradead.org>
In-Reply-To: <20150611082028.GA11330@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/11/2015 4:20 PM, Christoph Hellwig wrote:
> Hi Kinglong,
> 
> when we last brought up this issue the recommendation was to follow
> the model in the clients nfs41_sequence_done() which handles even
> more corner cases.  Given that my previous fixes in that area were
> just a bandaid I probably shouldn't complain about piece mail handling,
> but if you have a little spare time available implementing the full
> set of checks might be worthwhile.

Thank you for your comments.

I have see your patches sits "nfsd: callback fixes". You said process as
nfs41_sequence_done() for handling error cases is server's logical.

Those two patches for NFS client are fix two bugs.

The first one is fix that between validate_seqid() nfs can return error
to nfs server. NFS server cannot make sure whether NFS client has update
the sequence ID.

Also, according to RFC, "If CB_SEQUENCE returns an error, then the state
of the slot (sequence ID, cached reply) MUST NOT change.",
so that this this patch is out.

The second for nfs is fix the initialize problem of cb_sequenceres
when meeting NFS4ERR_RETRY_UNCACHED_REP.

And, other two patches for nfsd, 
The first is fix a infinite loop caused by your last patch I meet.
The second is as you said following to nfs41_sequence_done() maybe better.

thanks
Kinglong Mee
