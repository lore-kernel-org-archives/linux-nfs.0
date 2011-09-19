Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:56466 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777Ab1ISCEd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 18 Sep 2011 22:04:33 -0400
Date: Sun, 18 Sep 2011 22:04:31 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, Peng Tao <bergwolf@gmail.com>,
        linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
Message-ID: <20110919020431.GA18269@merit.edu>
References: <1315945452-1575-1-git-send-email-rees@umich.edu>
 <4E707FC1.2020607@tonian.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B356025@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B356025@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Myklebust, Trond wrote:

  > -----Original Message-----
  > From: Benny Halevy [mailto:bhalevy@tonian.com]
  > Sent: Wednesday, September 14, 2011 6:20 AM
  > To: Jim Rees; Peng Tao; Myklebust, Trond
  > Cc: linux-nfs@vger.kernel.org; peter honeyman
  > Subject: Re: [PATCH] pnfsblock: add missing rpc_put_mount and path_put
  > 
  > We need to decide on a process here :)
  > If we would like to maintain a staging tree in front of Trond's then
  to simplify
  > merging and rebasing, fixes to code that's already upstream, i.e. in
  linux-2.6
  > or already queued in nfs-2.6, that we decide to send to Trond ahead of
  > queue need to be queued in front of stuff in the staging tree and the
  latter
  > should be rebased on top of them.
  
  Unless we're talking about a large merge, I tend to prefer patches. They
  are much easier to review...

I guess the problem is that we now have a patch in Trond's tree that
conflicts with the workqueue patch that's staged for later in Benny's tree.
I think what I need to do is send Benny a set of patches that starts with
the same patch I sent Trond, and follows with one that adds the workqueue.
