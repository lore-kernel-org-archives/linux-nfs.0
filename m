Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7367 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755519Ab2CSPjM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 11:39:12 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20120319104432.56fe1e66@redhat.com>
References: <20120319104432.56fe1e66@redhat.com> <20120208110254.4050.8856.stgit@warthog.procyon.org.uk> <20120208110400.4050.11565.stgit@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: dhowells@redhat.com, steved@redhat.com, jmorris@namei.org,
        linux-security-module@vger.kernel.org, keyrings@linux-nfs.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [Keyrings] [PATCH 7/9] KEYS: Permit in-place link replacement in keyring list
Date: Mon, 19 Mar 2012 15:39:00 +0000
Message-ID: <14790.1332171540@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote:

> Why is it safe to use key_put(rcu_access_pointer(...)) ? Clearly that
> pointer will end up being dereferenced, right?

Simple.  This key_put() is called from within keyring_destroy() and that is
only ever called from the garbage collector - which is non-reentrant.  Add to
that that key_put() never actually destroys a now-unused key, but merely
schedules the gc for a future run, and it's *that* that searches out unused
keys and deletes them.

David
