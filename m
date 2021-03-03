Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0FCC001C7
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Mar 2021 00:29:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EC44D64EA4
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Mar 2021 00:29:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1451072AbhCDA3r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Mar 2021 19:29:47 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60112 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239064AbhCCSjF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Mar 2021 13:39:05 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C47E9C06175F
        for <linux-nfs@vger.kernel.org>; Wed,  3 Mar 2021 10:38:23 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 127DA2824; Wed,  3 Mar 2021 13:38:23 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 127DA2824
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1614796703;
        bh=uE6y/NN26t2PtuXvWcwN+Rv+MpWB2IrYuaEcnV6QzmU=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=dG5NLtKz1a0wGWpdCxUSXqC/EXSsE4xK3dWcLW8ZeTWFaYLuLro37MPL1TJESbJbf
         fBx4UI7QSUZOKI+jB1i9JtdF7H+CVcXm8oxaMAVEpxoFtkfEllKBJCrXSpyF41ZD56
         bHMuT5tNaMRh7bX+K5CIsh1hitDlbMV1LFNk35+U=
Date:   Wed, 3 Mar 2021 13:38:23 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 19/42] SUNRPC: Fix xdr_get_next_encode_buffer() page
 boundary handling
Message-ID: <20210303183823.GD1282@fieldses.org>
References: <161461145466.8508.13379815439337754427.stgit@klimt.1015granger.net>
 <161461183307.8508.17196295994390119297.stgit@klimt.1015granger.net>
 <20210302221130.GG3400@fieldses.org>
 <592A34CB-C178-4272-8905-F3BA95BCE299@oracle.com>
 <20210303165251.GB1282@fieldses.org>
 <D8625219-C758-44C0-A74E-272019E12C2E@oracle.com>
 <20210303182546.GC1282@fieldses.org>
 <FB4626C1-C2C1-4927-971B-8937420F963A@oracle.com>
 <0908A838-D518-4F81-B6EA-8C088D5538E9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0908A838-D518-4F81-B6EA-8C088D5538E9@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 03, 2021 at 06:30:40PM +0000, Chuck Lever wrote:
> 
> 
> > On Mar 3, 2021, at 1:27 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> > 
> > 
> > 
> >> On Mar 3, 2021, at 1:25 PM, Bruce Fields <bfields@fieldses.org> wrote:
> >> 
> >> On Wed, Mar 03, 2021 at 06:19:33PM +0000, Chuck Lever wrote:
> >>> 
> >>> 
> >>>> On Mar 3, 2021, at 11:52 AM, Bruce Fields <bfields@fieldses.org> wrote:
> >>>> 
> >>>> On Wed, Mar 03, 2021 at 03:43:28PM +0000, Chuck Lever wrote:
> >>>>> Why would that not be OK? the next call to xdr_get_next_encode_buffer()
> >>>>> should do the right thing and bounce the new encoded data from the
> >>>>> next page into this one again.
> >>>>> 
> >>>>> So far I have not encountered any problems. Would such a problem show
> >>>>> up with some frequency under normal use, or would it be especially
> >>>>> subtle?
> >>>> 
> >>>> I mainly just want to make sure we've got a coherent idea what this code
> >>>> is doing....
> >>> 
> >>> Agreed, that's a good thing.
> >> 
> >> I'm also a little vague on what exactly the problem is you're running
> >> into.  (Probably because I haven't really looked at the v3 readdir
> >> encoding.)
> >> 
> >> Is it approaching the end of a page, or is it running out of buflen?
> >> How exactly does it fail?
> > 
> > I don't recall exactly, it was a late last summer when I wrote all these.
> > 
> > Approaching the end of a page, IIRC, the unpatched code would leave
> > a gap in the directory entry stream.
> 
> Well, when I converted the entry encoders to use xdr_stream, it would
> have a problem around the end of a page. The existing encoders are
> open-coded to deal with this case.

We're not seeing v4 readdir bugs, though, I wonder what's different?

--b.
