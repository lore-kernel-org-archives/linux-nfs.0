Return-Path: <SRS0=29O7=R4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27854C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:13:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F06032080F
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Mar 2019 23:13:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727413AbfCYXNw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Mar 2019 19:13:52 -0400
Received: from fieldses.org ([173.255.197.46]:56078 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727192AbfCYXNw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Mar 2019 19:13:52 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id C921F1C81; Mon, 25 Mar 2019 19:13:51 -0400 (EDT)
Date:   Mon, 25 Mar 2019 19:13:51 -0400
To:     Ted Carpenter <ted@qumulo.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: Collapsing I/O size with unstable writes with NFSv3 on 4.15
Message-ID: <20190325231351.GA23190@fieldses.org>
References: <CABu8kFdbzgEnoWh595+ODPt4cTaWryO9OR9fKVB68z+tfbNaCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABu8kFdbzgEnoWh595+ODPt4cTaWryO9OR9fKVB68z+tfbNaCA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Mar 20, 2019 at 08:47:32AM -0700, Ted Carpenter wrote:
> I'm testing performance of a clustered NFS server using a 4.15 client.
> My test setup involves running IOZone to write a 30GB file to the
> server over NFSv3. The issue is that we occasionally see bad
> performance, especially when unstable writes are enabled on the
> server.

Which server, and how do you enable unstable writes?

> Based on observing the network traffic, we've seen the write I/O size
> during good runs stay around 1MB (which is how we've mounted) but in
> the bad runs we see often see dips in write size (down to even 4KB or
> 8KB) towards the end of the test.
> 
> I'm trying to understand why we see the dip in I/O size from the NFS
> client as it seems to be related to the decrease in performance. Any
> ideas what could cause it? Also, any suggestions on where I should
> look to start learning about the way the Linux NFS client and page
> cache handle unstable writes internally?

I'm not sure what to recommend.  We might also need some more details
about the performance results you're seeing.

--b.
