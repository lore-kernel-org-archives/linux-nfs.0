Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33784 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751114AbdAMRDg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Jan 2017 12:03:36 -0500
Date: Fri, 13 Jan 2017 12:03:34 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] setattr: test how v4.0 server handles setting of zero
 length principals
Message-ID: <20170113170334.GE24709@fieldses.org>
References: <20170109151556.7522-1-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170109151556.7522-1-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 09, 2017 at 04:15:56PM +0100, Tigran Mkrtchyan wrote:
> my interpretation of rfc3530 expects NFS4ERR_INVAL is owner and
> owner_group are empty strings.

Thanks.  This hangs the Linux server.  Possibly an idmapd bug, but I
think nfsd should be checking for this case before it calls idmapd.

Anyway, that's not your problem.

Any reason you're using NF4SOCK instead of NF4REG?

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.0/servertests/st_setattr.py | 31 +++++++++++++++++++++++++++++++
>  1 file changed, 31 insertions(+)
> 
> diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
> index b6a398b..b192ece 100644
> --- a/nfs4.0/servertests/st_setattr.py
> +++ b/nfs4.0/servertests/st_setattr.py
> @@ -701,3 +701,34 @@ def testChangeGranularity(t, env):
>      chattr4 = res.resarray[7].obj_attributes
>      if chattr1 == chattr2 or chattr2 == chattr3 or chattr3 == chattr4:
>          t.fail("consecutive SETATTR(mode)'s don't all change change attribute")
> +
> +def testEmptyPrincipal(t, env):
> +    """Setting owner with zero length principal must fail
> +
> +    FLAGS: setattr all
> +    DEPEND: MKFILE
> +    CODE: SATT16
> +    """
> +    c = env.c1
> +    path = c.homedir + [t.code]
> +    res = c.create_obj(path, NF4SOCK)
> +    check(res)
> +    ops = c.use_obj(path) + [c.setattr({FATTR4_OWNER: ''})]
> +    res = c.compound(ops)
> +    check(res, NFS4ERR_INVAL, "Setting empty owner")
> +
> +
> +def testEmptyGroupPrincipal(t, env):
> +    """Setting owner group with zero length principal must fail
> +
> +    FLAGS: setattr all
> +    DEPEND: MKFILE
> +    CODE: SATT17
> +    """
> +    c = env.c1
> +    path = c.homedir + [t.code]
> +    res = c.create_obj(path, NF4SOCK)
> +    check(res)
> +    ops = c.use_obj(path) + [c.setattr({FATTR4_OWNER_GROUP: ''})]
> +    res = c.compound(ops)
> +    check(res, NFS4ERR_INVAL, "Setting empty owner_group")
> -- 
> 2.9.3
