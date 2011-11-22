Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60940 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab1KVW0e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Nov 2011 17:26:34 -0500
Date: Tue, 22 Nov 2011 17:26:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] 4.1 CLNT: Test Case for OPEN file with claim_type is
 CLAIM_FH
Message-ID: <20111122222632.GA23818@fieldses.org>
References: <4EC46E76.5040907@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EC46E76.5040907@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 17, 2011 at 10:16:22AM +0800, Mi Jinlong wrote:
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_open.py |   38 +++++++++++++++++++++++++++++++++++++-
>  1 files changed, 37 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_open.py b/nfs4.1/server41tests/st_open.py
> index bd995a5..87b58b3 100644
> --- a/nfs4.1/server41tests/st_open.py
> +++ b/nfs4.1/server41tests/st_open.py
> @@ -1,6 +1,6 @@
>  from st_create_session import create_session
>  from nfs4_const import *
> -from environment import check, checklist, fail, create_file, open_file
> +from environment import check, checklist, fail, create_file, open_file, close_file
>  from nfs4_type import open_owner4, openflag4, createhow4, open_claim4
>  from nfs4_type import creatverfattr, fattr4
>  import nfs4_ops as op
> @@ -200,3 +200,39 @@ def testEXCLUSIVE4AtNameAttribute(t, env):
>      res = create_file(sess1, env.testname(t), mode=EXCLUSIVE4_1,
>                          verifier = "Justtest")
>      check(res, NFS4ERR_EXIST)
> +
> +def testOPENClaimFH(t, env):
> +    """OPEN file with claim_type is CLAIM_FH
> +
> +    FLAGS: open all
> +    CODE: OPEN7
> +    """
> +    sess1 = env.c1.new_client_session(env.testname(t))
> +    res = create_file(sess1, env.testname(t))
> +    check(res)
> +
> +    fh = res.resarray[-1].object
> +    stateid = res.resarray[-2].stateid
> +    res = close_file(sess1, fh, stateid=stateid)
> +    check(res)
> +
> +    claim = open_claim4(CLAIM_FH)
> +    how = openflag4(OPEN4_NOCREATE)
> +    oowner = open_owner4(0, "My Open Owner 2")
> +    open_op = op.open(0, OPEN4_SHARE_ACCESS_BOTH, OPEN4_SHARE_DENY_NONE,
> +                      oowner, how, claim)
> +    res = sess1.compound([op.putfh(fh), open_op])
> +    check(res)

You could just stop here.  But I suppose I don't see a problem with
doing some IO to the file too just to make sure the open is usable.

> +
> +    stateid = res.resarray[-1].stateid
> +    stateid.seqid = 0

Why are you modifying the seqid?

> +    data = "write test data"
> +    res = sess1.compound([op.putfh(fh), op.write(stateid, 5, FILE_SYNC4, data)])
> +    check(res)
> +    res = sess1.compound([op.putfh(fh), op.read(stateid, 0, 1000)])
> +    check(res)
> +    if not res.resarray[-1].eof:
> +        fail("EOF not set on read")
> +    desired = "\0"*5 + data

Why the five nulls?  I don't understand this code....

--b.

> +    if res.resarray[-1].data != desired:
> +        fail("Expected %r, got %r" % (desired, res.resarray[-1].data))
> -- 
> 1.7.7
> 
> 
