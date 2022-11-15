Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C2A4C433FE
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Nov 2022 14:26:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229665AbiKOO0C (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Nov 2022 09:26:02 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48200 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229556AbiKOO0B (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Nov 2022 09:26:01 -0500
Received: from sin.source.kernel.org (sin.source.kernel.org [145.40.73.55])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E8EB32AC5;
        Tue, 15 Nov 2022 06:25:59 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by sin.source.kernel.org (Postfix) with ESMTPS id 5E063CE1754;
        Tue, 15 Nov 2022 14:25:58 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1E86AC433D7;
        Tue, 15 Nov 2022 14:25:56 +0000 (UTC)
Date:   Tue, 15 Nov 2022 09:26:38 -0500
From:   Steven Rostedt <rostedt@goodmis.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] trace: Relocate event helper files
Message-ID: <20221115092638.62cb7322@gandalf.local.home>
In-Reply-To: <166843895843.170837.8663873976042560070.stgit@klimt.1015granger.net>
References: <166843895843.170837.8663873976042560070.stgit@klimt.1015granger.net>
X-Mailer: Claws Mail 3.17.8 (GTK+ 2.24.33; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 14 Nov 2022 10:16:12 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> Steven Rostedt says:
> > The include/trace/events/ directory should only hold files that
> > are to create events, not headers that hold helper functions.
> >
> > Can you please move them out of include/trace/events/ as that
> > directory is "special" in the creation of events.  
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
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
>  include/trace/misc/fs.h             |  122 +++++++++++
>  include/trace/misc/nfs.h            |  375 +++++++++++++++++++++++++++++++++++
>  include/trace/misc/rdma.h           |  168 ++++++++++++++++
>  include/trace/misc/sunrpc.h         |   18 ++
>  15 files changed, 695 insertions(+), 695 deletions(-)
>  delete mode 100644 include/trace/events/fs.h
>  delete mode 100644 include/trace/events/nfs.h
>  delete mode 100644 include/trace/events/rdma.h
>  delete mode 100644 include/trace/events/sunrpc_base.h
>  create mode 100644 include/trace/misc/fs.h
>  create mode 100644 include/trace/misc/nfs.h
>  create mode 100644 include/trace/misc/rdma.h
>  create mode 100644 include/trace/misc/sunrpc.h
> 
> Note: with an Acked-by from both the NFS client and RDMA core
> maintainers I can take this through the nfsd for-next tree, unless
> someone has another suggestion.

Acked-by: Steven Rostedt (Google) <rostedt@goodmis.org>

-- Steve
