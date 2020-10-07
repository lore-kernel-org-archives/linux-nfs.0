Return-Path: <SRS0=1cAr=DO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC071C4363D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Oct 2020 14:05:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 09603205F4
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Oct 2020 14:05:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fieldses.org header.i=@fieldses.org header.b="K4XIopx7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728532AbgJGOFD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Oct 2020 10:05:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56106 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728469AbgJGOFD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2020 10:05:03 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 59A44C061755
        for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2020 07:05:03 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 82C7F69C3; Wed,  7 Oct 2020 10:05:02 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 82C7F69C3
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1602079502;
        bh=gRT0dnFwglzPNulbC0c3JM2+Nto4TWO0uvknJ1NuNaE=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=K4XIopx7nYsaxFgP1L95/TNuSU3AcICBgY8UGfEhY1Pl/mCAUtWTbOC98xG2AnBpQ
         hej3HrEwdmEfa9WPbfBTWfb+DLogXmvfLrd8vXxLgTK/6V5SgKDoqPJx9jKhcORP9l
         bGvchzJzMCd+9GT2cw9XYBuuL7qeglTMrf1qiNLA=
Date:   Wed, 7 Oct 2020 10:05:02 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Benjamin Coddington <bcodding@redhat.com>,
        Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: unsharing tcp connections from different NFS mounts
Message-ID: <20201007140502.GC23452@fieldses.org>
References: <20201006151335.GB28306@fieldses.org>
 <95542179-0C20-4A1F-A835-77E73AD70DB8@redhat.com>
 <CAN-5tyGDC0VQqjqUNzs_Ka+-G_1eCScVxuXvWsp7xe7QYj69Ww@mail.gmail.com>
 <20201007001814.GA5138@fieldses.org>
 <57E3293C-5C49-4A80-957B-E490E6A9B32E@redhat.com>
 <5B5CF80C-494A-42D3-8D3F-51C0277D9E1B@redhat.com>
 <8ED5511E-25DE-4C06-9E26-A1947383C86A@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8ED5511E-25DE-4C06-9E26-A1947383C86A@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Oct 07, 2020 at 09:45:50AM -0400, Chuck Lever wrote:
> 
> 
> > On Oct 7, 2020, at 8:55 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> > 
> > On 7 Oct 2020, at 7:27, Benjamin Coddington wrote:
> > 
> >> On 6 Oct 2020, at 20:18, J. Bruce Fields wrote:
> >> 
> >>> On Tue, Oct 06, 2020 at 05:46:11PM -0400, Olga Kornievskaia wrote:
> >>>> On Tue, Oct 6, 2020 at 3:38 PM Benjamin Coddington <bcodding@redhat.com> wrote:
> >>>>> 
> >>>>> On 6 Oct 2020, at 11:13, J. Bruce Fields wrote:
> > 
> >>> Looks like nfs4_init_{non}uniform_client_string() stores it in
> >>> cl_owner_id, and I was thinking that meant cl_owner_id would be used
> >>> from then on....
> >>> 
> >>> But actually, I think it may run that again on recovery, yes, so I bet
> >>> changing the nfs4_unique_id parameter midway like this could cause bugs
> >>> on recovery.
> >> 
> >> Ah, that's what I thought as well.  Thanks for looking closer Olga!
> > 
> > Well, no -- it does indeed continue to use the original cl_owner_id.  We
> > only jump through nfs4_init_uniquifier_client_string() if cl_owner_id is
> > NULL:
> > 
> > 6087 static int
> > 6088 nfs4_init_uniform_client_string(struct nfs_client *clp)
> > 6089 {
> > 6090     size_t len;
> > 6091     char *str;
> > 6092
> > 6093     if (clp->cl_owner_id != NULL)
> > 6094         return 0;
> > 6095
> > 6096     if (nfs4_client_id_uniquifier[0] != '\0')
> > 6097         return nfs4_init_uniquifier_client_string(clp);
> > 6098
> > 
> > 
> > Testing proves this out as well for both EXCHANGE_ID and SETCLIENTID.
> > 
> > Is there any precedent for stabilizing module parameters as part of a
> > supported interface?  Maybe this ought to be a mount option, so client can
> > set a uniquifier per-mount.
> 
> The protocol is designed as one client-ID per client. FreeBSD is
> the only client I know of that uses one client-ID per mount, fwiw.
> 
> You are suggesting each mount point would have its own lease. There
> would likely be deeper implementation changes needed than just
> specifying a unique client-ID for each mount point.

Huh, I thought that should do it.

Do you have something specific in mind?

--b.
