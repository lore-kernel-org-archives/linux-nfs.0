Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54904 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751500AbdLFT1E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Dec 2017 14:27:04 -0500
Date: Wed, 6 Dec 2017 14:27:04 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thiago Rafael Becker <thiago.becker@gmail.com>
Cc: neilb@suse.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3 v3] Move groups_sort outisde of set_groups
Message-ID: <20171206192704.GA27019@fieldses.org>
References: <20171130130457.11429-1-thiago.becker@gmail.com>
 <20171205140512.13349-1-thiago.becker@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20171205140512.13349-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

ACK to these patches from me.  I'm not sure who should pick them up....

--b.

On Tue, Dec 05, 2017 at 12:05:09PM -0200, Thiago Rafael Becker wrote:
> In cases where group_info is cached (e.g. sunrpc), multiplpe
> threads may call set_groups with a freshly created group_info
> cache (e.g. nfsd), and attempt to sort them simultaneously,
> which configures a race condition that can overwrite some
> groups in the cache and lead to errors. In the case of nfsd,
> the client was receiving EPERM if the group used to provide
> authorization was overwritten by this race condition.
> 
> In an email exchange with bfields, we agreed that it seems
> unintuitive that the groups are sorted on set_groups, and that
> it would be better to move the responsibility of sorting to
> the caller of set_groups.
> 
> These patches:
>  - Export groups_sort in include/linux/cred.h
>  - Add a call to groups_sort after the groups are inserted in
>    group_info
>  - Remove the call to sort_groups from set_groups
> 
> Thiago Rafael Becker (3):
>   kernel: make groups_sort globally visible
>   kernel: Move groups_sort to the caller of set_groups.
>   kernel: set_groups doesn't call groups_sort anymore.
> 
>  include/linux/cred.h      | 1 +
>  kernel/groups.c           | 6 ++++--
>  kernel/uid16.c            | 1 +
>  net/sunrpc/svcauth_unix.c | 7 +++++++
>  4 files changed, 13 insertions(+), 2 deletions(-)
> 
> -- 
> 2.9.5
