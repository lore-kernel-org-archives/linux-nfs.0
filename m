Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:56370 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726467AbeGMJ6W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Jul 2018 05:58:22 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20180711122219.20808-1-smayhew@redhat.com>
References: <20180711122219.20808-1-smayhew@redhat.com>
To: Scott Mayhew <smayhew@redhat.com>
Cc: dhowells@redhat.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: add minor version to nfs_server_key for fscache
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 13 Jul 2018 10:44:27 +0100
Message-ID: <9138.1531475067@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Scott Mayhew <smayhew@redhat.com> wrote:

> kernel BUG at fs/cachefiles/namei.c:194!

Note that the cachefiles dumps a load of info immediately prior to this BUG()
which should be included in the description.

Can you also try the four patches at the top of this branch from Kiran Kumar
Modukuri?

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache-fixes

The topmost patch removes the BUG() and lets it fall through to the wait.  The
"Fix missing clear of the CACHEFILES_OBJECT_ACTIVE flag" patch fixes one of
the causes of the BUG.

David
