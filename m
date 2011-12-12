Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46158 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753468Ab1LLWjP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 17:39:15 -0500
Date: Mon, 12 Dec 2011 17:39:14 -0500
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] client: test LOCK and LOCKU in a single compound
Message-ID: <20111212223914.GA22927@fieldses.org>
References: <1323445215-3654-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323445215-3654-1-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 09, 2011 at 04:40:15PM +0100, Tigran Mkrtchyan wrote:
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

This should probably be in an st_lock.py.

But, OK, for now; applied.

--b.

> ---
>  nfs4.1/server41tests/st_open.py |   24 +++++++++++++++++++++++-
>  1 files changed, 23 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> index 89f3e2d..1c965b2 100644
> --- a/nfs4.1/server41tests/st_open.py
> +++ b/nfs4.1/server41tests/st_open.py
> @@ -4,7 +4,8 @@ from nfs4_const import *
>  from environment import check, checklist, fail, create_file, open_file, close_file
>  from environment import open_create_file_op
>  from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
> -from nfs4_type import creatverfattr, fattr4, stateid4
> +from nfs4_type import creatverfattr, fattr4, stateid4, locker4, lock_owner4
> +from nfs4_type import open_to_lock_owner4
>  import nfs4_ops as op
>  import threading
>  
> @@ -253,3 +254,24 @@ def testOpenAndClose(t, env):
>      res = sess1.compound(open_op + [op.close(0, current_stateid)])
>      check(res, NFS4_OK)
>  
> +def testLockLockU(t, env):
> +    """test current state id processing by having LOCK and LOCKU
> +       in a single compound
> +
> +    FLAGS: open all
> +    CODE: OPEN32
> +    """
> +    current_stateid = stateid4(1, '\0' * 12)
> +    sess1 = env.c1.new_client_session(env.testname(t))
> +
> +    res = create_file(sess1, env.testname(t))
> +    check(res)
> +    fh = res.resarray[-1].object
> +    stateid = res.resarray[-2].stateid
> +
> +    open_to_lock_owner = open_to_lock_owner4( 0, stateid, 0, lock_owner4(0, "lock1"))
> +    lock_owner = locker4(open_owner=open_to_lock_owner, new_lock_owner=True)
> +    lock_ops = [ op.lock(WRITE_LT, False, 0, NFS4_UINT64_MAX, lock_owner),
> +	op.locku(WRITE_LT, 0, current_stateid, 0, NFS4_UINT64_MAX) ]
> +    res = sess1.compound([op.putfh(fh)] + lock_ops)
> +    check(res, NFS4_OK)
> -- 
> 1.7.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
