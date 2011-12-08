Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34076 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752103Ab1LHVbx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 16:31:53 -0500
Date: Thu, 8 Dec 2011 16:31:52 -0500
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] create open requests without executing
Message-ID: <20111208213152.GH32505@fieldses.org>
References: <1323363112-13256-1-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323363112-13256-1-git-send-email-tigran.mkrtchyan@desy.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 08, 2011 at 05:51:51PM +0100, Tigran Mkrtchyan wrote:
> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.1/server41tests/environment.py |   13 ++++++++++++-
>  1 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
> index 6e68e83..6f3bd0a 100644
> --- a/nfs4.1/server41tests/environment.py
> +++ b/nfs4.1/server41tests/environment.py
> @@ -453,6 +453,17 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>  		     deleg_type=None,
>  		     open_create=OPEN4_NOCREATE,
>  		     seqid=0, clientid=0):
> +    return sess.compound(open_create_file_op())

I get:

	...
	File "/root/pynfs/nfs4.1/server41tests/environment.py", line 456, in open_create_file
        return sess.compound(open_create_file_op())
    TypeError: open_create_file_op() takes at least 2 arguments (0 given)

Also, the following patch has some minor conflicts with Mi Jinlong's
recent patch.  I don't mind fixing that up myself, but if you're
regenerating these patches anyway, maybe you could?

Thanks.

--b.

> +
> +def open_create_file_op(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
> +                     access=OPEN4_SHARE_ACCESS_BOTH,
> +                     deny=OPEN4_SHARE_DENY_NONE,
> +		     mode=GUARDED4, verifier=None,
> +		     claim_type=CLAIM_NULL,
> +		     want_deleg=False,
> +		     deleg_type=None,
> +		     open_create=OPEN4_NOCREATE,
> +		     seqid=0, clientid=0):
>      # Set defaults
>      if path is None:
>          dir = sess.c.homedir
> @@ -485,7 +496,7 @@ def open_create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>      open_op = op.open(seqid, access, deny, open_owner4(clientid, owner),
>                        openflag, openclaim)
>  
> -    return sess.compound(fh_op + [open_op, op.getfh()])
> +    return fh_op + [open_op, op.getfh()]
>  
>  def create_file(sess, owner, path=None, attrs={FATTR4_MODE: 0644},
>                  access=OPEN4_SHARE_ACCESS_BOTH,
> -- 
> 1.7.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
