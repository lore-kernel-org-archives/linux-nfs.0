Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41243 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751194Ab1HZWlv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 18:41:51 -0400
Date: Fri, 26 Aug 2011 18:41:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4 v4] 4.1 CLNT: test RECLAIM_COMPLETE twice
Message-ID: <20110826224149.GA18699@fieldses.org>
References: <4E4C7679.7000108@cn.fujitsu.com>
 <4E54BC35.3060001@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E54BC35.3060001@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks, these four look OK; I'll run a quick test and then push them out
to my repository.

--b.

On Wed, Aug 24, 2011 at 04:54:13PM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_reclaim_complete.py |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index adb368d..f6baf09 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -63,3 +63,21 @@ def testOpenBeforeRECC(t, env):
>  
>      res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
>      check(res, NFS4ERR_GRACE)
> +
> +def testDoubleRECC(t, env):
> +    """If RECLAIM_COMPLETE is done a second time, error
> +       NFS4ERR_COMPLETE_ALREADY will be returned. rfc5661 18.51.4
> +
> +    FLAGS: reclaim_complete all
> +    CODE: RECC4
> +    """
> +    name = env.testname(t)
> +    c = env.c1.new_client(name)
> +    sess = c.create_session()
> +
> +    res = sess.compound([op.reclaim_complete(FALSE)])
> +    check(res)
> +
> +    # RECLAIM_COMPLETE again
> +    res = sess.compound([op.reclaim_complete(FALSE)])
> +    check(res, NFS4ERR_COMPLETE_ALREADY)
> -- 
> 1.7.6
> 
> 
