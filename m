Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58204 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726279AbeJDHw2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 03:52:28 -0400
Date: Wed, 3 Oct 2018 21:01:40 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 0/4] NFS/RDMA server patches for v4.20
Message-ID: <20181004010140.GO17517@fieldses.org>
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 01, 2018 at 02:15:50PM -0400, Chuck Lever wrote:
> These four patches are ready for you to consider for the next merge
> window. There are three clean up patches, and one patch to increase
> the server's credit grant to the default size of the Linux client's
> NFSv4.1 session slot table. I've measured modest performance
> increases with this change.

Thanks, added Sagi Grimberg's Reviewed-by's and applied.

--b.
