Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:39596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934535AbaKNOty (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Nov 2014 09:49:54 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20141030174612.10093.61557.stgit@manet.1015granger.net>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, keyrings@linux-nfs.org
Subject: Are both DO_STATE_CHECK and NO_STATE_CHECK required?
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 14 Nov 2014 14:49:46 +0000
Message-ID: <10137.1415976586@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm wondering if I actually need KEYRING_SEARCH_DO_STATE_CHECK and
KEYRING_SEARCH_NO_STATE_CHECK as separate flags rather than just states of the
same flag.

The most important distinction is in search_nested_keyrings() where I turn on
DO_STATE_CHECK specifically for potential matches on the root keyring.

However, NO_STATE_CHECK is only used for two special searches: possession
determination and cycle detection.  Neither of these use
keyring_search_iterator() as the iteration function, so neither actually takes
any notice of DO_STATE_CHECK.

Everything else currently uses - or should use - DO_STATE_CHECK, including
key_get_instantiation_authkey().

David
