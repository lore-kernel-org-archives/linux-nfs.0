Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52832 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757661AbaCEPLF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 10:11:05 -0500
Received: by mail-ie0-f175.google.com with SMTP id to1so1119874ieb.6
        for <linux-nfs@vger.kernel.org>; Wed, 05 Mar 2014 07:11:05 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH 8/8] NFS: allow lockless access to access_cache
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140305030028.27421.87633.stgit@notabene.brown>
Date: Wed, 5 Mar 2014 10:11:02 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <305B5E2C-33BE-4268-87A9-22FD19EF8E1A@primarydata.com>
References: <20140305025813.27421.23871.stgit@notabene.brown> <20140305030028.27421.87633.stgit@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 4, 2014, at 22:00, NeilBrown <neilb@suse.de> wrote:

> The access cache is used during RCU-walk path lookups, so it is best
> to avoid locking if possible as taking a lock kills concurrency.
> 
> The rbtree is not rcu-safe and cannot easily be made so.
> Instead we simply check the last (i.e. most recent) entry on the LRU
> list.  If this doesn't match, then we return -ECHILD and retry in
> lock/refcount mode.
> 
> This requires freeing the nfs_access_entry struct with rcu, and
> requires using rcu access primates when adding entries to the lru, and
> when examining the last entry.
> 
> Calling put_rpccred before kfree_rcu looks a bit odd, but as
> put_rpccred already provide rcu protection, we know that the cred will
> not actually be freed until the next grace period, so any concurrent
> access will be safe.
> 
> This patch provides about 5% performance improvement on a stat-heavy
> synthetic work load with 4 threads on a 2-core CPU.
> 

Have you looked at converting the rb-tree into something a little more RCU-friendly? Since our lookup key is just a pointer value, couldn’t we use a radix-tree?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

