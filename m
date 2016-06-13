Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55416 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161018AbcFMSVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 14:21:06 -0400
Date: Mon, 13 Jun 2016 14:21:04 -0400
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] fix backchannel crash due to multipath
Message-ID: <20160613182104.GA19825@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On March 24 J. Bruce Fields said:
> pynfs can crash the nfs server since the new multipath code.  The
> problem is that pynfs uses the same tcp connection for multiple v4
> clients (something the spec explicitly allows).  The callback client in
> such cases has to share the same rpc_xprt.  The new rpc code, when it
> creates two callback clients sharing the same rpc_xprt, ends up trying
> to keep that rpc_xprt on the lists of two different rpc_xprt_switch's.
> The first symptom I see is a list corruption warning.
>
> So, I'm enforcing the requirement that there be only one backchannel
> rpc_xprt_switch per tcp connection by doing as we do in the rpc_xprt
> case: keeping a pointer to it in the svc_xprt, and using that when it's
> available instead of allocating a new one.

> That's a pretty straightforward fix (and I've verified it works), but
> doesn't look very elegant.  If there's a better solution, I'm all ears.

I haven't come up with anything neater, and kind of need the crash
fixed.  ACK or NACK?  I can take it through my tree if it's an ACK.

--b.
