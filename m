Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36072 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752766AbdGNBjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Jul 2017 21:39:15 -0400
Date: Thu, 13 Jul 2017 21:39:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Colin King <colin.king@canonical.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S . Miller" <davem@davemloft.net>,
        Sagi Grimberg <sagi@grimberg.me>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH][net-next] svcrdma: fix an incorrect check on -E2BIG and
 -EINVAL
Message-ID: <20170714013914.GA14085@fieldses.org>
References: <20170713175115.9044-1-colin.king@canonical.com>
 <1D2A804A-9BEC-4D34-AF01-960F35E297E7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1D2A804A-9BEC-4D34-AF01-960F35E297E7@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 13, 2017 at 01:53:10PM -0400, Chuck Lever wrote:
> 
> > On Jul 13, 2017, at 1:51 PM, Colin King <colin.king@canonical.com> wrote:
> > 
> > From: Colin Ian King <colin.king@canonical.com>
> > 
> > The current check will always be true and will always jump to
> > err1, this looks dubious to me. I believe && should be used
> > instead of ||.
> > 
> > Detected by CoverityScan, CID#1450120 ("Logically Dead Code")
> > 
> > Fixes: 107c1d0a991a ("svcrdma: Avoid Send Queue overflow")
> > Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> 
> Dan reported this today, and I have a similar patch in my
> "pending for-rc" series. This one works too.

Applied and merged upstream, thanks.

--b.
