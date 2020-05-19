Return-Path: <SRS0=FnX5=7B=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07333C433DF
	for <linux-nfs@archiver.kernel.org>; Tue, 19 May 2020 21:29:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D94C92072C
	for <linux-nfs@archiver.kernel.org>; Tue, 19 May 2020 21:29:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728129AbgESV3j (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 May 2020 17:29:39 -0400
Received: from fieldses.org ([173.255.197.46]:45608 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725998AbgESV3j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 May 2020 17:29:39 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id ACA27621B; Tue, 19 May 2020 17:29:38 -0400 (EDT)
Date:   Tue, 19 May 2020 17:29:38 -0400
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v2 00/29] Possible NFSD patches for v5.8
Message-ID: <20200519212938.GG25858@fieldses.org>
References: <20200512211640.5826.77139.stgit@klimt.1015granger.net>
 <20200519161108.GD25858@fieldses.org>
 <81E97D7E-7B8D-4C64-844A-18EF0346C49C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81E97D7E-7B8D-4C64-844A-18EF0346C49C@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, May 19, 2020 at 12:14:22PM -0400, Chuck Lever wrote:
> 
> 
> > On May 19, 2020, at 12:11 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > I'm getting a repeatable timeout failure on python 4.0 test WRT15.  In
> > pynfs, run: 
> > 
> > 	./nfs4.0/testserver.py server:/export/path --rundeps --maketree WRT15
> > 
> > Looks like it sends WRITE+GETATTR(FATTR4_SIZE) compounds with write
> > offset 0 and write length taking on every value from 0 to 8192.
> > 
> > Probably an xdr decoding bug of some kind?
> 
> My first thought is to bisect, but I don't see a particular change in my
> v5.8 series that would plausibly introduce this class of problem.

It's SUNRPC: Refactor svc_recvfrom().

That was just from a quick automated bisect.  I haven't tried to figure
out where the bug is....

--b.
