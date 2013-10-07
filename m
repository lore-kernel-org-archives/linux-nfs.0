Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59261 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755275Ab3JGPh5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Oct 2013 11:37:57 -0400
Date: Mon, 7 Oct 2013 11:37:55 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] st_destroy_session: remove invalid testcase
Message-ID: <20131007153755.GG18051@fieldses.org>
References: <1380918492-8413-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380918492-8413-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 04, 2013 at 10:28:12PM +0200, Tigran Mkrtchyan wrote:
> we cant expect NFS4ERR_NOT_ONLY_OP if spec
> enforces NFS4ERR_OP_NOT_IN_SESSION

I guess we could just add that to the list of allowable error returns,
but... yeah, OK, let's just remove that test.  Applied.

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/st_destroy_session.py | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_destroy_session.py b/nfs4.1/server41tests/st_destroy_session.py
> index 1feb671..f4f0762 100644
> --- a/nfs4.1/server41tests/st_destroy_session.py
> +++ b/nfs4.1/server41tests/st_destroy_session.py
> @@ -164,6 +164,3 @@ def testDestoryNotSoleOps(t, env):
>      sid = sess1.sessionid
>      res = c.c.compound([op.destroy_session(sess1.sessionid), op.putrootfh()])
>      check(res, NFS4ERR_NOT_ONLY_OP)
> -
> -    res = c.c.compound([op.putrootfh(), op.destroy_session(sess1.sessionid)])
> -    check(res, NFS4ERR_NOT_ONLY_OP)
> -- 
> 1.8.3.1
> 
