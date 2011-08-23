Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33955 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753418Ab1HWVul (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Aug 2011 17:50:41 -0400
Date: Tue, 23 Aug 2011 17:50:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/4 v3] 4.1 CLNT: test reclaims after RECLAIM_COMPLETE
Message-ID: <20110823215040.GE25350@fieldses.org>
References: <4E4C7679.7000108@cn.fujitsu.com>
 <4E4C76F8.7060203@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E4C76F8.7060203@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Aug 18, 2011 at 10:20:40AM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_reclaim_complete.py |   30 ++++++++++++++++++++++++++-
>  1 files changed, 29 insertions(+), 1 deletions(-)

Just nits:

> 
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index a591ef5..3940b7b 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from nfs4_const import *
> -from environment import check, fail
> +from environment import check, fail, open_file, create_confirm
>  import nfs4_ops as op
>  import nfs4lib
>  
> @@ -19,3 +19,31 @@ def testSupported(t, env):
>  
>      res = sess.compound([op.reclaim_complete(FALSE)])
>      check(res)
> +
> +def testReclaimAfterRECC(t, env):
> +    """If client does subsequent reclaims of locking state after
> +       RECLAIM_COMPLETE is done, server will return NFS4ERR_NO_GRACE.
> +       rfc5661 18.51.3
> +
> +    FLAGS: reclaim_complete all
> +    CODE: RECC2
> +    """
> +    name = env.testname(t)
> +    c = env.c1.new_client(name)
> +    sess = c.create_session()
> +
> +    # RECLAIM_COMPLETE

This comment doesn't explain anything not already obvious from the code.

> +    res = sess.compound([op.reclaim_complete(FALSE)])
> +    check(res)
> +
> +    owner = "owner_%s" % name
> +    path = sess.c.homedir + [name]
> +    fh, stateid = create_confirm(sess, owner)
> +
> +    # Try to reclaims after RECLAIM_COMPLETE

Ditto.

> +    res = open_file(sess, owner, path=fh, claim_type=CLAIM_PREVIOUS,
> +                    access=OPEN4_SHARE_ACCESS_BOTH,
> +                    deny=OPEN4_SHARE_DENY_NONE,
> +                    deleg_type=OPEN_DELEGATE_NONE)
> +
> +    check(res,NFS4ERR_NO_GRACE)

Make the "," a ", ".

Also: in this case:

	- the file we're trying to open doesn't exist
	- the client we just created probably isn't allowed to reclaim

So NFS4ERR_EXIST and NFS4ERR_RECLAIM_BAD are probably both legal error
returns as well.  I don't think the spec mandates that these be checked
in any particular order.

--b.

> -- 
> 1.7.6
> 
> 
