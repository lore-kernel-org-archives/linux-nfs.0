Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082AbaFEC3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 22:29:19 -0400
Date: Wed, 4 Jun 2014 22:29:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs 02/17] 4.1 server: service RECLAIM_COMPLETE
 operations
Message-ID: <20140605022918.GB12044@fieldses.org>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
 <1401915726-29092-3-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401915726-29092-3-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2014 at 05:01:50PM -0400, Weston Andros Adamson wrote:
> Just return ok!

Technically it should record whether or not the reclaim_complete has
happened and return a GRACE error on any non-reclaim open performed
before the reclaim_complete--but for your purposes you may not care...

--b.

> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  nfs4.1/nfs4server.py | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
> index 65fb9af..3607dc0 100755
> --- a/nfs4.1/nfs4server.py
> +++ b/nfs4.1/nfs4server.py
> @@ -1809,6 +1809,9 @@ class NFS4Server(rpc.Server):
>          with find_state(env, arg.deleg_stateid, allow_0=False) as state:
>              state.delegreturn()
>          return encode_status(NFS4_OK)
> +
> +    def op_reclaim_complete(self, arg, env):
> +        return encode_status(NFS4_OK)
>      
>      def op_getdevicelist(self, arg, env): # STUB
>          check_session(env)
> -- 
> 1.8.5.2 (Apple Git-48)
> 
