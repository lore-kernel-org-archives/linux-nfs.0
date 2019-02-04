Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BC0AC282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:37:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0A8102087C
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:37:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726585AbfBDThq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 14:37:46 -0500
Received: from fieldses.org ([173.255.197.46]:51752 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726533AbfBDThq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 14:37:46 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 504A51E3A; Mon,  4 Feb 2019 14:37:45 -0500 (EST)
Date:   Mon, 4 Feb 2019 14:37:45 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        simo@redhat.com
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Message-ID: <20190204193745.GB1816@fieldses.org>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <20190202170258.GA14074@infradead.org>
 <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
 <20190204075336.GA28337@infradead.org>
 <0EB44600-7CF7-45C3-A1AB-75B76EFA1546@oracle.com>
 <20190204143239.GA15081@infradead.org>
 <7532348A-4059-4435-9D87-291902148681@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7532348A-4059-4435-9D87-291902148681@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 04, 2019 at 09:56:20AM -0500, Chuck Lever wrote:
> 
> 
> > On Feb 4, 2019, at 9:32 AM, Christoph Hellwig <hch@infradead.org> wrote:
> > 
> > On Mon, Feb 04, 2019 at 09:16:54AM -0500, Chuck Lever wrote:
> >> They are. The problem is that we are byte-swapping the incoming wire
> >> data and then comparing to CPU-endian constants in some hot paths.
> >> It's better to leave the incoming data alone and compare to a pre-
> >> byte-swapped constant. This patch adds some of these constants that
> >> were missing, in preparation for fixing the hot paths.
> >> 
> >> That is apparently not clear from the patch description, so I will
> >> endeavor to improve it.
> > 
> > Why do we need new enums / #defines for that?
> > 
> > Just replace:
> > 
> > 	if (beXX_to_cpu(pkt->field) == SOME_CONSTANT)
> > 
> > with
> > 
> > 	if (pkt->field == cpu_to_be32(SOME_CONSTANT))
> > 
> > and we are done.
> 
> True.

I'm a little surprised the compiler couldn't do that automatically.
(Disclaimer: I know nothing about compilers.)

> > The latter is a pretty common pattern through the kernel.
> 
> However the pattern in the NFS server and lockd is to define a
> lower-case version of the same macro that is pre-byte-swapped.
> I'm attempting to follow existing precedent in this area.

I've never really understood why that was done.  (Not saying it was
wrong, just that I don't understand it.)  As long as you're reading the
value, how could byte-swapping it actually add a significant expense?

The one thing I do like is that I can look at e.g.:

	int nfsd4_get_nfs4_acl	...
	__be32 nfsd4_set_nfs4_acl ...

and tell that the former returns a linux errno, the latter an NFS error.

--b.

> 
> We already have, for example, in various sunrpc headers:
> 
> enum rpc_accept_stat {
>         RPC_SUCCESS = 0,
>         RPC_PROG_UNAVAIL = 1,
>         RPC_PROG_MISMATCH = 2,
>   ...
> };
> 
> #define rpc_success             cpu_to_be32(RPC_SUCCESS)
> #define rpc_prog_unavail        cpu_to_be32(RPC_PROG_UNAVAIL)
> #define rpc_prog_mismatch       cpu_to_be32(RPC_PROG_MISMATCH)
> 
> Or, for NFS:
> 
> enum nfs_stat {
>    ...
>    NFSERR_SHARE_DENIED = 10015,
>    ...
> };
> 
> #define nfserr_share_denied cpu_to_be32(NFSERR_SHARE_DENIED)
> 
> There are some missing lower-case macros, which I am trying to
> add to our existing collection before I rewrite the RPC header
> encoding and decoding functions. So I'm adding:
> 
> +       rpc_gss_version = cpu_to_be32(RPC_GSS_VERSION),
> 
> +       rpc_call                = cpu_to_be32(RPC_CALL),
> +       rpc_reply               = cpu_to_be32(RPC_REPLY),
> +
> +       rpc_msg_accepted        = cpu_to_be32(RPC_MSG_ACCEPTED),
> +       rpc_msg_denied          = cpu_to_be32(RPC_MSG_DENIED),
> 
> Actually since we have decided not to use enum for these, this
> smaller addition can simply be squashed into the later patches,
> and I can drop this patch, which was intended as a clean-up but
> now appears to be unnecessary.
> 
> --
> Chuck Lever
> 
> 
