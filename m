Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33036 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1954550AbdDYU4e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 25 Apr 2017 16:56:34 -0400
Date: Tue, 25 Apr 2017 16:56:33 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Colin King <colin.king@canonical.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] lockd: remove redundant check on block
Message-ID: <20170425205633.GC15279@fieldses.org>
References: <20170408170959.19805-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170408170959.19805-1-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 08, 2017 at 06:09:59PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> A null check followed by a return is being performed already, so block
> is always non-null at the second check on block, hence we can remove
> this redundant null-check (Detected by PVS-Studio).  Also re-work
> comment to clean up a check-patch warning.

Thanks, applying for 4.12.--b.
