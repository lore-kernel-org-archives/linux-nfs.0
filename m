Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52975 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753968AbaEFUex (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 16:34:53 -0400
Date: Tue, 6 May 2014 16:34:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS4.0: Case for linking to bad source patch with
 zero-length
Message-ID: <20140506203453.GP18281@fieldses.org>
References: <5358EE2F.9070301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5358EE2F.9070301@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 24, 2014 at 06:57:51PM +0800, Kinglong Mee wrote:
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  nfs4.0/servertests/st_create.py | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/nfs4.0/servertests/st_create.py b/nfs4.0/servertests/st_create.py
> index d2d6701..09c80cc 100644
> --- a/nfs4.0/servertests/st_create.py
> +++ b/nfs4.0/servertests/st_create.py
> @@ -161,6 +161,19 @@ def testZeroLength(t, env):
>      res = c.create_obj(c.homedir + [''])
>      check(res, NFS4ERR_INVAL, "CREATE with zero-length name")
>  
> +def testZeroLengthForLNK(t, env):
> +    """CREATE with zero length name should return NFS4ERR_INVAL

Is it actually true that attempts to create symlinks with zero-length
content should fail with NFS4ERR_INVAL, and if so according to who?  (Is
there language in the RFC's?)

--b.

> +
> +    FLAGS: create symlink all
> +    CODE: CR9a
> +    """
> +    c = env.c1
> +    ops = c.go_home()
> +    objtype = createtype4(NF4LNK, **{'linkdata':''})
> +    ops += [c.create_op(objtype, t.code, getDefaultAttr(c))]
> +    res = c.compound(ops)
> +    check(res, NFS4ERR_INVAL, "CREATE with zero-length name for SYMLINK")
> +
>  def testRegularFile(t, env):
>      """CREATE should fail with NFS4ERR_BADTYPE for regular files
>  
> -- 
> 1.9.0
> 
