Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47624 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751151AbdAWQwj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 23 Jan 2017 11:52:39 -0500
Date: Mon, 23 Jan 2017 11:52:38 -0500
To: Christoph Hellwig <hch@lst.de>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [pynfs PATCH] check that a mixed size / uid setattr works
Message-ID: <20170123165238.GC9493@fieldses.org>
References: <1485103878-15160-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1485103878-15160-1-git-send-email-hch@lst.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 22, 2017 at 05:51:18PM +0100, Christoph Hellwig wrote:
> On some Linux file systems this currently fails and/or trips an ASSERT.

Thanks, applied.--b.

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  nfs4.0/servertests/st_setattr.py | 29 +++++++++++++++++++++++++++++
>  1 file changed, 29 insertions(+)
> 
> diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
> index b6a398b..accd807 100644
> --- a/nfs4.0/servertests/st_setattr.py
> +++ b/nfs4.0/servertests/st_setattr.py
> @@ -27,6 +27,23 @@ def _set_size(t, c, file, stateid=None, msg=" using stateid=0"):
>      check(res, msg="Changing size from %i to 0" % newsize)
>      check_res(t, c, res, file, dict)
>  
> +#
> +# Mix size and non-size attributes in a single SETATTR.  Some Linux file
> +# systems aren't happy with this mix, and a server passing this on 1:1
> +# will trigger warnings or incorrect results.
> +#
> +def _set_mixed(t, c, file, stateid=None, msg=" using stateid=0"):
> +    startsize = c.do_getattr(FATTR4_SIZE, file)
> +    newsize = startsize + 10
> +    owner = "65534" # nobody
> +
> +    dict = {FATTR4_SIZE: newsize, FATTR4_OWNER: owner}
> +    ops = c.use_obj(file) + [c.setattr(dict, stateid)]
> +    res = c.compound(ops)
> +    check(res, msg="Changing size from %i to %i and owner to %s%s" %
> +          (startsize, newsize, owner, msg), warnlist=[NFS4ERR_BAD_STATEID])
> +    check_res(t, c, res, file, dict)
> +
>  def _try_readonly(t, env, path):
>      c = env.c1
>      baseops = c.use_obj(path)
> @@ -701,3 +718,15 @@ def testChangeGranularity(t, env):
>      chattr4 = res.resarray[7].obj_attributes
>      if chattr1 == chattr2 or chattr2 == chattr3 or chattr3 == chattr4:
>          t.fail("consecutive SETATTR(mode)'s don't all change change attribute")
> +
> +def testMixed(t, env):
> +    """SETATTR(FATTR4_SIZE + FATTR4_OWNER) on file with stateid = 0
> +
> +    FLAGS: setattr file all
> +    DEPEND: MKFILE
> +    CODE: SATT16
> +    """
> +    c = env.c1
> +    c.init_connection()
> +    fh, stateid = c.create_confirm(t.code, deny=OPEN4_SHARE_DENY_NONE)
> +    _set_mixed(t, c, fh)
> -- 
> 2.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
