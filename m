Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e31.co.us.ibm.com ([32.97.110.149]:44975 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855Ab1LOVeO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2011 16:34:14 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <zohar@linux.vnet.ibm.com>;
	Thu, 15 Dec 2011 14:34:13 -0700
Subject: Re: [PATCH] [RFC] KEYS: Add invalidation support
From: Mimi Zohar <zohar@linux.vnet.ibm.com>
To: David Howells <dhowells@redhat.com>
Cc: keyrings@linux-nfs.org, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org
Date: Thu, 15 Dec 2011 16:30:17 -0500
In-Reply-To: <5110.1323954863@redhat.com>
References: <1323953422.15982.13.camel@falcor>
	 <20111215121723.18382.99996.stgit@warthog.procyon.org.uk>
	 <5110.1323954863@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1323984617.16982.21.camel@falcor>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-12-15 at 13:14 +0000, David Howells wrote:
> Mimi Zohar <zohar@linux.vnet.ibm.com> wrote:
> 
> > Not all keys can be 'refetched'.  A trusted key, sealed to a PCR, can
> > extend the PCR to prevent it from being re-loaded. Removing the trusted
> > key could prevent the instantiation/update of encrypted keys.
> 
> I meant discard and set up a new struct key not actually invalidate any real
> key store.  Is this actually a problem?  If it is, I can certainly add a flag
> to prevent struct keys from being invalidated; but that doesn't stop them from
> being unlinked or revoked.
> 
> David

We discussed it here and don't think it should be a problem.

thanks,

Mimi

