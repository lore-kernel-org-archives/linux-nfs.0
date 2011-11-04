Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56764 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754574Ab1KDW0z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 18:26:55 -0400
Date: Fri, 4 Nov 2011 18:26:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] 4.1 CLNT: Send reclaim complete before create file
 at CSESS26
Message-ID: <20111104222653.GN721@fieldses.org>
References: <4EAA7CCD.8020309@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EAA7CCD.8020309@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 28, 2011 at 05:58:37PM +0800, Mi Jinlong wrote:
> Send reclaim complete before create file at CSESS26

Thanks, applied.--b.

> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  nfs4.1/server41tests/st_create_session.py |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/nfs4.1/server41tests/st_create_session.py b/nfs4.1/server41tests/st_create_session.py
> index f8f59f6..2f351a6 100644
> --- a/nfs4.1/server41tests/st_create_session.py
> +++ b/nfs4.1/server41tests/st_create_session.py
> @@ -455,8 +455,10 @@ def testRepTooBig(t, env):
>      name = env.testname(t)
>      c1 = env.c1.new_client(name)
>      # create session with a small ca_maxresponsesize
> -    chan_attrs = channel_attrs4(0,8192,50,8192,128,8,[])
> +    chan_attrs = channel_attrs4(0,8192,500,8192,128,8,[])
>      sess1 = c1.create_session(fore_attrs=chan_attrs)
> +    sess1.compound([op.reclaim_complete(FALSE)])
> +
>      owner = "owner_%s" % name
>      path = sess1.c.homedir + [name]
>      res = create_file(sess1, owner, path, access=OPEN4_SHARE_ACCESS_BOTH)
> -- 
> 1.7.5.1
> 
> 
