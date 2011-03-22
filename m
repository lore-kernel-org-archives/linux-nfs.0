Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:49974 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755383Ab1CVVsk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Mar 2011 17:48:40 -0400
Date: Tue, 22 Mar 2011 17:48:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/17] CLNT: test resues slot ID
Message-ID: <20110322214839.GA17784@fieldses.org>
References: <4D6DE26C.3010103@cn.fujitsu.com>
 <4D6DE4A5.1050702@cn.fujitsu.com>
 <20110303061442.GE7724@fieldses.org>
 <4D6F5B4E.7000903@cn.fujitsu.com>
 <4D70AB97.3070502@cn.fujitsu.com>
 <20110314184144.GB25442@fieldses.org>
 <20110314192434.GC25442@fieldses.org>
 <4D7ED324.4070600@cn.fujitsu.com>
 <20110317225245.GE31845@fieldses.org>
 <4D886F71.8050001@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D886F71.8050001@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Mar 22, 2011 at 05:44:17PM +0800, Mi Jinlong wrote:
>   I have made a mistake about this case, we don't need the filehandle from GETFHres,
>   that is just unnecessary.
> 
>   Thanks for your point about the homedir, 
>   I found a function named use_obj at nfs4lib which can solve our problem.
> 
>   After fixed, maybe the following patch is OK now.

Great, thanks--applied.

At this point I've applied and pushed out everything I've taken from
you.

So let me know what else you still have that's not in my git repo.  I
know there are the reclaim_complete tests that you're still looking
at, but there might also be a few other odd tests that I still had
questions about?

--b.

> 
> ---
> thanks,
> Mi Jinlong 
> 
> >From e9faf0c2e86421012296f95ce5cd9cd3338f98a2 Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Mon, 22 Mar 2011 19:25:23 +0800
> Subject: [PATCH] CLNT: test resues slot ID
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_sequence.py |   29 +++++++++++++++++++++++++++++
>  1 files changed, 29 insertions(+), 0 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_sequence.py b/nfs4.1/server41tests/st_sequence.py
> index c11fdc9..7277290 100644
> --- a/nfs4.1/server41tests/st_sequence.py
> +++ b/nfs4.1/server41tests/st_sequence.py
> @@ -363,3 +363,32 @@ def testBadSequenceidAtSlot(t, env):
>  
>      res = c.c.compound([op.sequence(sid, nfs4lib.dec_u32(seqid), 2, 3, True)])
>      check(res, NFS4ERR_SEQ_MISORDERED)
> +
> +def testReuseSlotID(t, env):
> +    """ If client reuses a slot ID and sequence ID for a completely
> +        different request, server MAY treat the request as if it is
> +        a retry of what it has already executed. rfc5661 18.46.3
> +
> +    FLAGS: sequence all
> +    CODE: SEQ14
> +    """
> +    c = env.c1.new_client(env.testname(t))
> +    # CREATE_SESSION
> +    sess1 = c.create_session()
> +
> +    name = "%s_1" % env.testname(t)
> +    res = create_file(sess1, name)
> +    check(res)
> +
> +    sid = sess1.sessionid
> +    seqid = nfs4lib.inc_u32(sess1.seqid)
> +    dir = sess1.c.homedir
> +
> +    res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE)] +
> +                        nfs4lib.use_obj(dir) + [op.remove(name)])
> +    check(res)
> +
> +    # Reuses slot ID and sequence ID for different request
> +    res = c.c.compound([op.sequence(sid, seqid, 0, 0, TRUE)] +
> +                        nfs4lib.use_obj(dir) + [op.rename(name, "test")])
> +    check(res)
> -- 
> 1.7.4.1
> 
> 
> 
> 
