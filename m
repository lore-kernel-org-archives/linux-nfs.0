Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52170 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753940AbdKIONa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Nov 2017 09:13:30 -0500
Date: Thu, 9 Nov 2017 09:13:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] 4.1 server tests: make DELEG8 also check that an
 operation using a revoked stateid returns revoked status
Message-ID: <20171109141329.GA8773@fieldses.org>
References: <20171101120855.65421-1-aweits@rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171101120855.65421-1-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Applied, thanks.--b.

On Wed, Nov 01, 2017 at 08:08:55AM -0400, Andrew Elble wrote:
> Signed-off-by: Andrew Elble <aweits@rit.edu>
> ---
>  nfs4.1/server41tests/st_delegation.py | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
> index a5066926a89d..c5959f6cda84 100644
> --- a/nfs4.1/server41tests/st_delegation.py
> +++ b/nfs4.1/server41tests/st_delegation.py
> @@ -186,6 +186,8 @@ def testDelegRevocation(t, env):
>          # depend on the above compound waiting no longer than the
>          # server's lease period:
>          res = sess1.compound([])
> +    res = sess1.compound([op.putfh(fh), op.read(delegstateid, 0, 1000)])
> +    check(res, NFS4ERR_DELEG_REVOKED, "Read with a revoked delegation")
>      slot, seq_op = sess1._prepare_compound({})
>      res = sess1.c.compound([seq_op])
>      flags = res.resarray[0].sr_status_flags;
> -- 
> 2.10.1
