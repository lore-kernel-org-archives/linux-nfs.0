Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753827AbaDPGui (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 02:50:38 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <534DCD52.5080202@RedHat.com>
References: <534DCD52.5080202@RedHat.com> <534C7B70.9000500@candelatech.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: dhowells@redhat.com, Ben Greear <greearb@candelatech.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs-utils patch for 'keyctl_invalidate'.
Date: Wed, 16 Apr 2014 07:50:30 +0100
Message-ID: <7417.1397631030@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <SteveD@redhat.com> wrote:

> CC-ing the keyutils maintainer... David, when did that kernel 
> change go in that cause keyctl_revoke() to no longer work?

I think this is what you are referring to:

Committer: David Howells <dhowells@redhat.com>  2012-10-02 19:24:56
Parent: 3a50597de8635cd05133bd12c95681c82fe7b878 (KEYS: Make the session and process keyrings per-thread)
Child:  f8aa23a55f813c9bddec2a6176e0e67274e6e7c1 (KEYS: Use keyring_alloc() to create special keyrings)
Branches: cred-fixes, master and many more (159)
Follows: v3.6-rc7
Precedes: fscache-fixes-20121220

> It sound like we need to do some type of #ifdef kernel version.... 

You could try keyctl_invalidate(), then if that doesn't work, call
keyctl_revoke().

David
