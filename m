Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D08A3C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 14:04:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA77520880
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 14:04:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726414AbfBTOEG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 09:04:06 -0500
Received: from mx1.redhat.com ([209.132.183.28]:24106 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726194AbfBTOEG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 09:04:06 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 33DC5C0D0861;
        Wed, 20 Feb 2019 14:04:06 +0000 (UTC)
Received: from parsley.fieldses.org (ovpn-117-90.phx2.redhat.com [10.3.117.90])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 06CBC5ED52;
        Wed, 20 Feb 2019 14:04:05 +0000 (UTC)
Received: by parsley.fieldses.org (Postfix, from userid 2815)
        id B746118036E; Wed, 20 Feb 2019 09:04:04 -0500 (EST)
Date:   Wed, 20 Feb 2019 09:04:04 -0500
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v2 06/10] NFSD add COPY_NOTIFY operation
Message-ID: <20190220140403.GA32357@parsley.fieldses.org>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-7-olga.kornievskaia@gmail.com>
 <20190220020732.GF19603@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190220020732.GF19603@fieldses.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 20 Feb 2019 14:04:06 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 19, 2019 at 09:07:32PM -0500, J. Bruce Fields wrote:
> On Fri, Nov 30, 2018 at 03:03:44PM -0500, Olga Kornievskaia wrote:
> > diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> > index 879ddc6..c9fb625 100644
> > --- a/fs/nfsd/nfs4xdr.c
> > +++ b/fs/nfsd/nfs4xdr.c
> ...
> > +	/* cnr_lease_time */
> > +	p = xdr_encode_hyper(p, cn->cpn_sec);
> > +	*p++ = cpu_to_be32(cn->cpn_nsec);
> 
> This is redundant; xdr_encode_hyper already wrote cn->cpn_sec.

Um, I completely missed the sec/nsec distinction, never mind me.

--b.
