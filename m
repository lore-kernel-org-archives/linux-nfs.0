Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51290 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753232AbcIITxi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 15:53:38 -0400
Date: Fri, 9 Sep 2016 15:53:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5] NFSD: Add support for the COPY operation
Message-ID: <20160909195336.GA25490@fieldses.org>
References: <20160907195730.26480-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160907195730.26480-1-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 07, 2016 at 03:57:29PM -0400, Anna Schumaker wrote:
> This patch adds server support for the NFS v4.2 COPY operation.  I did some
> performance testing on my own, and found that a 4MB copy cap has performance
> pretty close to copying with no cap at all.  Here are my results for testing
> with various file sizes and copy caps:

Thanks, but we expect the tradeoffs here to vary a lot depending on the
latency of the client<->server connection and the server<->server copy
bandwidth.  So this isn't really interesting without knowing your
testing setup.

--b.

> 
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |NFSv4.1|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
> |system |   0.28s |   0.48s |   0.72s |   0.94s |   1.17s |   1.42s |   2.37s |
> |cpu    |     18% |     14% |     14% |     14% |     14% |     13% |     13% |
> |total  |  1.547s |  3.269s |  5.040s |  6.690s |  8.363s | 10.146s | 16.729s |
> |read   |   4096  |   8192  |  12288  |  16384  |  20480  |  24576  |  40960  |
> |write  |   4098  |   8203  |  12302  |  16402  |  20497  |  24668  |  40996  |
> |commit |      9  |     18  |     27  |     36  |     46  |     55  |     93  |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> 
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |No Cap |  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
> |system |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
> |cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
> |total  |  1.476s |  3.068s |  4.569s |  6.123s |  7.701s |  9.265s | 15.438s |
> |copy   |      1  |      1  |      1  |      2  |      2  |      2  |      3  |
> |commit |      1  |      1  |      1  |      2  |      2  |      2  |      3  |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> 
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |1MB Cap|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
> |system |   0.01s |   0.02s |   0.03s |   0.04s |   0.05s |   0.07s |   0.10s |
> |cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
> |total  |  1.659s |  3.118s |  4.930s |  6.647s |  8.110s |  9.637s | 16.030s |
> |copy   |    512  |   1024  |   1536  |   2048  |   2560  |   3072  |   5120  |
> |commit |    512  |   1024  |   1536  |   2048  |   2560  |   3072  |   5120  |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> 
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |2MB Cap|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
> |system |   0.01s |   0.01s |   0.02s |   0.03s |   0.03s |   0.04s |   0.07s |
> |cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
> |total  |  1.757s |  3.351s |  4.791s |  6.522s |  8.090s |  9.594s | 15.977s |
> |copy   |    256  |    512  |    768  |   1024  |   1280  |   1536  |   2560  |
> |commit |    256  |    512  |    768  |   1024  |   1280  |   1536  |   2560  |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> 
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |4MB Cap|  512 MB | 1024 MB | 1536 MB | 2048 MB | 2560 MB | 3072 MB | 5120 MB |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> |user   |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |   0.00s |
> |system |   0.00s |   0.01s |   0.01s |   0.01s |   0.02s |   0.02s |   0.04s |
> |cpu    |      0% |      0% |      0% |      0% |      0% |      0% |      0% |
> |total  |  1.475s |  3.046s |  4.643s |  6.159s |  7.779s |  9.340s | 15.476s |
> |copy   |    128  |    256  |    384  |    512  |    640  |    768  |   1280  |
> |commit |    128  |    256  |    384  |    512  |    640  |    768  |   1280  |
> |-------|---------|---------|---------|---------|---------|---------|---------|
> 
> 
> Changes in v5:
> - Add an arbitrary 4MB copy cap
> 
> Anna Schumaker (1):
>   NFSD: Implement the COPY call
> 
>  fs/nfsd/nfs4proc.c | 90 +++++++++++++++++++++++++++++++++++++++++++++++-------
>  fs/nfsd/nfs4xdr.c  | 63 ++++++++++++++++++++++++++++++++++++--
>  fs/nfsd/vfs.c      |  8 +++++
>  fs/nfsd/vfs.h      |  2 ++
>  fs/nfsd/xdr4.h     | 23 ++++++++++++++
>  5 files changed, 173 insertions(+), 13 deletions(-)
> 
> -- 
> 2.9.3
