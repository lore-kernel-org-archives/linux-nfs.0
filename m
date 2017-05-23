Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41090 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967218AbdEWPOt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 11:14:49 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87zie3mxkc.fsf@xmission.com>
References: <87zie3mxkc.fsf@xmission.com> <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de> <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk> <1495472039.2757.19.camel@HansenPartnership.com> <2446.1495551216@warthog.procyon.org.uk>
To: ebiederm@xmission.com (Eric W. Biederman)
Cc: dhowells@redhat.com, Aleksa Sarai <asarai@suse.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2017 16:14:41 +0100
Message-ID: <2961.1495552481@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:

> > As an example, I could set up a client machine with two ethernet ports,
> > set up two DNS+NFS servers, each of which think they're called "foo.bar"
> > and attach each server to a different port on the client machine.  Then I
> > could create a pair of containers on the client machine and route the
> > network in each container to a different port.  Now there's a problem
> > because the names of the cached DNS records for each port overlap.
> 
> Please look at ip netns add.

	warthog>man ip | grep setns
	warthog1>

> It does solve this in userspace rather simply.

Ummm...  How?  The kernel DNS resolver is not namespace aware.

David
