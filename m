Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:36730 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207AbcFPUBB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 16:01:01 -0400
From: Weston Andros Adamson <dros@monkey.org>
Content-Type: text/plain; charset=utf-8
Subject: nfs/flexfiles patches for stable
Date: Thu, 16 Jun 2016 16:00:55 -0400
Message-Id: <77CC4C9F-85C6-4E78-9ACA-11D4A67D1B9B@monkey.org>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@primarydata.com>,
        Anna.Schumaker@netapp.com
To: stable@vger.kernel.org
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following patches are already merged upstream, but should be
included in stable releases 4.5.y and 4.6.y.

They fix an issue where the client can use the wrong credential if the
server returns a read-only and readwrite layout with different creds.
The client then goes into a LAYOUTRETURN/LAYOUTGET loop that
it never recovers from.

This has been seen in recent fedora releases.

Here are the relevant patches:

commit 547a637630c61b9e1dae9abce2b44ce7076244af
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:51:57 2016 -0400

  nfs: don't call nfs4_ff_layout_prepare_ds from ff_layout_get_ds_cred

commit 57f3f4c0cd50e90aa92eec20d9c309dd67c594a5
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:51:58 2016 -0400

  nfs: have ff_layout_get_ds_cred take a reference to the cred

commit 90a0be00e9d29d9baac27c0c63a5e71ca1334001
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:51:59 2016 -0400

  nfs: get a reference to the credential in ff_layout_alloc_lseg

commit 3064b6861d00b7124558cdf79f9387f948361be3
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:52:00 2016 -0400

  nfs: have flexfiles mirror keep creds for both ro and rw layouts



linux-4.6.y: applies cleanly

linux-4.5.y: needs another patch to apply cleanly — and that patch looks pretty important too!

commit 849dc3244c916545790bfb9055625a3719061c92
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Wed Feb 24 15:28:29 2016 -0500

    nfs4: nfs4_ff_layout_prepare_ds should return NULL if connection failed


Thanks,

-dros

