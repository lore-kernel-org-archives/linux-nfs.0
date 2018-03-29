Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33304 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750735AbeC2QqX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Mar 2018 12:46:23 -0400
Date: Thu, 29 Mar 2018 12:46:23 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: linux-nfs@vger.kernel.org, "'J. Bruce Fields'" <bfields@redhat.com>
Subject: Re: [pynfs] [PATCH 3/3] Fix DELEG21 to have CODE:
Message-ID: <20180329164623.GB17806@fieldses.org>
References: <00e801d3c6e9$8ab47c00$a01d7400$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00e801d3c6e9$8ab47c00$a01d7400$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Uh, I think I didn't actually mean to commit that test at all.  Oh well,
I'll take this and then go see if I can find what else I had to patch to
make it work.

I realized after writing this that the existing tests all *require* that
clients' operations conflict with their own delegations.  So at some
point those tests need fixing too, but for now they're useful tests of
my patches--when they start failing I know I've got something right.

--b.

On Wed, Mar 28, 2018 at 04:07:27PM -0700, Frank Filz wrote:
> Signed-off-by: Frank S. Filz <ffilzlnx@mindspring.com>
> 
> ---
> 
> nfs4.0/servertests/st_delegation.py | 2 +-
> 
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
>  
> 
> diff --git a/nfs4.0/servertests/st_delegation.py
> b/nfs4.0/servertests/st_delegation.py
> 
> index e204e50..1d69fb5 100644
> 
> --- a/nfs4.0/servertests/st_delegation.py
> 
> +++ b/nfs4.0/servertests/st_delegation.py
> 
> @@ -714,7 +714,7 @@ def testServerSelfConflict(t, env):
> 
>      It should not conflict with the read delegation.
> 
>      FLAGS: delegations
> 
> -    DELEG21
> 
> +    CODE: DELEG21
> 
>      """
> 
>      c = env.c1
> 
>      count = c.cb_server.opcounts[OP_CB_RECALL]
> 
> -- 
> 
> 2.5.5
> 
>  
> 
>  
> 
>  
> 
