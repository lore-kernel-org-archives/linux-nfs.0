Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9781 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752696Ab3HBRCb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 Aug 2013 13:02:31 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1375462821.15733.262.camel@willson.li.ssimo.org>
References: <1375462821.15733.262.camel@willson.li.ssimo.org> <20130802095555.07a2cda3@tlielax.poochiereds.net> <20130801173846.28023.19009.stgit@warthog.procyon.org.uk> <20130801173902.28023.68819.stgit@warthog.procyon.org.uk> <7136.1375462405@warthog.procyon.org.uk>
To: Simo Sorce <simo@redhat.com>
Cc: dhowells@redhat.com, Jeff Layton <jlayton@redhat.com>,
        keyrings@linux-nfs.org, linux-nfs@vger.kernel.org, krbdev@mit.edu,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
        linux-kernel@vger.kernel.org,
        "Eric W. Biederman" <ebiederm@xmission.com>
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for persistent per-UID kerberos caches
Date: Fri, 02 Aug 2013 18:02:25 +0100
Message-ID: <7261.1375462945@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Simo Sorce <simo@redhat.com> wrote:

> > Simo:  I believe the problem you have with the user keyring is that it's not
> > persistent beyond the life of the processes of that UID, right?
> 
> Correct.

In which case, pinning the user keyring in this fashion should make this work
without the need to add another keyctl, I think.

David
