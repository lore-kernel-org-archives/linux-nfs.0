Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50182 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752504AbeDJTtX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Apr 2018 15:49:23 -0400
Date: Tue, 10 Apr 2018 15:49:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Haynes <Thomas.Haynes@primarydata.com>
Cc: Mailing List Linux NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Args need to be the same for replay cache
Message-ID: <20180410194922.GD5652@fieldses.org>
References: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1507740502-5151-1-git-send-email-Thomas.Haynes@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This prompted a long discussion on the correct server behavior in the
case of false retries of bare SEQUENCE calls, which was kind of
irrelevant to your actual pynfs patch.  Somebody just reminded me that I
never applied that.

Applied now, thanks.--b.

On Wed, Oct 11, 2017 at 09:48:22AM -0700, Thomas Haynes wrote:
> From: Tom Haynes <loghyr@primarydata.com>
> 
> 2.10.6.1.3.1.  False Retry
> 
>   If a requester sent a Sequence operation with a slot ID and sequence
>   ID that are in the reply cache but the replier detected that the
>   retried request is not the same as the original request, including a
>   retry that has different operations or different arguments in the
>   operations from the original and a retry that uses a different
>    principal in the RPC request's credential field that translates to a
>   different user, then this is a false retry.  When the replier detects
>   a false retry, it is permitted (but not always obligated) to return
>   NFS4ERR_SEQ_FALSE_RETRY in response to the Sequence operation when it
>   detects a false retry.
> 
> Or in other words, sa_cachethis needs to be set or a
> server can respond with an error.
> 
> Signed-off-by: Tom Haynes <loghyr@primarydata.com>
> ---
>  nfs4.1/server41tests/st_sequence.py | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
> index d8d460c..e1e5f06 100644
> --- a/nfs4.1/server41tests/st_sequence.py
> +++ b/nfs4.1/server41tests/st_sequence.py
> @@ -115,7 +115,7 @@ def testReplayCache001(t, env):
>      sess1 = c1.create_session()
>      res1 = sess1.compound([op.putrootfh()], cache_this=True)
>      check(res1)
> -    res2 = sess1.compound([op.putrootfh()], seq_delta=0)
> +    res2 = sess1.compound([op.putrootfh()], cache_this=True, seq_delta=0)
>      check(res2)
>      res1.tag = res2.tag = ""
>      if not nfs4lib.test_equal(res1, res2):
> @@ -137,7 +137,7 @@ def testReplayCache002(t, env):
>            op.rename("%s_1" % env.testname(t), "%s_2" % env.testname(t))]
>      res1 = sess1.compound(ops, cache_this=True)
>      check(res1)
> -    res2 = sess1.compound(ops, seq_delta=0)
> +    res2 = sess1.compound(ops, cache_this=True, seq_delta=0)
>      check(res2)
>      res1.tag = res2.tag = ""
>      if not nfs4lib.test_equal(res1, res2):
> @@ -158,7 +158,7 @@ def testReplayCache003(t, env):
>      sess1 = c1.create_session()
>      res1 = sess1.compound([op.putrootfh(), op.lookup("")], cache_this=True)
>      check(res1, NFS4ERR_INVAL)
> -    res2 = sess1.compound([op.putrootfh(), op.lookup("")], seq_delta=0)
> +    res2 = sess1.compound([op.putrootfh(), op.lookup("")], cache_this=True, seq_delta=0)
>      check(res2, NFS4ERR_INVAL)
>      res1.tag = res2.tag = ""
>      if not nfs4lib.test_equal(res1, res2):
> @@ -176,7 +176,7 @@ def testReplayCache004(t, env):
>      ops += [op.savefh(), op.rename("", "foo")]
>      res1 = sess1.compound(ops, cache_this=True)
>      check(res1, NFS4ERR_INVAL)
> -    res2 = sess1.compound(ops, seq_delta=0)
> +    res2 = sess1.compound(ops, cache_this=True, seq_delta=0)
>      check(res2, NFS4ERR_INVAL)
>      res1.tag = res2.tag = ""
>      if not nfs4lib.test_equal(res1, res2):
> @@ -192,7 +192,7 @@ def testReplayCache005(t, env):
>      sess1 = c1.create_session()
>      res1 = sess1.compound([op.illegal()], cache_this=True)
>      check(res1, NFS4ERR_OP_ILLEGAL)
> -    res2 = sess1.compound([op.illegal()], seq_delta=0)
> +    res2 = sess1.compound([op.illegal()], cache_this=True, seq_delta=0)
>      check(res2, NFS4ERR_OP_ILLEGAL)
>      res1.tag = res2.tag = ""
>      if not nfs4lib.test_equal(res1, res2):
> @@ -208,7 +208,7 @@ def testReplayCache006(t, env):
>      sess = c.create_session()
>      res1 = sess.compound([])
>      check(res1)
> -    res2 = sess.compound([], seq_delta=0)
> +    res2 = sess.compound([], cache_this=True, seq_delta=0)
>      check(res2)
>      res1.tag = res2.tag = ""
>      if not nfs4lib.test_equal(res1, res2):
> -- 
> 2.3.6
