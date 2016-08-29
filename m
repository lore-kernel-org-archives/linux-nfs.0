Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:20403 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756324AbcH2R6I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2016 13:58:08 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Jason L Tibbitts III <tibbs@math.uh.edu>
CC: Oleg Drokin <green@linuxhacker.ru>,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix infinite looping in
 rpc_clnt_iterate_for_each_xprt
Date: Mon, 29 Aug 2016 17:57:03 +0000
Message-ID: <3D1D3C7A-EE3D-46DA-8F90-919B2F7A2F3F@primarydata.com>
References: <1468685090-5513-1-git-send-email-trond.myklebust@primarydata.com>
 <ufah9a3wmds.fsf@epithumia.math.uh.edu>
In-Reply-To: <ufah9a3wmds.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 29, 2016, at 12:49, Jason L Tibbitts III <tibbs@math.uh.edu> wrote=
:
>=20
> I have found (with Chuck's help) that this patch appears to fix an issue
> I've been struggling with for the past couple of weeks, where my clients
> will just hammer the server with BIND_CONN_TO_SESSION requests endlessly
> until the server dies from OOM.  Really, Chuck found the patch and all I
> did was apply it locally.  At least that issue hasn't reoccurred so far.
>=20
> The server probably shouldn't die from a confused client, but that's a
> separate issue.
>=20
> However, this patch isn't tagged for stable.  Would you consider
> submitting it there?  I'm hoping that Fedora will integrate it locally
> but I think it would be of more general use.


Feel free to submit it to stable@vger.kernel.org=85

Cheers,
  Trond

