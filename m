Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E86A9C433FE
	for <linux-nfs@archiver.kernel.org>; Sat, 12 Nov 2022 12:27:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231404AbiKLM1t (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 12 Nov 2022 07:27:49 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50636 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231338AbiKLM1s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2022 07:27:48 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8DB531929C;
        Sat, 12 Nov 2022 04:27:47 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 39554B80315;
        Sat, 12 Nov 2022 12:27:46 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6357EC433D6;
        Sat, 12 Nov 2022 12:27:44 +0000 (UTC)
Date:   Sat, 12 Nov 2022 07:27:42 -0500
From:   Steven Rostedt <rostedt@goodmis.org>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
Cc:     LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Files in include/trace/events
Message-ID: <20221112072742.065df70a@rorschach.local.home>
X-Mailer: Claws Mail 3.17.8 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Chuck,

I was just looking over some files in include/trace/events/ and noticed
that there's sunrpc_base.h, fs.h and nfs.h that are not event files.

The include/trace/events/ directory should only hold files that are to
create events, not headers that hold helper functions.

Can you please move them out of include/trace/events/ as that directory
is "special" in the creation of events.

Perhaps we could create a new directory include/linux/trace/ or
include/trace/linux/ specific for these types of files?

Thanks!

-- Steve
