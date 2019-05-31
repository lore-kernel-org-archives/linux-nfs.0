Return-Path: <SRS0=b6pt=T7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31DEAC04AB6
	for <linux-nfs@archiver.kernel.org>; Fri, 31 May 2019 15:38:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F28A218C3
	for <linux-nfs@archiver.kernel.org>; Fri, 31 May 2019 15:38:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726546AbfEaPi1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 31 May 2019 11:38:27 -0400
Received: from fieldses.org ([173.255.197.46]:42168 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726037AbfEaPi1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 31 May 2019 11:38:27 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 1C0D61CEA; Fri, 31 May 2019 11:38:27 -0400 (EDT)
Date:   Fri, 31 May 2019 11:38:27 -0400
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     NeilBrown <neilb@suse.com>, Olga Kornievskaia <aglo@umich.edu>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/9] Multiple network connections for a single NFS mount.
Message-ID: <20190531153827.GB1251@fieldses.org>
References: <155917564898.3988.6096672032831115016.stgit@noble.brown>
 <001DED71-0E0D-46B1-BA34-84E6ACCBB79F@oracle.com>
 <87muj3tuuk.fsf@notabene.neil.brown.name>
 <4316E30B-1BD7-4F0E-8375-03E9F85FFD2B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4316E30B-1BD7-4F0E-8375-03E9F85FFD2B@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, May 31, 2019 at 09:46:32AM -0400, Chuck Lever wrote:
> Adding user tunables has never been known to increase the aggregate
> amount of happiness in the universe.

I need to add that to my review checklist: "will this patch increase the
aggregate amount of happiness in the universe?".

--b.
