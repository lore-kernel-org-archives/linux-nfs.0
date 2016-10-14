Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59969 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752495AbcJNMvE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Oct 2016 08:51:04 -0400
Date: Fri, 14 Oct 2016 05:50:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Oleg Drokin <green@linuxhacker.ru>
Subject: Re: [PATCH v7 23/31] NFSv4: Fix a race when updating an open_stateid
Message-ID: <20161014125051.GA2840@infradead.org>
References: <1474565961-21303-15-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-16-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-17-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-18-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-19-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-20-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-21-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-22-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-23-git-send-email-trond.myklebust@primarydata.com>
 <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
In-Reply-To: <1474565961-21303-24-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 22, 2016 at 01:39:13PM -0400, Trond Myklebust wrote:
> If we're replacing an old stateid which has a different 'other' field,
> then we probably need to free the old stateid.

This gives me a new compiler warning:

fs/nfs/nfs4proc.c: In function ‘update_open_stateid’:
fs/nfs/nfs4proc.c:1548:2: warning: missing braces around initializer [-Wmissing-braces]
  nfs4_stateid freeme = {0};
    ^
fs/nfs/nfs4proc.c:1548:2: warning: (near initialization for ‘freeme.<anonymous>’) [-Wmissing-braces]
