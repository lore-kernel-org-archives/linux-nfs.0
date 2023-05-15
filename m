Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51B83C77B7D
	for <linux-nfs@archiver.kernel.org>; Mon, 15 May 2023 17:00:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243497AbjEORAI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 May 2023 13:00:08 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:40734 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S243371AbjEOQ7r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 May 2023 12:59:47 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C77627EC2
        for <linux-nfs@vger.kernel.org>; Mon, 15 May 2023 09:59:33 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 3B5F962A5D
        for <linux-nfs@vger.kernel.org>; Mon, 15 May 2023 16:59:33 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4CC98C433D2;
        Mon, 15 May 2023 16:59:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1684169972;
        bh=559wN/Gt0x6vxUnexaeRH9mxVksh6kGYNcZLQ1krA1A=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=U8NptptxrOnB0XMuGmYv7z8XLjhq2NpYY7tqQUSJDH/TbIYWJ1y47n1Sxpc87wKDT
         X/nv+oEbTjek2fcR/4jOzCmYOJZGjMQKZPutfYOUB7RWn+7jb2Pis6oE8mW+Ig+C6r
         y+6TAimMui/jTdBntgCLWRzYFQRPVI5hQJ0tVRNUjSfIz19AUTfQgzSxxK2gWdmPJi
         ++/4xPNPbeMowP1JfnGXDh5N4EIZzrJ4VZBVTewt9MsLM6RaDNU782GMxAZ2dqWsrb
         kTY88D8ZPcFCKolBWm001/2hCvtySa3YK/5SuHlCOCcgcNowzOncFyZHB3wHDi4Zp9
         lrxU/KIqG0Qvg==
Message-ID: <f85e6aec6e94362abbfd58d9b34864d9d3545818.camel@kernel.org>
Subject: Re: [PATCH 0/3] NFSD admin interface observability
From:   Jeff Layton <jlayton@kernel.org>
To:     Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 15 May 2023 12:59:31 -0400
In-Reply-To: <168415762168.9589.16821927887100606727.stgit@manet.1015granger.net>
References: <168415762168.9589.16821927887100606727.stgit@manet.1015granger.net>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.48.1 (3.48.1-1.fc38) 
MIME-Version: 1.0
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, 2023-05-15 at 09:35 -0400, Chuck Lever wrote:
> I added new tracepoints while looking into the
> svc_tcp_listen_data_ready() bug and proposed fix. I thought these
> might be generally helpful. I'd like to apply these to nfsd-next.
>=20
> ---
>=20
> Chuck Lever (3):
>       NFSD: Clean up nfsctl white-space damage
>       NFSD: Clean up nfsctl_transaction_write()
>       NFSD: trace nfsctl operations
>=20
>=20
>  fs/nfsd/nfsctl.c |  83 +++++++++------
>  fs/nfsd/trace.h  | 259 +++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 309 insertions(+), 33 deletions(-)
>=20
> --
> Chuck Lever
>=20

Usually not crazy about whitespace patches, but OK, just this once.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
