Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34514 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753866AbcFPOwt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2016 10:52:49 -0400
Received: by mail-yw0-f171.google.com with SMTP id c72so44824274ywb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2016 07:52:49 -0700 (PDT)
From: Weston Andros Adamson <dros@monkey.org>
Content-Type: text/plain; charset=utf-8
Subject: flexfiles LAYOUTGET/LAYOUTRETURN loop
Date: Thu, 16 Jun 2016 10:52:44 -0400
Message-Id: <54992BAB-C388-4CA6-9713-D8CA09BE3E37@monkey.org>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
To: Anna.Schumaker@netapp.com, Trond Myklebust <trondmy@primarydata.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Trond, Anna,

The following patches should be CC’d to stable for all stable branches
with flexfiles.

They fix an issue where the client can use the wrong credential if the
server returns a read-only and readwrite layout with different creds.
The client then goes into a LAYOUTRETURN/LAYOUTGET loop that
it never recovers from.

This has been seen in recent fedora releases.

Here are the relevant patches:

commit 3064b6861d00b7124558cdf79f9387f948361be3
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:52:00 2016 -0400

   nfs: have flexfiles mirror keep creds for both ro and rw layouts

commit 90a0be00e9d29d9baac27c0c63a5e71ca1334001
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:51:59 2016 -0400

   nfs: get a reference to the credential in ff_layout_alloc_lseg

commit 57f3f4c0cd50e90aa92eec20d9c309dd67c594a5
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:51:58 2016 -0400

   nfs: have ff_layout_get_ds_cred take a reference to the cred

commit 547a637630c61b9e1dae9abce2b44ce7076244af
Author: Jeff Layton <jlayton@poochiereds.net>
Date:   Thu Apr 21 20:51:57 2016 -0400

   nfs: don't call nfs4_ff_layout_prepare_ds from ff_layout_get_ds_cred


-dros

