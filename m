Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:16425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754397Ab3EJUr4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 May 2013 16:47:56 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20130510193307.3045.21609.stgit@warthog.procyon.org.uk>
References: <20130510193307.3045.21609.stgit@warthog.procyon.org.uk> <20130510193257.3045.77981.stgit@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, Trond.Myklebust@netapp.com,
        torvalds@linux-foundation.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cachefs@redhat.com,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/8] Add wait_on_atomic_t() and wake_up_atomic_t() [ver #2]
Date: Fri, 10 May 2013 21:47:52 +0100
Message-ID: <26063.1368218872@warthog.procyon.org.uk>
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Fengguang's kbuild bot found a compile error on one arch with this patch, so
I've pushed a new version to the git tree.

David
