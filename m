Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49459 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137AbaGKWUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 18:20:08 -0400
Date: Fri, 11 Jul 2014 18:20:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Malahal Naineni <malahal@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] Open files with OPEN4_SHARE_DENY_NONE for DELEG5 test
Message-ID: <20140711222007.GD13656@fieldses.org>
References: <1403542662-8450-1-git-send-email-malahal@us.ibm.com>
 <1403542662-8450-2-git-send-email-malahal@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1403542662-8450-2-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying both.

On Mon, Jun 23, 2014 at 11:57:42AM -0500, Malahal Naineni wrote:
> DELEG5 test, while getting the READ delegation, uses
> OPEN4_SHARE_DENY_WRITE as that is the default.

That's a really dumb default, by the way, we should fix it to default to
DENY_NONE.

--b.

> Pass
> OPEN4_SHARE_DENY_NONE explicitly as that is assumed
> in the test.
> 
> Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> ---
>  nfs4.0/servertests/st_delegation.py | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/nfs4.0/servertests/st_delegation.py b/nfs4.0/servertests/st_delegation.py
> index 4da3a7a..eaff326 100644
> --- a/nfs4.0/servertests/st_delegation.py
> +++ b/nfs4.0/servertests/st_delegation.py
> @@ -249,6 +249,7 @@ def testManyReaddeleg(t, env, funct=_recall, response=NFS4_OK):
>              
>          # Get a read delegation
>          res = c.open_file(t.code, access=OPEN4_SHARE_ACCESS_READ,
> +                          deny=OPEN4_SHARE_DENY_NONE,
>                            set_recall=True,
>                            recall_funct=funct, recall_return=response)
>          fh, stateid = c.confirm(t.code, res)
> -- 
> 1.8.3.1
> 
