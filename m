Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B8B0C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:17:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 570992147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 16:17:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725885AbfBSQRM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 11:17:12 -0500
Received: from fieldses.org ([173.255.197.46]:47112 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726546AbfBSQRM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 11:17:12 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id E58AA88A; Tue, 19 Feb 2019 11:17:11 -0500 (EST)
Date:   Tue, 19 Feb 2019 11:17:11 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 04/10] NFSD add ca_source_server<> to COPY
Message-ID: <20190219161711.GD19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-5-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-5-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:42PM -0500, Olga Kornievskaia wrote:
> Decode the ca_source_server list that's sent but only use the
> first one. Presence of non-zero list indicates an "inter" copy.
> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  fs/nfsd/nfs4xdr.c | 69 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/xdr4.h    | 12 ++++++----
>  2 files changed, 74 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 3de42a7..879ddc6 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
...
>  static __be32
>  nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
>  {
>  	DECODE_HEAD;
> -	unsigned int tmp;
> +	struct nl4_server ns_dummy;

This struct is much too big to put on the stack.

--b.
