Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:33637 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755519AbaFBQwq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 12:52:46 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'J. Bruce Fields'" <bfields@fieldses.org>
Cc: "'Devesh Sharma'" <Devesh.Sharma@Emulex.Com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <tom@opengridcomputing.com>
References: <20140529165532.16349.95248.stgit@build.ogc.int> <EE7902D3F51F404C82415C4803930ACD3FE01265@CMEXMB1.ad.emulex.com> <000001cf7c07$72e613d0$58b23b70$@opengridcomputing.com> <EE7902D3F51F404C82415C4803930ACD3FE01355@CMEXMB1.ad.emulex.com> <004101cf7e82$68b58ad0$3a20a070$@opengridcomputing.com> <20140602165151.GA20031@fieldses.org>
In-Reply-To: <20140602165151.GA20031@fieldses.org>
Subject: RE: [PATCH V3] svcrdma: refactor marshalling logic
Date: Mon, 2 Jun 2014 11:52:47 -0500
Message-ID: <004901cf7e83$15107790$3f3166b0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > You're correct.  And this bug appears to be in the current upstream code as well.  If
an
> > IB_WR_LOCAL_INV wr is used, it must include IB_SEND_FENCE to fence it until the prior
> read
> > completes.
> >
> > Good catch!  I'll post V4 soon.
> 
> Any chance that can be handled as a separate patch rather than folded
> in?
> 
> (Disclaimer: I've been following the discussion only very
> superficially.)
> 

Sure.  I'll post the patch soon.

