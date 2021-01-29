Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEB69C433DB
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Jan 2021 02:51:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 58E4764DFF
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Jan 2021 02:51:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231517AbhA2CvZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Jan 2021 21:51:25 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:32862 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231470AbhA2CvX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2021 21:51:23 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E31E5C061574
        for <linux-nfs@vger.kernel.org>; Thu, 28 Jan 2021 18:50:42 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id D2A194599; Thu, 28 Jan 2021 21:50:41 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org D2A194599
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1611888641;
        bh=/PNiZBSBHkdCLynmfVXpV/UcnWGC24yhrG6mM4fz0vA=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=nfSRm87a+p97/ZmMnMh8VQ/0pmOv/vzQmLYrj6UN2aFBDo6fqtzHMFx6D04smqvYp
         vil+rYniVb3AEmDccW/VQcMTugZMqTNInx24eSJ9uFA4CGJc/e0/8ScrKP2gtKDSHC
         19sNoaU6f1UOMmB6NGMwpHpqRQTinWX5TGVgAIuM=
Date:   Thu, 28 Jan 2021 21:50:41 -0500
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "guy@vastdata.com" <guy@vastdata.com>,
        "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: we don't support removing system.nfs4_acl
Message-ID: <20210129025041.GA12151@fieldses.org>
References: <20210128223638.GE29887@fieldses.org>
 <95e5f9e4-76d4-08c4-ece3-35a10c06073b@vastdata.com>
 <cbc7115cc5d5aeb7ffb9e9b3880e453bf54ecbdb.camel@hammerspace.com>
 <20210129023527.GA11864@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210129023527.GA11864@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Jan 28, 2021 at 09:35:27PM -0500, bfields@fieldses.org wrote:
> Note that this patch doesn't prevent an application from setting a
> zero-length ACL.  The xattr format is XDR with the first four bytes
> representing the number of ACEs, so you'd set a zero-length ACL by
> passing down a 4-byte all-zero buffer as the new value of the
> system.nfs4_acl xattr.
> 
> A zero-length NULL buffer is what's used to implement removexattr:
> 
> int
> __vfs_removexattr(struct dentry *dentry, const char *name)
> {
> 	...
> 	return handler->set(handler, dentry, inode, name, NULL, 0, XATTR_REPLACE);
> }
> 
> That's the case this patch covers.

So, I should have said in the changelog, apologies--the behavior without
this patch is that when it gets a removexattr, the client sends a
SETATTR with a bitmap claiming there's an ACL attribute, but a
zero-length attribute value list, and the server (correctly) returns
BADXDR.

--b.
