From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/17] CLNT: check NFS4ERR_NOT_ONLY_OP for
 CREATE_SESSION
Date: Thu, 3 Mar 2011 00:57:02 -0500
Message-ID: <20110303055702.GC7724@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D6DE2F8.8010309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49719 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960Ab1CCF5D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Mar 2011 00:57:03 -0500
In-Reply-To: <4D6DE2F8.8010309@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 02, 2011 at 02:26:00PM +0800, Mi Jinlong wrote:
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>

Looks fine, thanks.--b.

> ---
>  nfs4.1/server41tests/st_create_session.py |   14 ++++++++++++++
>  1 files changed, 14 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
> index a213a3c..1d02a50 100644
> --- a/nfs4.1/server41tests/st_create_session.py
> +++ b/nfs4.1/server41tests/st_create_session.py
> @@ -382,3 +382,17 @@ def testMaxreqs(t, env):
>      if nfs4lib.test_equal(sess1.fore_channel.maxrequests,
>                            chan_attrs.ca_maxrequests, "count4"):
>          fail("Server allows surprisingly large fore_channel maxreqs")
> +
> +def testNotOnlyOp(t, env):
> +    """Check for NFS4ERR_NOT_ONLY_OP
> +
> +    FLAGS: create_session all
> +    CODE: CSESS23
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    # CREATE_SESSION with PUT_ROOTFH
> +    chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
> +    res = c.c.compound([op.create_session(c.clientid, c.seqid, 0,
> +                                        chan_attrs, chan_attrs,
> +                                        123, []), op.putrootfh()], None)
> +    check(res, NFS4ERR_NOT_ONLY_OP)
> -- 
> 1.7.4.1
> 
> 
> 
