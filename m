Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:57925 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757989Ab0KRPFR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 10:05:17 -0500
Subject: Re: [PATCH 3/3] NFS return an rpc auth error on back channel
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTin7frm3PDAD-iU=G==COQJL3NQCaxY6dsT6pwi=@mail.gmail.com>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
	 <1289964990-4480-2-git-send-email-andros@netapp.com>
	 <1289964990-4480-3-git-send-email-andros@netapp.com>
	 <1289964990-4480-4-git-send-email-andros@netapp.com>
	 <1290036369.3070.22.camel@heimdal.trondhjem.org>
	 <AANLkTin7frm3PDAD-iU=G==COQJL3NQCaxY6dsT6pwi=@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 18 Nov 2010 10:05:10 -0500
Message-ID: <1290092710.3187.28.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-11-18 at 09:42 -0500, William A. (Andy) Adamson wrote:
> On Wed, Nov 17, 2010 at 6:26 PM, Trond Myklebust
> <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2010-11-16 at 22:36 -0500, andros@netapp.com wrote:
> >
> > In NFSv4.0, you basically want to set the nfs_client in
> > nfs_callback_compound() (using the server's address and the
> > 'callback_ident' argument).
> 
> And if the nfs_client is not found should we SVC_DROP the request?
> NFS4ERR_BADHANDLE?

We can still drop the request in nfs4_callback_compound().

> >
> > In NFSv4.1, you need to set it in the OP_SEQUENCE decode callback, but
> > there you need to be returning NFS4ERR_BADSESSION and/or
> > NFS4ERR_CONN_NOT_BOUND_TO_SESSION anyway...
> 
> I don't see the difference between not finding the proper nfs_client
> in the pg_authenticate method and not finding it after decode in
> CB_SEQUENCE.

In the NFSv4.1 case, the client callback server knows that the
connection is valid, 'cos we're the ones who set it up. All we care
about is to make sure the session is still valid. If it isn't, then
NFS4ERR_BADSESSION is the correct reply.

NFSv4.0 is an altogether different kettle of fish since we need to
authenticate the connection too.

Trond

