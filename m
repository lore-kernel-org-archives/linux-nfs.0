Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58994 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751850AbdK2WXm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 29 Nov 2017 17:23:42 -0500
Date: Wed, 29 Nov 2017 17:23:41 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@kernel.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org
Subject: Re: [PATCH 0/4] lockd refcount conversions
Message-ID: <20171129222341.GB3923@fieldses.org>
References: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1511954146-11793-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying all four for 4.16.--b.

On Wed, Nov 29, 2017 at 01:15:42PM +0200, Elena Reshetova wrote:
> This series, for lockd component, replaces atomic_t reference
> counters with the new refcount_t type and API (see include/linux/refcount.h).
> By doing this we prevent intentional or accidental
> underflows or overflows that can led to use-after-free vulnerabilities.
> 
> The patches are fully independent and can be cherry-picked separately.
> If there are no objections to the patches, please merge them via respective tree.
> 
> Elena Reshetova (4):
>   lockd: convert nlm_host.h_count from atomic_t to refcount_t
>   lockd: convert nsm_handle.sm_count from atomic_t to refcount_t
>   lockd: convert nlm_lockowner.count from atomic_t to refcount_t
>   lockd: convert nlm_rqst.a_count from atomic_t to refcount_t
> 
>  fs/lockd/clntproc.c         | 14 +++++++-------
>  fs/lockd/host.c             | 16 ++++++++--------
>  fs/lockd/mon.c              | 14 +++++++-------
>  fs/lockd/svcproc.c          |  2 +-
>  include/linux/lockd/lockd.h |  9 +++++----
>  5 files changed, 28 insertions(+), 27 deletions(-)
> 
> -- 
> 2.7.4
