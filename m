Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55500 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753664AbcFMTVn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 15:21:43 -0400
Date: Mon, 13 Jun 2016 15:21:41 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] handle NFS4ERR_BAD_STATEID on setattr
Message-ID: <20160613192141.GB19825@fieldses.org>
References: <1463671971-5085-1-git-send-email-tigran.mkrtchyan@desy.de>
 <1463671971-5085-2-git-send-email-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1463671971-5085-2-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 19, 2016 at 05:32:51PM +0200, Tigran Mkrtchyan wrote:
> the st_setattr test expect that setting a size for not file objects
> will return NFS4ERR_INVAL, nevertheless, as setting a size requires
> a valid open/lock state id, server may check that first and return
> NFS4ERR_BAD_STATEID, which is not handled by the test case.
> 
> this change adds NFS4ERR_BAD_STATEID into the list of expected
> errors.

I think that makes sense, thanks; applied (along with previous patch).

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.0/servertests/st_setattr.py | 24 ++++++++++++------------
>  1 file changed, 12 insertions(+), 12 deletions(-)
> 
> diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_setattr.py
> index 5e9c4e9..912707d 100644
> --- a/nfs4.0/servertests/st_setattr.py
> +++ b/nfs4.0/servertests/st_setattr.py
> @@ -544,7 +544,7 @@ def testUnsupportedSocket(t, env):
>      _try_unsupported(t, env, path)
>  
>  def testSizeDir(t, env):
> -    """SETATTR(_SIZE) of a directory should return NFS4ERR_ISDIR
> +    """SETATTR(_SIZE) of a directory should return NFS4ERR_ISDIR or NFS4ERR_BAD_STATEID
>  
>      FLAGS: setattr dir all
>      DEPEND: MKDIR
> @@ -556,10 +556,10 @@ def testSizeDir(t, env):
>      check(res)
>      ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
>      res = c.compound(ops)
> -    check(res, NFS4ERR_ISDIR, "SETATTR(_SIZE) of a directory")
> +    check(res, [NFS4ERR_ISDIR, NFS4ERR_BAD_STATEID], "SETATTR(_SIZE) of a directory")
>      
>  def testSizeLink(t, env):
> -    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL
> +    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL or NFS4ERR_BAD_STATEID
>  
>      FLAGS: setattr symlink all
>      DEPEND: MKLINK
> @@ -571,11 +571,11 @@ def testSizeLink(t, env):
>      check(res)
>      ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
>      res = c.compound(ops)
> -    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK],
> +    check(res, [NFS4ERR_INVAL, NFS4ERR_SYMLINK, NFS4ERR_BAD_STATEID],
>              "SETATTR(FATTR4_SIZE) of a symlink")
>      
>  def testSizeBlock(t, env):
> -    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL
> +    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL or NFS4ERR_BAD_STATEID
>  
>      FLAGS: setattr block all
>      DEPEND: MKBLK
> @@ -587,10 +587,10 @@ def testSizeBlock(t, env):
>      check(res)
>      ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
>      res = c.compound(ops)
> -    check(res, NFS4ERR_INVAL, "SETATTR(FATTR4_SIZE) of a block device")
> +    check(res, [NFS4ERR_INVAL, NFS4ERR_BAD_STATEID], "SETATTR(FATTR4_SIZE) of a block device")
>      
>  def testSizeChar(t, env):
> -    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL
> +    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL or NFS4ERR_BAD_STATEID
>  
>      FLAGS: setattr char all
>      DEPEND: MKCHAR
> @@ -602,10 +602,10 @@ def testSizeChar(t, env):
>      check(res)
>      ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
>      res = c.compound(ops)
> -    check(res, NFS4ERR_INVAL, "SETATTR(FATTR4_SIZE) of a character device")
> +    check(res, [NFS4ERR_INVAL, NFS4ERR_BAD_STATEID], "SETATTR(FATTR4_SIZE) of a character device")
>      
>  def testSizeFifo(t, env):
> -    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL
> +    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL or NFS4ERR_BAD_STATEID
>  
>      FLAGS: setattr fifo all
>      DEPEND: MKFIFO
> @@ -617,10 +617,10 @@ def testSizeFifo(t, env):
>      check(res)
>      ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
>      res = c.compound(ops)
> -    check(res, NFS4ERR_INVAL, "SETATTR(FATTR4_SIZE) of a fifo")
> +    check(res, [NFS4ERR_INVAL, NFS4ERR_BAD_STATEID], "SETATTR(FATTR4_SIZE) of a fifo")
>  
>  def testSizeSocket(t, env):
> -    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL
> +    """SETATTR(FATTR4_SIZE) of a non-file object should return NFS4ERR_INVAL or NFS4ERR_BAD_STATEID
>  
>      FLAGS: setattr socket all
>      DEPEND: MKSOCK
> @@ -632,7 +632,7 @@ def testSizeSocket(t, env):
>      check(res)
>      ops = c.use_obj(path) + [c.setattr({FATTR4_SIZE: 0})]
>      res = c.compound(ops)
> -    check(res, NFS4ERR_INVAL, "SETATTR(FATTR4_SIZE) of a socket")
> +    check(res, [NFS4ERR_INVAL, NFS4ERR_BAD_STATEID], "SETATTR(FATTR4_SIZE) of a socket")
>  
>  def testInodeLocking(t, env):
>      """SETATTR: This causes printk message due to inode locking bug
> -- 
> 2.5.5
