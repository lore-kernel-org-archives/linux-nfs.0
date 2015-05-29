Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f48.google.com ([209.85.218.48]:34070 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756081AbbE2PqO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2015 11:46:14 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQbKvkG_FdFX+3cd1s2VsrE8FUK4beAn6BsK9Dt1hLQsw@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<4bf77d045d2bd3494c695229cd0505b7002cc9a2.1429868795.git.agruenba@redhat.com>
	<CAHQdGtQbKvkG_FdFX+3cd1s2VsrE8FUK4beAn6BsK9Dt1hLQsw@mail.gmail.com>
Date: Fri, 29 May 2015 17:46:14 +0200
Message-ID: <CAHpGcMLwEuhyQyy2DwX7mfdmyCt+ZBW9KpiFLEiKXNtvp0dByg@mail.gmail.com>
Subject: Re: [RFC v3 41/45] rpc: Allow to demand-allocate pages to encode into
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-29 1:24 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> xdr_get_next_encode() should return NULL on failure, not ENOMEM.
> Why is this trying to do a GFP_KERNEL allocation inside an XDR routine
> anyway? That's not an I/O safe sleep.

Fixed, thanks.

Andreas
