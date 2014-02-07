Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751319AbaBGTkb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Feb 2014 14:40:31 -0500
Message-ID: <52F5366D.9010300@redhat.com>
Date: Fri, 07 Feb 2014 14:39:25 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
To: Rafael Aquini <aquini@redhat.com>, linux-kernel@vger.kernel.org
CC: trond.myklebust@primarydata.com, jstancek@redhat.com, jlayton@redhat.com,
        mgorman@suse.de, linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
In-Reply-To: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 02/07/2014 10:19 AM, Rafael Aquini wrote:
> Changes committed by "a0b8cab3 mm: remove lru parameter from
> __pagevec_lru_add and remove parts of pagevec API" have introduced
> a call to add_to_page_cache_lru() which causes a leak in nfs_symlink()
> as now the page gets an extra refcount that is not dropped.
>
> Jan Stancek observed and reported the leak effect while running test8 from
> Connectathon Testsuite. After several iterations over the test case,
> which creates several symlinks on a NFS mountpoint, the test system was
> quickly getting into an out-of-memory scenario.
>
> This patch fixes the page leak by dropping that extra refcount
> add_to_page_cache_lru() is grabbing.
>
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

