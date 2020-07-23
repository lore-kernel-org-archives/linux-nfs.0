Return-Path: <SRS0=gZaf=BC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3787EC433EB
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Jul 2020 19:38:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id DADC32065F
	for <linux-nfs@archiver.kernel.org>; Thu, 23 Jul 2020 19:38:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="j9lFFqkW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726686AbgGWTiN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 23 Jul 2020 15:38:13 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40828 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725894AbgGWTiM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jul 2020 15:38:12 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id CD701C0619DC
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2020 12:38:12 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 80570680F; Thu, 23 Jul 2020 15:38:11 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 80570680F
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1595533091;
        bh=1rK+pDS4+s/gBIr9qdDY4f5qfOg2+PYW5GSV9ryoroY=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=j9lFFqkWH4IehVxltDrMDdw1NbmPyeCXyUWbLlLFOXtfhPTg10sD6qPVqK8nuZkdK
         lGDyMDAM9QQUEiRAezbEe42bRoeEW2PoO+ZYF16OJd066XUYFAVTnpE8oCzyYfgZDa
         CiNnmmVN+NNrcD8VNj5mtCfLIaFHy5BtmqxjW0NQ=
Date:   Thu, 23 Jul 2020 15:38:11 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: fix_priv_head
Message-ID: <20200723193811.GG31487@fieldses.org>
References: <3799C9E0-DFF3-450C-A815-14BAFAC97EA8@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3799C9E0-DFF3-450C-A815-14BAFAC97EA8@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jul 23, 2020 at 01:46:19PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> I'm trying to figure out if fix_priv_head is still necessary. This
> was introduced by 7c9fdcfb1b64 ("[PATCH] knfsd: svcrpc: gss:
> server-side implementation of rpcsec_gss privacy").
> 
> static void
> fix_priv_head(struct xdr_buf *buf, int pad)
> {
>         if (buf->page_len == 0) {
>                 /* We need to adjust head and buf->len in tandem in this
>                  * case to make svc_defer() work--it finds the original
>                  * buffer start using buf->len - buf->head[0].iov_len. */
>                 buf->head[0].iov_len -= pad;
>         }
> }
> 
> It doesn't seem like unwrapping can ever result in a buffer length that
> is not quad-aligned. Is that simply a characteristic of modern enctypes?

This code is beofre any unwrapping.  We're looking at the length of the
encrypted (wrapped) object here, not the unwrapped buffer.

When using privacy, the body of an rpcsec_gss request is a single opaque
object consisting of the wrapped data.  So the question is whether
there's any case where the length of that object can be less than the
length remaining in the received buffer.

I think the only reason for bytes at the end is, yes, that that opaque
object is not a multiple of 4 and so rpc requires padding at the end.

I think that might be possible with encryption types that use cipher
text stealing, but I'm not certain.

--b.
