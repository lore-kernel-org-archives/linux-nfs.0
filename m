Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B5CDC4332F
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Nov 2022 15:01:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236681AbiKNPBn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Nov 2022 10:01:43 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33710 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236152AbiKNPBi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2022 10:01:38 -0500
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 348651F639;
        Mon, 14 Nov 2022 07:01:37 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id E0D6EB80F99;
        Mon, 14 Nov 2022 15:01:35 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 164DAC433D6;
        Mon, 14 Nov 2022 15:01:33 +0000 (UTC)
Date:   Mon, 14 Nov 2022 10:02:14 -0500
From:   Steven Rostedt <rostedt@goodmis.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v1] trace: Relocate event helper files
Message-ID: <20221114100214.55848d8c@gandalf.local.home>
In-Reply-To: <166843574651.160660.16747506894761495587.stgit@klimt.1015granger.net>
References: <166843574651.160660.16747506894761495587.stgit@klimt.1015granger.net>
X-Mailer: Claws Mail 3.17.8 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 14 Nov 2022 09:36:39 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

>  drivers/infiniband/core/cm_trace.h  |    2 
>  drivers/infiniband/core/cma_trace.h |    2 
>  fs/nfs/nfs4trace.h                  |    6 -
>  fs/nfs/nfstrace.h                   |    6 -
>  include/trace/events/fs.h           |  122 -----------
>  include/trace/events/nfs.h          |  375 -----------------------------------
>  include/trace/events/rdma.h         |  168 ----------------
>  include/trace/events/rpcgss.h       |    2 
>  include/trace/events/rpcrdma.h      |    4 
>  include/trace/events/sunrpc.h       |    2 
>  include/trace/events/sunrpc_base.h  |   18 --
>  include/trace/include/fs.h          |  122 +++++++++++
>  include/trace/include/nfs.h         |  375 +++++++++++++++++++++++++++++++++++
>  include/trace/include/rdma.h        |  168 ++++++++++++++++
>  include/trace/include/sunrpc.h      |   18 ++

I'm not so sure I like the "include/trace/include" name. But kernel
developers are known for sucky naming conventions :-p

How about one of:

  include/trace/linux/
  include/trace/misc/
  include/trace/ext/
  include/trace/helpers/

?

-- Steve
