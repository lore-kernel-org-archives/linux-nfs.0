Return-Path: <SRS0=ZX+r=P2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E13CC5ACD5
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 20:10:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E866A20657
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 20:10:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729362AbfARUKw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 18 Jan 2019 15:10:52 -0500
Received: from fieldses.org ([173.255.197.46]:51558 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729356AbfARUKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Jan 2019 15:10:52 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id E95771EF5; Fri, 18 Jan 2019 15:10:51 -0500 (EST)
Date:   Fri, 18 Jan 2019 15:10:51 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kstewart@linuxfoundation.org, simo@redhat.com
Subject: Re: [PATCH RFC] SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/
 files
Message-ID: <20190118201051.GA27125@fieldses.org>
References: <20190117220233.13961.53423.stgit@manet.1015granger.net>
 <20190118072942.GA22125@infradead.org>
 <EDB5039C-2DD9-4134-A447-040840B34D85@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EDB5039C-2DD9-4134-A447-040840B34D85@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 18, 2019 at 10:42:00AM -0500, Chuck Lever wrote:
> 
> 
> > On Jan 18, 2019, at 2:29 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > The general idea is to replace the existing boilerplate with just the tag,
> > not add it on top.  Altough someone will have to conform how that works
> > with the BSD license.
> 
> The online SPDX license text matches the license text in these particular
> files. Can I therefore assume I have permission to remove the boilerplate
> in this patch?

I've got no special knowledge or insight, but: that sounds totally
reasonable to me.

--b.
