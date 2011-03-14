Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59233 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753177Ab1CNT1d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Mar 2011 15:27:33 -0400
Date: Mon, 14 Mar 2011 15:27:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 15/17] CLNT: test lock before RECLAIM_COMPLETE
Message-ID: <20110314192733.GD25442@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D6DE55F.6040205@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D6DE55F.6040205@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 02, 2011 at 02:36:15PM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

I'm getting failures I don't understand on these reclaim complete tests
too.

--b.

> ---
>  nfs4.1/server41tests/st_reclaim_complete.py |   26 ++++++++++++++++++++++++++
>  1 files changed, 26 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index 45ac9ad..a94f2ad 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -50,3 +50,29 @@ def testReclaimAfterRECC(t, env):
>  
>      res = sess.compound([op.putfh(cfh), op.lock(READ_LT, TRUE, 0, 1, lowner)])
>      check(res, NFS4ERR_NO_GRACE)
> +
> +def testLockBeforeRECC(t, env):
> +    """After a client establishes a new client ID, if non-reclaim
> +       locking operations are done before the RECLAIM_COMPLETE,
> +       error NFS4ERR_GRACE will be returned. rfc5661 18.51.3
> +
> +    FLAGS: all
> +    CODE: RECC3
> +    """
> +    name = env.testname(t)
> +    c = env.c1.new_client(name)
> +    sess = c.create_session()
> +
> +    fname = "owner_%s" % name
> +    path = sess.c.homedir + [name]
> +    res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
> +    check(res)
> +
> +    oseqid = res.resarray[2].stateid
> +    cfh = res.resarray[3].object
> +    owner = open_owner4(0, "My Open Owner")
> +    otlowner = open_to_lock_owner4(0, oseqid, 0, owner)
> +    lowner = locker4(TRUE, otlowner)
> +
> +    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, FALSE, 0, 1, lowner)])
> +    check(res, NFS4ERR_NO_GRACE)
> -- 
> 1.7.4.1
> 
> 
> 
