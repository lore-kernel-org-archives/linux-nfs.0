Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CEFAC04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 11:46:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1EA4F20848
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 11:46:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EA4F20848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726163AbeLCLqo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 06:46:44 -0500
Received: from usa-sjc-mx-foss1.foss.arm.com ([217.140.101.70]:35426 "EHLO
        foss.arm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726023AbeLCLqo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Dec 2018 06:46:44 -0500
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
        by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7A683165C;
        Mon,  3 Dec 2018 03:45:59 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.113])
        by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 84BA23F59C;
        Mon,  3 Dec 2018 03:45:58 -0800 (PST)
Date:   Mon, 3 Dec 2018 11:45:55 +0000
From:   Catalin Marinas <catalin.marinas@arm.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "cristian.marussi@arm.com" <cristian.marussi@arm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Message-ID: <20181203114555.GF49865@arrakis.emea.arm.com>
References: <20180917130335.112832-38-trond.myklebust@hammerspace.com>
 <20180917130335.112832-39-trond.myklebust@hammerspace.com>
 <20180917130335.112832-40-trond.myklebust@hammerspace.com>
 <20180917130335.112832-41-trond.myklebust@hammerspace.com>
 <20181109111930.idve77thgcnsg5u3@localhost>
 <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
 <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
 <a23d0c18-1030-82f3-a046-41497dc7725b@arm.com>
 <92a750b72255c6a91fd5606668f26b2d492ec43f.camel@hammerspace.com>
 <7d58a5dc7f62117245c824fc63bce62ba99e5b44.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d58a5dc7f62117245c824fc63bce62ba99e5b44.camel@hammerspace.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

On Sun, Dec 02, 2018 at 04:44:49PM +0000, Trond Myklebust wrote:
> On Fri, 2018-11-30 at 14:31 -0500, Trond Myklebust wrote:
> > On Fri, 2018-11-30 at 16:19 +0000, Cristian Marussi wrote:
> > > On 29/11/2018 19:56, Trond Myklebust wrote:
> > > > On Thu, 2018-11-29 at 19:28 +0000, Cristian Marussi wrote:
> > > > Question to you both: when this happens, does /proc/*/stack show
> > > > any of the processes hanging in the socket or sunrpc code? If
> > > > so, can you please send me examples of those stack traces (i.e.
> > > > the contents of /proc/<pid>/stack for the processes that are
> > > > hanging)
> > > 
> > > (using a reverse shell since starting ssh causes a lot of pain and
> > > traffic)
> > > 
> > > Looking at NFS traffic holes(30-40 secs) to detect Client side
> > > various HANGS
> 
> Chuck and I have identified a few issues that might have an effect on
> the hangs you report. Could you please give the linux-next branch in my
> repository on git.linux-nfs.org (
> https://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/linux-next
> ) a try?
> 
> git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next

I tried, unfortunately there's no difference for me (I merged the above
branch on top of 4.20-rc5).

-- 
Catalin
