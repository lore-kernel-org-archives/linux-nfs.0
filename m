Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEDF0C433FE
	for <linux-nfs@archiver.kernel.org>; Thu, 19 May 2022 13:54:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238421AbiESNyT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 19 May 2022 09:54:19 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48586 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239260AbiESNxi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 May 2022 09:53:38 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E6B1F5003B
        for <linux-nfs@vger.kernel.org>; Thu, 19 May 2022 06:53:11 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 2B2E664B9; Thu, 19 May 2022 09:53:11 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 2B2E664B9
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1652968391;
        bh=Y8uDHCJYQlCaLl1S9noV5VBOzQ8EquGFlNwDlLNX5SQ=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=QmMdHIGWE2+9BMVaIRyuwBQe5YNNeCCXsrtUp0t7/+X/vxR5mWVxjRFYiCOwcmn6M
         lp5wdS8L/a6+XMrSf9HjP0V9MFPJ3nKjAyqB3GzDYf3fmt6Vtw0bdDlfDM6qDvvqiZ
         VeCFbE0RRrnJpZShY9sMdVEJZx2UppGiyLEZT4NE=
Date:   Thu, 19 May 2022 09:53:11 -0400
From:   "bfields@fieldses.org" <bfields@fieldses.org>
To:     Steve Dickson <steved@redhat.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "trondmy@kernel.org" <trondmy@kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/6] Allow nfs4-acl-tools to access 'dacl' and 'sacl'
Message-ID: <20220519135311.GC23564@fieldses.org>
References: <20220514144436.4298-1-trondmy@kernel.org>
 <20220515015946.GB30004@fieldses.org>
 <15c4602658aff025b6d84e2b9461378930cbd802.camel@hammerspace.com>
 <627133c7-dab9-db0b-5fdf-ecb95820e76a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <627133c7-dab9-db0b-5fdf-ecb95820e76a@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, May 19, 2022 at 09:47:41AM -0400, Steve Dickson wrote:
> 
> 
> On 5/14/22 11:23 PM, Trond Myklebust wrote:
> >On Sat, 2022-05-14 at 21:59 -0400, J.Bruce Fields wrote:
> >>On Sat, May 14, 2022 at 10:44:30AM -0400, trondmy@kernel.org wrote:
> >>>From: Trond Myklebust <trond.myklebust@hammerspace.com>
> >>>
> >>>The following patch set matches the kernel patches to allow access
> >>>to
> >>>the NFSv4.1 'dacl' and 'sacl' attributes. The current patches are
> >>>very
> >>>basic, adding support for encoding/decoding the new attributes only
> >>>when
> >>>the user specifies the '--dacl' or '--sacl' flags on the command
> >>>line.
> >>
> >>Seems like a reasonable thing to do.
> >>
> >>I'd rather not be responsible for nfs4-acl-tools any longer, though.
> >>
> >>--b.
> >
> >I suspected that might be the case, but since you haven't made any
> >announcements about anybody else taking over, I figured I'd start by
> >sending these to you.
> >
> >So who should take over the nfs4-acl-tools maintainer role? Is that
> >something Red Hat might be interested in doing, or should I volunteer
> >to do it while we wait for somebody to get so fed up that they decide
> >to step in?
> >
> Yeah... it probably something we should take over....
> 
> I'll add these to my todo list... Where does the upstream repo
> live today?

The Fedora rpm package points to my repo on linux-nfs.  So you can just
clone that and update the spec files to point at your repo.

--b.
