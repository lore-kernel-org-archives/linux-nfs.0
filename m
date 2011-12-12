Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49070 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346Ab1LLTwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Dec 2011 14:52:10 -0500
Date: Mon, 12 Dec 2011 14:52:07 -0500
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 2/2] client: add open+close test with current stateid
Message-ID: <20111212195207.GB20826@fieldses.org>
References: <1323435533-32571-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1323435533-32571-2-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323435533-32571-2-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 09, 2011 at 01:58:53PM +0100, Tigran Mkrtchyan wrote:
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

Both applied, thanks.

--b.

> ---
>  nfs4.1/server41tests/st_open.py |   19 ++++++++++++++++++-
>  1 files changed, 18 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> index 87b58b3..89f3e2d 100644
> --- a/nfs4.1/server41tests/st_open.py
> +++ b/nfs4.1/server41tests/st_open.py
> @@ -1,8 +1,10 @@
>  from st_create_session import create_session
>  from nfs4_const import *
> +
>  from environment import check, checklist, fail, create_file, open_file, close_file
> +from environment import open_create_file_op
>  from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
> -from nfs4_type import creatverfattr, fattr4
> +from nfs4_type import creatverfattr, fattr4, stateid4
>  import nfs4_ops as op
>  import threading
>  
> @@ -236,3 +238,18 @@ def testOPENClaimFH(t, env):
>      desired = "\0"*5 + data
>      if res.resarray[-1].data != desired:
>          fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
> +
> +def testOpenAndClose(t, env):
> +    """test current state id processing by having OPEN and CLOSE
> +       in a single compound
> +
> +    FLAGS: open all
> +    CODE: OPEN31
> +    """
> +    current_stateid = stateid4(1, '\0' * 12)
> +    sess1 = env.c1.new_client_session(env.testname(t))
> +
> +    open_op = open_create_file_op(sess1, env.testname(t), open_create=OPEN4_CREATE)
> +    res = sess1.compound(open_op + [op.close(0, current_stateid)])
> +    check(res, NFS4_OK)
> +
> -- 
> 1.7.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
