Return-Path: <SRS0=jvUk=QV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7ED6CC4360F
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 17:12:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5672F222DA
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Feb 2019 17:12:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389055AbfBNRL7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 12:11:59 -0500
Received: from fieldses.org ([173.255.197.46]:37372 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726219AbfBNRL7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Feb 2019 12:11:59 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 466AD3EB; Thu, 14 Feb 2019 12:11:58 -0500 (EST)
Date:   Thu, 14 Feb 2019 12:11:58 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] st_getattr: do not expect server to return rdattr_error
Message-ID: <20190214171158.GA7710@fieldses.org>
References: <20190208171808.7861-1-tigran.mkrtchyan@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190208171808.7861-1-tigran.mkrtchyan@desy.de>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 08, 2019 at 06:18:08PM +0100, Tigran Mkrtchyan wrote:
> rfc7530:
>    5.8.1.12.  Attribute 11: rdattr_error
> 
>      Error returned from an attempt to retrieve attributes during a
>      READDIR operation.
> 
> IOW, we do not expect rdattr_error to be returned in reply to regular
> GETATTR operation.

Applied, thanks!

--b.

> 
> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> ---
>  nfs4.0/servertests/st_getattr.py | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/nfs4.0/servertests/st_getattr.py b/nfs4.0/servertests/st_getattr.py
> index 292fcd2..1c47ebf 100644
> --- a/nfs4.0/servertests/st_getattr.py
> +++ b/nfs4.0/servertests/st_getattr.py
> @@ -1,12 +1,14 @@
>  from xdrdef.nfs4_const import *
>  from .environment import check
> -from nfs4lib import get_attr_name
> +from nfs4lib import get_attr_name, get_attrbitnum_dict
>  import nfs_ops
>  op = nfs_ops.NFS4ops()
>  
>  def _try_mandatory(t, env, path):
>      c = env.c1
>      mandatory = [attr.bitnum for attr in env.attr_info if attr.mandatory]
> +    # don't expect rdattr_error to be a part of returned attributes
> +    mandatory.remove(get_attrbitnum_dict()['rdattr_error'])
>      ops = c.use_obj(path)
>      ops += [c.getattr(mandatory)]
>      res = c.compound(ops)
> -- 
> 2.20.1
