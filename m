Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52226 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751702AbcJDPpR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Oct 2016 11:45:17 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1475588260-10838-1-git-send-email-asavkov@redhat.com>
References: <1475588260-10838-1-git-send-email-asavkov@redhat.com>
To: Artem Savkov <asavkov@redhat.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Fix suspicious RCU usage in nfs_idmap_get_key.
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 04 Oct 2016 16:45:14 +0100
Message-ID: <7960.1475595914@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Artem Savkov <asavkov@redhat.com> wrote:

> nfs_idmap_get_key doesn't hold rkey->sem when calling user_key_payload
> resulting in a "suspicious RCU usage" lockdep splat. It does, however hold
> rcu_read_lock, so it either needs to use unprotected rcu_dereference, or take
> rkey->sem instead of rcu_read_lock.

This shouldn't be using rkey->sem.  user_key_payload() should do sufficient
RCU magic that rcu_read_lock() is sufficient.  Can you please include the RCU
splat?  It's possible user_key_payload() is wrong.

David
