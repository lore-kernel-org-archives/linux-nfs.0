Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:56784 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751055Ab0KVSoM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Nov 2010 13:44:12 -0500
Subject: Re: [PATCH] lockd: release memory for non-normal situation
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Wengang Wang <wen.gang.wang@oracle.com>, linux-nfs@vger.kernel.org,
        greg.marsden@oracle.com, joe.jin@oracle.com
In-Reply-To: <86295CE6-C2D8-4186-BF51-455A5C190F3A@oracle.com>
References: <201011221243.oAM931FO003822@rcsinet13.oracle.com>
	 <86295CE6-C2D8-4186-BF51-455A5C190F3A@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 22 Nov 2010 13:44:07 -0500
Message-ID: <1290451447.2909.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-22 at 12:15 -0500, Chuck Lever wrote:
> Hi-
> 
> On Nov 22, 2010, at 7:40 AM, Wengang Wang wrote:
> 
> > nlmclnt_proc() is neither releasing nlm_rqst nor dropping the ref on nlm_host.
> > Do the release work though I am not sure if it can really hit the situation.
> 
> Based on casual code review, the only case where this is a possibility is the "out_unlock" label in nlmclnt_lock().  Otherwise, this patch introduces a double release in other cases, doesn't it?

No. It only occurs if !IS_GETLK(cmd) && !IS_SETLK(cmd) && !
IS_SETLKW(cmd). The VFS should ensure this never happens, so I don't
think this is an exploitable bug.

The question therefore is: do we add this fix, or do we just remove the
-EINVAL error condition and replace it by a BUG()?

Cheers
  Trond

