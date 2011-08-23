Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33957 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751886Ab1HWVvl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Aug 2011 17:51:41 -0400
Date: Tue, 23 Aug 2011 17:51:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4 v3] 4.1 CLNT: test open before RECLAIM_COMPLETE
Message-ID: <20110823215140.GF25350@fieldses.org>
References: <4E4C7679.7000108@cn.fujitsu.com>
 <4E4C771B.2030405@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4C771B.2030405@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 18, 2011 at 10:21:15AM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

Same nits as previous ones (comments mostly repeat what the code says,
space needed after comma between function arguments).

Looks reasonable otherwise.

--b.

> ---
>  nfs4.1/server41tests/st_reclaim_complete.py |   21 ++++++++++++++++++++-
>  1 files changed, 20 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index 3940b7b..921d537 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from nfs4_const import *
> -from environment import check, fail, open_file, create_confirm
> +from environment import check, fail, open_file, create_file, create_confirm
>  import nfs4_ops as op
>  import nfs4lib
>  
> @@ -47,3 +47,22 @@ def testReclaimAfterRECC(t, env):
>                      deleg_type=OPEN_DELEGATE_NONE)
>  
>      check(res,NFS4ERR_NO_GRACE)
> +
> +def testOpenBeforeRECC(t, env):
> +    """After a client establishes a new client ID, if non-reclaim
> +       locking operations are done before the RECLAIM_COMPLETE,
> +       error NFS4ERR_GRACE will be returned. rfc5661 18.51.3
> +
> +    FLAGS: reclaim_complete all
> +    CODE: RECC3
> +    """
> +    name = env.testname(t)
> +    c = env.c1.new_client(name)
> +    sess = c.create_session()
> +
> +    fname = "owner_%s" % name
> +    path = sess.c.homedir + [name]
> +
> +    # Try to open file before RECLAIM_COMPLETE
> +    res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
> +    check(res,NFS4ERR_GRACE)
> -- 
> 1.7.6
> 
> 
