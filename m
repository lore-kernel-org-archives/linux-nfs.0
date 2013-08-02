Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19606 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754331Ab3HBRAm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 13:00:42 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87ob9hovop.fsf@xmission.com>
References: <87ob9hovop.fsf@xmission.com> <20130801173846.28023.19009.stgit@warthog.procyon.org.uk> <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
To: ebiederm@xmission.com (Eric W. Biederman)
Cc: dhowells@redhat.com, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org, simo@redhat.com
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent per-UID kerberos caches
Date: Fri, 02 Aug 2013 18:00:30 +0100
Message-ID: <7202.1375462830@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:

> > Add support for per-user_namespace registers of persistent per-UID kerberos
> > caches held within the kernel.
> 
> Out of curiosity is this cache per user namspace because the key lookup
> is per user namespace?

Yes.  You can't see keys in another namespace.  I occasionally wonder if I
should make the key serial number tree per namespace so that you don't search
keys outside your namespace and can't try looking them up by ID - but it
complicates the garbage collector which iterates over the entire tree (though
it could maintain a list of per-ns trees).

> Some minor nits below. But I don't see anything particulary scary about
> this patch.  Other than seeming to make it easy for root to get my
> kerbose tickets.

Root can do that anyway with file-based ccaches, I believe.  However, you can
change the key permissions to prevent root even seeing that your keys/keyrings
exist, let alone stealing them.

