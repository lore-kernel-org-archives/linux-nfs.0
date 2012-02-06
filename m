Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:56315
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751324Ab2BFRrr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Feb 2012 12:47:47 -0500
Date: Mon, 6 Feb 2012 12:47:43 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Steve Dickson <steved@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 1/2] SUNRPC: Add trace events to the sunrpc subsystem
Message-ID: <20120206174742.GA10427@infradead.org>
References: <1328540888-30109-1-git-send-email-steved@redhat.com>
 <1328540888-30109-2-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328540888-30109-2-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	TP_STRUCT__entry(
> +		__field(const struct rpc_clnt *, clnt)
> +		__field(const struct rpc_task *, task)
> +		__field(const void *, action)
> +		__field(unsigned long, runstate)
> +		__field(int, status)
> +		__field(unsigned short, flags)

Storing pointers in the trace buffer is not safe for reuse later,
and just printing the pointer values isn't overly useful either.  Please
redesign these tracepoint to be a bit more useful.

