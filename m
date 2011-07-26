Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:52359 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab1GZQIX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 12:08:23 -0400
Date: Tue, 26 Jul 2011 12:08:05 -0400
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Peng Tao <bergwolf@gmail.com>, tao.peng@emc.com, linux-nfs@vger.kernel.org,
        bhalevy@tonian.com
Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
Message-ID: <20110726160805.GA1922@merit.edu>
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
 <4E18614C.4010002@tonian.com>
 <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com>
 <1311621204.28209.14.camel@lade.trondhjem.org>
 <CA+a=Yy59HXXjd4HgrqeANaQZKO9rRPKzM+r3NNq2KSMV_L4S_w@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A51825D@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A51825D@SACMVEXC2-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Myklebust, Trond wrote:

  > Thanks for your explanation. Is there any plan on how to fix
  > pnfs_ld_read/write_done? Basically, we would need an interface that
  > can redirect the IO to MDS if pnfs_error is set or do all necessary
  > cleanup work to end read/write if pnfs_error is 0. IMHO, the
  > recoalesce logic need to access nfs_pageio_descriptor but we do not
  > have that information at pnfs_ld_read/write_done.
  
  As far as I can see, the right thing to do is to mark the layout as
  invalid and then redirty the page. It should be easy to have fsync()
  re-send the pages in this case. These should be extremely rare events,
  since we expect to catch most of the pNFS failures when we do the actual
  LAYOUTGET in the ->pg_init().
  
  My main worry is for aio/dio where there is no good mechanism for
  retrying. I'm still working on that...

What do you suggest we do for the current set of patches that add block
layout to pnfs?
