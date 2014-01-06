Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53011 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755191AbaAFUmq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 15:42:46 -0500
Date: Mon, 6 Jan 2014 15:42:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4.1: check whether old session is discard for EID5f
Message-ID: <20140106204246.GF31764@fieldses.org>
References: <52B8F86A.1040509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52B8F86A.1040509@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 24, 2013 at 10:58:50AM +0800, Kinglong Mee wrote:
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Applied and pushed out with the previous pynfs patch; let me know if you
see anything missing in my pynfs repo.

--b.

> ---
>  nfs4.1/server41tests/st_exchange_id.py | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
> index c31af95..d2c0c97 100644
> --- a/nfs4.1/server41tests/st_exchange_id.py
> +++ b/nfs4.1/server41tests/st_exchange_id.py
> @@ -244,7 +244,12 @@ def testNoUpdate101(t, env):
>      # Old session state should not be discarded until confirm:
>      res = sess1.compound([])
>      check(res)
> -    # FIXME - more checks here
> +
> +    # Old session state should be discarded after confirm:
> +    sess2 = c2.create_session()
> +    check(res)
> +    res = sess1.compound([])
> +    check(res, NFS4ERR_BADSESSION)
>  
>  def testNoUpdate101b(t, env):
>      """
> -- 
> 1.8.4.2
