Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 080E8C4332F
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Nov 2022 15:18:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237186AbiKNPST (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Nov 2022 10:18:19 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44122 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237171AbiKNPSS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2022 10:18:18 -0500
Received: from sin.source.kernel.org (sin.source.kernel.org [IPv6:2604:1380:40e1:4800::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4F15C19010;
        Mon, 14 Nov 2022 07:18:17 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by sin.source.kernel.org (Postfix) with ESMTPS id 68851CE10FF;
        Mon, 14 Nov 2022 15:18:15 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0010BC433D6;
        Mon, 14 Nov 2022 15:18:12 +0000 (UTC)
Date:   Mon, 14 Nov 2022 10:18:54 -0500
From:   Steven Rostedt <rostedt@goodmis.org>
To:     Chuck Lever III <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v1] trace: Relocate event helper files
Message-ID: <20221114101854.35bd75c4@gandalf.local.home>
In-Reply-To: <C11D5606-4432-4FBC-8754-CA49832D172F@oracle.com>
References: <166843574651.160660.16747506894761495587.stgit@klimt.1015granger.net>
        <20221114100307.6abba30a@gandalf.local.home>
        <C11D5606-4432-4FBC-8754-CA49832D172F@oracle.com>
X-Mailer: Claws Mail 3.17.8 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 14 Nov 2022 15:13:56 +0000
Chuck Lever III <chuck.lever@oracle.com> wrote:

> > Probably needs to be updated in the Documentation/trace/events.rst?  
> 
> That file seems to be a user's guide, not a programmer's guide.

Good point. Perhaps its time to make a events-howto.rst document, that can
use the input from the samples/trace_events/ directory.

-- Steve
