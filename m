Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54632 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752498AbdJTS71 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 14:59:27 -0400
Date: Fri, 20 Oct 2017 14:59:27 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Elena Reshetova <elena.reshetova@intel.com>
Cc: trond.myklebust@primarydata.com, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, anna.schumaker@netapp.com,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org
Subject: Re: [PATCH 00/11] nfs refcount conversions
Message-ID: <20171020185927.GD15211@fieldses.org>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 20, 2017 at 12:53:27PM +0300, Elena Reshetova wrote:
> This series, for nfs components, replaces atomic_t reference
> counters with the new refcount_t type and API (see include/linux/refcount.h).
> By doing this we prevent intentional or accidental
> underflows or overflows that can led to use-after-free vulnerabilities.
> 
> The patches are fully independent and can be cherry-picked separately.
> If there are no objections to the patches, please merge them via respective trees.
> 
> Rebased on top of linux-next.
> 
> Elena Reshetova (11):
>   fs, nfsd: convert nfs4_stid.sc_count from atomic_t to refcount_t
>   fs, nfsd: convert nfs4_cntl_odstate.co_odcount from atomic_t to
>     refcount_t
>   fs, nfsd: convert nfs4_file.fi_ref from atomic_t to refcount_t

Thanks, applying for 4.15.

I haven't followed recent discussion on the refcount api, but I assume
the consensus is to do this, and these particular conversions certainly
look trivial enough.

--b.
