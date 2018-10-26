Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3B2CECDE44
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:54:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8ABD520824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 12:54:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="NrK1R6tA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ABD520824
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726111AbeJZVbs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 17:31:48 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:56464 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725983AbeJZVbs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 17:31:48 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=KIBP2c+A7RemyVMOSCWt/4r5fUBe4pePTEcO+6joG8o=; b=NrK1R6tAbCPGuQ2YVYz+9cfmY
        uesJh6xbyy4J3Y4ku0IcjPmMYnd/d9/+jd+lPafamRM0nd67MRswiEV8AkFkyop5dODcESEe78pTk
        g87n03kjzNlguX3lNqWCYDqmtWVLpq/4xQSica9SRGyUkRXLjE32RgdpmFWr2PLa4IP6lwOp0sPmw
        D4PwjIb99Hm7UKxhlVev8MU7mbhDGjQb1Mmeg6dq9rT/qEE/5uYZZPvgRejVuSi2MZVDuFnJ8bLyc
        Gln0X3pXNzAub17cXDKgrTmAOSpQ02HFLBvwHZSI8Dlpdy3A9YKDPX1p3K9u8e3wXmmCuzzp9Vr6Q
        1N9N9Fxsw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gG1dU-00063p-41; Fri, 26 Oct 2018 12:54:44 +0000
Date:   Fri, 26 Oct 2018 05:54:43 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com,
        Anna Schumaker <anna.schumaker@netapp.com>,
        viro@zeniv.linux.org.uk, Steve French <smfrench@gmail.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, linux-man@vger.kernel.org
Subject: Re: [PATCH v3 11/11] NFS replace cross device with cross filesystem
 check in copy_file_range
Message-ID: <20181026125443.GR25444@bombadil.infradead.org>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
 <20181025215147.36248-13-olga.kornievskaia@gmail.com>
 <20181025222754.GN25444@bombadil.infradead.org>
 <CAN-5tyEtHdZZ6Rvs+DZWbU9O5MU3hVwvSCsUFx+fjrY7AZ1JMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyEtHdZZ6Rvs+DZWbU9O5MU3hVwvSCsUFx+fjrY7AZ1JMA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 08:45:38AM -0400, Olga Kornievskaia wrote:
> On Thu, Oct 25, 2018 at 6:27 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Thu, Oct 25, 2018 at 05:51:47PM -0400, Olga Kornievskaia wrote:
> > > -     if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> > > +     if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
> >
> > Isn't it simpler to do:
> >
> >         if (file_in->f_inode->i_sb->s_type != &nfs4_fs_type)
> 
> I don't believe that's sufficient. What if "in"  fs was NFS and "out"
> fs was CIFS?

This is the NFS implementation, so you know that 'out' is an NFS file.

> > But now I've done some grepping, and I wonder whether it's possible
> > / desirable to also copy between inodes on a nfs4_remote_fs_type,
> > nfs4_remote_referral_fs_type, nfs4_referral_fs_type or nfs4_xdev_fs_type.
> > I haven't kept up with NFS development for a while, so maybe none of
> > those are possible.
> 
> Thank you for pointing it out. Grepping thru the code, don't believe
> the last one is used but for the migration and replication types, I
> don't know if there are any caveats that would preclude support for
> copy offload I'll check with Chuck Lever. Then the check should be
> that "in" and "out" are any of the 4 NFS types.
