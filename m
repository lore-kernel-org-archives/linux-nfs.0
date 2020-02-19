Return-Path: <SRS0=wW16=4H=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E4EFC169F9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Feb 2020 18:13:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2247F2465D
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Feb 2020 18:13:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726598AbgBSSNs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Feb 2020 13:13:48 -0500
Received: from fieldses.org ([173.255.197.46]:43664 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726582AbgBSSNs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Feb 2020 13:13:48 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 01BE7BCE; Wed, 19 Feb 2020 13:13:47 -0500 (EST)
Date:   Wed, 19 Feb 2020 13:13:47 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Richard Haines <richard_c_haines@btinternet.com>
Cc:     smayhew@redhat.com, paul@paul-moore.com, sds@tycho.nsa.gov,
        selinux@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: Test to trace NFS unlabeled bug
Message-ID: <20200219181347.GB23275@fieldses.org>
References: <db2a9d661ec9b53e01c029f98877a3556d8297bc.camel@btinternet.com>
 <20200219180720.GA23275@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200219180720.GA23275@fieldses.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 19, 2020 at 01:07:20PM -0500, J. Bruce Fields wrote:
> On Wed, Feb 19, 2020 at 06:03:02PM +0000, Richard Haines wrote:
> > I've been building selinux-testsuite tests for various filesystems and
> > have come across an unlabeled issue when testing. Stephen thinks that
> > this is a bug sometimes seen with labeled NFS, where the top-level
> > mounted directory shows up with unlabeled_t initially, then later gets
> > refreshed to a valid context.
> > 
> > I've put together a test script, policy module and mount prog to
> > facilitate debugging this issue. I've set out how I tested this on a
> > Fedora 31 system below, if any problems let me know. 
> 
> Thanks!  Adding the nfs group to the cc.
> 
> I seem to recall a report of a similar bug in the Red Hat bugzilla, that
> I spent a little time investigating and couldn't pin down.  I'll see if
> I can dig that up.

This one:

	https://bugzilla.redhat.com/show_bug.cgi?id=1625955

It should be publicy visible.

--b.
