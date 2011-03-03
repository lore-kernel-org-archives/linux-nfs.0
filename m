Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46422 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695Ab1CCGOn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 01:14:43 -0500
Date: Thu, 3 Mar 2011 01:14:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/17] CLNT: test resues slot ID
Message-ID: <20110303061442.GE7724@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D6DE4A5.1050702@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D6DE4A5.1050702@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Mar 02, 2011 at 02:33:09PM +0800, Mi Jinlong wrote:
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_sequence.py |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
> index 4ea5cab..391fc45 100644
> --- a/nfs4.1/server41tests/st_sequence.py
> +++ b/nfs4.1/server41tests/st_sequence.py
> @@ -363,3 +363,21 @@ def testBadSequenceidAtSlot(t, env):
>  
>      res = c.c.compound([op.sequence(sid, nfs4lib.dec_u32(seqid), 2, 3, True)])
>      check(res, NFS4ERR_SEQ_MISORDERED)
> +
> +def testReuseSlotID(t, env):
> +    """
> +
> +    FLAGS: sequence all
> +    CODE: SEQ14
> +    """

Missing description?

> +    c = env.c1.new_client(env.testname(t))
> +    # CREATE_SESSION
> +    sess1 = c.create_session()
> +
> +    sid = sess1.sessionid 
> +    res = c.c.compound([op.sequence(sid, 1, 2, 3, True), op.putrootfh()])
> +    check(res)
> +
> +    res = c.c.compound([op.sequence(sid, 1, 2, 3, True)])
> +    # should we also check the ERROR of NFS4ERR_SEQ_FALSE_RETRY ??

As I understand it, the server isn't required to recognize false
retries, so I don't think we can check for that.

The only useful thing to check for, I think, is just to send the same
request twice and make sure the requests match.

Actually, best would be to do this with a non-idempotent operation.  For
example, send SEQ+RENAME twice and make sure that both renames succeed.
(Whereas if the server reply cache is broken and the server attempts to
rename the file again, the second rename will fail with NOENT.)

--b.

> +    check(res)
> -- 
> 1.7.4.1
> 
> 
> 
