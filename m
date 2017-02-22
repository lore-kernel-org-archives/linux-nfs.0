Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57324 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753699AbdBVQg6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 11:36:58 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170222124653.GA11726@dustball.brq.redhat.com>
References: <20170222124653.GA11726@dustball.brq.redhat.com>
To: Jan Stancek <jstancek@redhat.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Subject: Re: [bug] suspicious RCU usage nfs_idmap_get_key
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 22 Feb 2017 16:36:55 +0000
Message-ID: <567.1487781415@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jan Stancek <jstancek@redhat.com> wrote:

> I'm running into following warning with 4.10 reliably (on ppc64le)
> when I mount NFS volume (exported by RHEL6 system):

Yeah.  I've seen this before.

> Patch below makes it go away for me, but I'm not sure it's the correct way.

The right solution is to split user_key_payload().  It's actually getting used
for two different things.  We really need a user_key_payload_rcu() that just
uses rcu_dereference().

David
