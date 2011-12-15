Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26874 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199Ab1LONOa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Dec 2011 08:14:30 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1323953422.15982.13.camel@falcor>
References: <1323953422.15982.13.camel@falcor> <20111215121723.18382.99996.stgit@warthog.procyon.org.uk>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: dhowells@redhat.com, keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org
Subject: Re: [PATCH] [RFC] KEYS: Add invalidation support
Date: Thu, 15 Dec 2011 13:14:23 +0000
Message-ID: <5110.1323954863@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mimi Zohar <zohar@linux.vnet.ibm.com> wrote:

> Not all keys can be 'refetched'.  A trusted key, sealed to a PCR, can
> extend the PCR to prevent it from being re-loaded. Removing the trusted
> key could prevent the instantiation/update of encrypted keys.

I meant discard and set up a new struct key not actually invalidate any real
key store.  Is this actually a problem?  If it is, I can certainly add a flag
to prevent struct keys from being invalidated; but that doesn't stop them from
being unlinked or revoked.

David
