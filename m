Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33959 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886Ab1HWVwF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Aug 2011 17:52:05 -0400
Date: Tue, 23 Aug 2011 17:52:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4 v3] 4.1 CLNT: test RECLAIM_COMPLETE twice
Message-ID: <20110823215205.GG25350@fieldses.org>
References: <4E4C7679.7000108@cn.fujitsu.com>
 <4E4C774D.1040302@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4C774D.1040302@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 18, 2011 at 10:22:05AM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_reclaim_complete.py |   19 +++++++++++++++++++
>  1 files changed, 19 insertions(+), 0 deletions(-)

Looks OK.

--b.

> 
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index 921d537..7c9f2b8 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -66,3 +66,22 @@ def testOpenBeforeRECC(t, env):
>      # Try to open file before RECLAIM_COMPLETE
>      res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
>      check(res,NFS4ERR_GRACE)
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
> +    # RECLAIM_COMPLETE
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
