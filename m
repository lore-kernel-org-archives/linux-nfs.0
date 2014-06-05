Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52417 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751593AbaFEC0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 22:26:40 -0400
Date: Wed, 4 Jun 2014 22:26:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH pynfs 01/17] 4.1 client: reclaim_complete after
 create_session
Message-ID: <20140605022640.GA12044@fieldses.org>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
 <1401915726-29092-2-git-send-email-dros@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401915726-29092-2-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2014 at 05:01:49PM -0400, Weston Andros Adamson wrote:
> Send RECLAIM_COMPLETE after CREATE_SESSION. This enables backend
> communication to v4.1 linux nfsd servers (i/o through MDS only).

If that's unconditionally adding a reclaim_complete after every
create_sesion, that's probably not what we want since there are tests
that want to do the reclaim_complete by hand.  You probably want to use
new_client_session() instead?  See 219cf7b7f7d0 and the preceding
commit.

--b.

> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> ---
>  nfs4.1/nfs4client.py | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
> index e750728..0d94a42 100644
> --- a/nfs4.1/nfs4client.py
> +++ b/nfs4.1/nfs4client.py
> @@ -367,6 +367,7 @@ class ClientRecord(object):
>          self.seqid = inc_u32(csr.csr_sequence) # XXX Do we need to check this?
>          sess = SessionRecord(csr, self)
>          self.c.sessions[sess.sessionid] = sess
> +        sess.compound([op.reclaim_complete(FALSE)])
>          return sess
>  
>      def _cb_hook(self, prefix, opname, funct):
> -- 
> 1.8.5.2 (Apple Git-48)
> 
