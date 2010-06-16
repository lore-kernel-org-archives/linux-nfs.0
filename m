From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/1] NFSv4.1 set NFS4_MAX_SLOT_TABLE in
 _nfs41_proc_sequence
Date: Wed, 16 Jun 2010 09:41:56 -0400
Message-ID: <1276695716.5267.8.camel@heimdal.trondhjem.org>
References: <1276641089-6867-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:48644 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755622Ab0FPNmI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jun 2010 09:42:08 -0400
In-Reply-To: <1276641089-6867-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-06-15 at 18:31 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> _nfs41_proc_sequence() kmallocs the calldata but does not set
> calldata->res.slotid to NFS4_MAX_SLOT_TABLE, so nfs41_sequence_prepare() calls
> nfs41_setup_sequence() with the res.sr_slotid set to a random value.
> If nfs41_setup_sequence() sees res.sr_slotid as not set to NFS4_MAX_SLOT_TABLE,
> it returns without actually setting up the sequence.

Looks like a typo in my patch "NFSv41: Fix a memory leak in
nfs41_proc_async_sequence()". I'll squash your patch into that. Please
note that you will have to rebase if you try to pull the nfs-for-2.6.36
branch again.

Now.... With that said, do we really need to allow RPC calls to call
nfs41_setup_sequence with an initialised slotid? This initialisation is
a serious hassle, and is easy to forget.
When do we expect to end up hitting the res.sr_slotid !=
NFS4_MAX_SLOT_TABLE condition in real life?

Cheers
  Trond

