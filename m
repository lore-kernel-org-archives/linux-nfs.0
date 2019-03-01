Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A9D6C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 15:04:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3229B20850
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 15:04:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728257AbfCAPEC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 10:04:02 -0500
Received: from fieldses.org ([173.255.197.46]:34866 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727492AbfCAPEC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Mar 2019 10:04:02 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 8A5891E19; Fri,  1 Mar 2019 10:04:01 -0500 (EST)
Date:   Fri, 1 Mar 2019 10:04:01 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org
Subject: Re: [PATCH RFC 4/4] NFSD: Prototype support for IMA on NFS (server)
Message-ID: <20190301150401.GA17160@fieldses.org>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <20190214204326.6469.25843.stgit@manet.1015granger.net>
 <20190218193218.GA5879@fieldses.org>
 <A7D59BDC-08B3-4338-8E3B-6B41AC652968@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <A7D59BDC-08B3-4338-8E3B-6B41AC652968@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 18, 2019 at 02:41:24PM -0500, Chuck Lever wrote:
> 
> 
> > On Feb 18, 2019, at 2:32 PM, bfields@fieldses.org wrote:
> > 
> > On Thu, Feb 14, 2019 at 03:43:26PM -0500, Chuck Lever wrote:
> >> When NFSv4 Security Label support is enabled and kernel Integrity
> >> and IMA support is enabled (via CONFIG), then build in code to
> >> handle the "security.ima" xattr. The NFS server converts incoming
> >> GETATTR and SETATTR calls to acesses and updates of the xattr.
> >> 
> >> The FATTR4 bit is made up; meaning we still have to go through a
> >> standards process to allocate a bit that all NFS vendors agree on.
> >> Thus there is no guarantee this prototype will interoperate with
> >> others or with a future standards-based implementation.
> > 
> > Why the dependence on CONFIG_NFSD_V4_SECURITY_LABEL?
> 
> Hrm, well there is some mechanism on the client side that IMA
> needs that is behind CONFIG_NFS_V4_SECURITY_LABEL. I guess I
> didn't think about not doing the same thing on the server. It
> may just be an artifact of an earlier version of this code.
> 
> 
> > (Also, I wonder if we actually need CONFIG_NFSD_V4_SECURITY_LABEL or if
> > we could just remove it, or replace it by CONFIG_SECURITY where
> > necessary.)
> 
> On the server, there is already a (run-time) export option to
> enable and disable security labels. Is there a reason a
> distribution would want to disable client or server support
> for security labels at build time?

Distributions tend to want kernels that can do anything, with run time
controls that are adequate to handle any use cases.

So given that we need adequate run-time configuration, why might someone
also want the ability to disable at build time?  Some reasons I can
think of:

	- they need a really small kernel.
	- the feature is too hard to support, or they think it
	  introduces security risks, so they don't want their users
	  turning it on at all.

I could see any of those being reasons for someone not to want NFSD_V4
or SECURITY at all, but is there likely to be a big need to configure in
both of those things but configure out NFSD_V4_SECURITY_LABEL?  That
seems unnecessarily fine grained.

--b.
