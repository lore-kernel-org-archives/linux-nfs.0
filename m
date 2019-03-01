Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BBB4C10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 16:10:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6511C2083D
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 16:10:38 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389065AbfCAQKc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 11:10:32 -0500
Received: from fieldses.org ([173.255.197.46]:34938 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387940AbfCAQKb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Mar 2019 11:10:31 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id F262D1E19; Fri,  1 Mar 2019 11:10:30 -0500 (EST)
Date:   Fri, 1 Mar 2019 11:10:30 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org
Subject: Re: [PATCH RFC 4/4] NFSD: Prototype support for IMA on NFS (server)
Message-ID: <20190301161030.GB17671@fieldses.org>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <20190214204326.6469.25843.stgit@manet.1015granger.net>
 <20190218193218.GA5879@fieldses.org>
 <A7D59BDC-08B3-4338-8E3B-6B41AC652968@oracle.com>
 <20190301150401.GA17160@fieldses.org>
 <B8F76BFF-73DB-4904-8DB6-5ADE093AB051@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <B8F76BFF-73DB-4904-8DB6-5ADE093AB051@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 01, 2019 at 11:01:14AM -0500, Chuck Lever wrote:
> 
> 
> > On Mar 1, 2019, at 10:04 AM, Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Mon, Feb 18, 2019 at 02:41:24PM -0500, Chuck Lever wrote:
> >> 
> >> 
> >>> On Feb 18, 2019, at 2:32 PM, bfields@fieldses.org wrote:
> >>> 
> >>> On Thu, Feb 14, 2019 at 03:43:26PM -0500, Chuck Lever wrote:
> >>>> When NFSv4 Security Label support is enabled and kernel Integrity
> >>>> and IMA support is enabled (via CONFIG), then build in code to
> >>>> handle the "security.ima" xattr. The NFS server converts incoming
> >>>> GETATTR and SETATTR calls to acesses and updates of the xattr.
> >>>> 
> >>>> The FATTR4 bit is made up; meaning we still have to go through a
> >>>> standards process to allocate a bit that all NFS vendors agree on.
> >>>> Thus there is no guarantee this prototype will interoperate with
> >>>> others or with a future standards-based implementation.
> >>> 
> >>> Why the dependence on CONFIG_NFSD_V4_SECURITY_LABEL?
> >> 
> >> Hrm, well there is some mechanism on the client side that IMA
> >> needs that is behind CONFIG_NFS_V4_SECURITY_LABEL. I guess I
> >> didn't think about not doing the same thing on the server. It
> >> may just be an artifact of an earlier version of this code.
> >> 
> >> 
> >>> (Also, I wonder if we actually need CONFIG_NFSD_V4_SECURITY_LABEL or if
> >>> we could just remove it, or replace it by CONFIG_SECURITY where
> >>> necessary.)
> >> 
> >> On the server, there is already a (run-time) export option to
> >> enable and disable security labels. Is there a reason a
> >> distribution would want to disable client or server support
> >> for security labels at build time?
> > 
> > Distributions tend to want kernels that can do anything, with run time
> > controls that are adequate to handle any use cases.
> > 
> > So given that we need adequate run-time configuration, why might someone
> > also want the ability to disable at build time?  Some reasons I can
> > think of:
> > 
> > 	- they need a really small kernel.
> > 	- the feature is too hard to support, or they think it
> > 	  introduces security risks, so they don't want their users
> > 	  turning it on at all.
> > 
> > I could see any of those being reasons for someone not to want NFSD_V4
> > or SECURITY at all, but is there likely to be a big need to configure in
> > both of those things but configure out NFSD_V4_SECURITY_LABEL?  That
> > seems unnecessarily fine grained.
> 
> I'm not clear, then. Are you proposing to control support for IMA labels
> with the "security_labels" export option?

Just security labels.  I'd think it'd make sense to support IMA labels
whenever IMA and NFSD_V4 are both turned on.

--b.
