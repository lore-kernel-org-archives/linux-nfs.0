Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61D42C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 15:44:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 133DA2080A
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 15:44:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 133DA2080A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729271AbeKAAmv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 20:42:51 -0400
Received: from fieldses.org ([173.255.197.46]:54622 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727623AbeKAAmv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 20:42:51 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id E3AD2249A; Wed, 31 Oct 2018 11:44:18 -0400 (EDT)
Date:   Wed, 31 Oct 2018 11:44:18 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Linus Torvalds <torvalds@linux-foundation.org>
Cc:     linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        jlayton@redhat.com
Subject: Re: [GIT PULL] nfsd changes for 4.20
Message-ID: <20181031154418.GB2451@fieldses.org>
References: <20181030191710.GA23042@fieldses.org>
 <CAHk-=wi+-POnmS41x9SKR+CB9va3ZnmRmCF8S7wNEw0QVATHXA@mail.gmail.com>
 <CAHk-=wgeJzBWjCafB3nKP0QMJCyh3rAjN+s6Z+T+5hfAT81YMw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wgeJzBWjCafB3nKP0QMJCyh3rAjN+s6Z+T+5hfAT81YMw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 30, 2018 at 01:06:58PM -0700, Linus Torvalds wrote:
> On Tue, Oct 30, 2018 at 12:55 PM Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > Pulled,
> 
> Oh, I take that back. Semantic conflict with locking name change
> (recv_lock -> queue_lock) and new code in
> 
>    net/sunrpc/xprtrdma/svc_rdma_backchannel.c
> 
> exposed by my build test.
> 
> And looking around, it was reported in linux-next, but you didn't
> mention it, which kind of makes the whole reporting pointless.
> 
> Guys, what is the point of linux-next if you then don't *react* to it?
> The correct reaction is to say during the merge window that "hey,
> linux-next showed this issue", just so that I know about it and it
> doesn't take me by surprise.
> 
> Yes, my normal build tests caught it, and I've fixed up my merge, but
> this isn't how things are supposed to work.

Apologies, thanks for the correction.

I see Stephen Rothwell's message from October 5.  I think at the time I
said "OK, looks minor, just something to mention in the pull request",
then forgot about it.

In future when that happens, I'll add some kind of reminder to my
request-pull script.

Stephen also sent a warning about a merge conflict with the vfs tree
(not merged yet, I think) but I assume that's not as big a deal since it
should actually show up at merge time, not build time:

	http://lkml.kernel.org/r/20181029122121.7758fed4@canb.auug.org.au

--b.
