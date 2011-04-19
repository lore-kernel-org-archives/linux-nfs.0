Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54305 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751567Ab1DSWtu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Apr 2011 18:49:50 -0400
Date: Tue, 19 Apr 2011 18:49:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 3/5] CLNT: test reclaim after RECLAIM_COMPLETE
Message-ID: <20110419224948.GA10478@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D904BEB.1060101@cn.fujitsu.com>
 <4D904DF9.1080806@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D904DF9.1080806@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Mar 28, 2011 at 04:59:37PM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

Looks fine but note you shouldn't need to go to the trouble of doing a
lock if you want to test reclaims--opens can also be reclaimed.

--b.

> ---
>  nfs4.1/server41tests/st_reclaim_complete.py |   50 +++++++++++++++++++++++++++
>  1 files changed, 50 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_reclaim_complete.py b/nfs4.1/server41tests/st_reclaim_complete.py
> index 5e3174c..4c9fc37 100644
> --- a/nfs4.1/server41tests/st_reclaim_complete.py
> +++ b/nfs4.1/server41tests/st_reclaim_complete.py
> @@ -1,9 +1,18 @@
>  from st_create_session import create_session
>  from nfs4_const import *
>  from environment import check, fail, use_obj, create_file
> +from nfs4_type import open_owner4, locker4, open_to_lock_owner4
>  import nfs4_ops as op
>  import nfs4lib
>  
> +def opt_result(res, opt=None):
> +    """Get the corresponding result at res.resarray[]"""
> +    if opt == None:
> +        return
> +    for resa in res.resarray:
> +        if resa.resop == opt:
> +            return resa
> +
>  def testSupported(t, env):
>      """Do a simple RECLAIM_COMPLETE
>  
> @@ -20,3 +29,44 @@ def testSupported(t, env):
>      res = sess.compound([op.reclaim_complete(FALSE)])
>      check(res)
>      sess.destroy()
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
> +    res = sess.compound([op.reclaim_complete(FALSE)])
> +    check(res)
> +
> +    fname = "owner_%s" % name
> +    path = sess.c.homedir + [name]
> +    res = create_file(sess, fname, path, access=OPEN4_SHARE_ACCESS_BOTH)
> +    check(res)
> +
> +    # Get stateid from OPEN4resok for making a lockowner
> +    nres = opt_result(res, OP_OPEN)
> +    if nres == None:
> +        fail("Can not get OPEN4resok!")
> +    oseqid = nres.stateid
> +
> +    owner = open_owner4(0, "My Open Owner")
> +    otlowner = open_to_lock_owner4(0, oseqid, 0, owner)
> +    lowner = locker4(TRUE, otlowner)
> +
> +    # Get filehandle from GETFHresok for locking
> +    nres = opt_result(res, OP_GETFH)
> +    if nres == None:
> +	fail("Can not get GETFHresok!")
> +    cfh = nres.object
> +
> +    res = sess.compound([op.putfh(cfh), op.lock(READ_LT, TRUE, 0, 1, lowner)])
> +    check(res, NFS4ERR_NO_GRACE)
> +    sess.destroy()
> -- 
> 1.7.4.1
> 
> 
> 
