Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64B80C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:54:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 404AB21738
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 15:54:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725911AbfBSPyX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 10:54:23 -0500
Received: from fieldses.org ([173.255.197.46]:47022 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725820AbfBSPyX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 10:54:23 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 039A81C9D; Tue, 19 Feb 2019 10:54:23 -0500 (EST)
Date:   Tue, 19 Feb 2019 10:54:22 -0500
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     bfields@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 10/10] NFSD add nfs4 inter ssc to nfsd4_copy
Message-ID: <20190219155422.GB19603@fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-11-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181130200348.59524-11-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 30, 2018 at 03:03:48PM -0500, Olga Kornievskaia wrote:
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index 2e28254..238c4b7 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
...
> +static __be32
> +nfsd4_setup_inter_ssc(struct svc_rqst *rqstp,
> +		      struct nfsd4_compound_state *cstate,
> +		      struct nfsd4_copy *copy,
> +		      struct vfs_mount **mount)

That should be struct vfsmount.  Don't forget to check the compile with
the new config option both on and off.

--b.

> +{
> +	*mount = NULL;
> +	return -EINVAL;
> +}
