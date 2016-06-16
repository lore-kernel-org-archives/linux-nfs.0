Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:34778 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbcFPPIx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 11:08:53 -0400
Received: by mail-yw0-f172.google.com with SMTP id c72so45300149ywb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2016 08:08:52 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: flexfiles LAYOUTGET/LAYOUTRETURN loop
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <41FA6F5E-E288-4FE4-B748-E17A854E2551@primarydata.com>
Date: Thu, 16 Jun 2016 11:08:40 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <DDEED441-981A-4D6A-B867-4AD2FF5708B1@monkey.org>
References: <54992BAB-C388-4CA6-9713-D8CA09BE3E37@monkey.org> <41FA6F5E-E288-4FE4-B748-E17A854E2551@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 16, 2016, at 10:56 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> 
> > On Jun 16, 2016, at 10:52, Weston Andros Adamson <dros@monkey.org> wrote:
> > 
> > Hey Trond, Anna,
> > 
> > The following patches should be CC’d to stable for all stable branches
> > with flexfiles.
> > 
> > They fix an issue where the client can use the wrong credential if the
> > server returns a read-only and readwrite layout with different creds.
> > The client then goes into a LAYOUTRETURN/LAYOUTGET loop that
> > it never recovers from.
> > 
> > This has been seen in recent fedora releases.
> > 
> > Here are the relevant patches:
> > 
> > commit 3064b6861d00b7124558cdf79f9387f948361be3
> > Author: Jeff Layton <jlayton@poochiereds.net>
> > Date: Thu Apr 21 20:52:00 2016 -0400
> > 
> > nfs: have flexfiles mirror keep creds for both ro and rw layouts
> > 
> > commit 90a0be00e9d29d9baac27c0c63a5e71ca1334001
> > Author: Jeff Layton <jlayton@poochiereds.net>
> > Date: Thu Apr 21 20:51:59 2016 -0400
> > 
> > nfs: get a reference to the credential in ff_layout_alloc_lseg
> > 
> > commit 57f3f4c0cd50e90aa92eec20d9c309dd67c594a5
> > Author: Jeff Layton <jlayton@poochiereds.net>
> > Date: Thu Apr 21 20:51:58 2016 -0400
> > 
> > nfs: have ff_layout_get_ds_cred take a reference to the cred
> > 
> > commit 547a637630c61b9e1dae9abce2b44ce7076244af
> > Author: Jeff Layton <jlayton@poochiereds.net>
> > Date: Thu Apr 21 20:51:57 2016 -0400
> > 
> > nfs: don't call nfs4_ff_layout_prepare_ds from ff_layout_get_ds_cred
> > 
> > 
> > -dros
> > 
> 
> Those are already applied upstream afaics, so we can’t add any Ccs. If they need to go to stable, then someone has to submit them directly.

Oh, right. I’ll take care of it.

-dros

