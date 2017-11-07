Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48718 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751931AbdKGUrD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Nov 2017 15:47:03 -0500
Date: Tue, 7 Nov 2017 15:47:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/7] Tighten up locking around stateids in knfsd
Message-ID: <20171107204702.GF24262@fieldses.org>
References: <20171103120016.6200-1-trond.myklebust@primarydata.com>
 <20171107200616.GE24262@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171107200616.GE24262@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 07, 2017 at 03:06:16PM -0500, J. Bruce Fields wrote:
> What tree are these patches against?

Never mind, there were just some minor conflicts against the refcount
patches.

--b.
