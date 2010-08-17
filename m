From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/2] remove open share mode file permission check
Date: Mon, 16 Aug 2010 20:45:47 -0400
Message-ID: <20100817004547.GF7764@fieldses.org>
References: <20100817003734.GD7764@fieldses.org>
 <20100817003802.GE7764@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: iisaman@umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43728 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756694Ab0HQArr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Aug 2010 20:47:47 -0400
In-Reply-To: <20100817003802.GE7764@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Both of these are also available from

	git://linux-nfs.org/~bfields/pynfs.git

--b.

On Mon, Aug 16, 2010 at 08:38:02PM -0400, J. Bruce Fields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> First, the ability to deny reads is generally considered stronger than
> the ability to deny writes, so if anything should require special
> permissions it is the former.
> 
> Second, this test contradicts observed Windows behavior.  Testing shows
> that Windows prohits an opener without write permissions from denying
> reads.  It will allow such an open, but will then also allow concurrent
> read opens, failing to enforce the DENY_WRITE.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  lib/nfs4/servertests/st_open.py |   21 ---------------------
>  1 files changed, 0 insertions(+), 21 deletions(-)
> 
> diff --git a/lib/nfs4/servertests/st_open.py b/lib/nfs4/servertests/st_open.py
> index 64deb9f..1e5ec70 100644
> --- a/lib/nfs4/servertests/st_open.py
> +++ b/lib/nfs4/servertests/st_open.py
> @@ -347,27 +347,6 @@ def testShareConflict1(t, env):
>            "Trying to open a file with deny=WRITE "
>            "that was already opened with access=WRITE")
>  
> -# FRED - is this right response? or should it be allowed?
> -def testShareConflict2(t, env):
> -    """OPEN with deny=write when don't have write permissions
> -
> -    FLAGS: open all
> -    DEPEND: MKFILE MODE
> -    CODE: OPEN19
> -    """
> -    c1 = env.c1
> -    c1.init_connection()
> -    c1.create_confirm(t.code, attrs={FATTR4_MODE:0644},
> -                      access=OPEN4_SHARE_ACCESS_READ,
> -                      deny=OPEN4_SHARE_DENY_NONE)
> -    c2 = env.c2
> -    c2.init_connection()
> -    res = c2.open_file(t.code, access=OPEN4_SHARE_ACCESS_READ,
> -                       deny=OPEN4_SHARE_DENY_WRITE)
> -    check(res, NFS4ERR_ACCESS,
> -          "Trying to deny write permissions to others when "
> -          "don't have write permissions")
> -
>  def testFailedOpen(t, env):
>      """MULTIPLE: failed open should not mess up other clients' filehandles
>  
> -- 
> 1.7.0.4
> 
