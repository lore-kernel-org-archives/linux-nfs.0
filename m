Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47186 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S967530AbdEWQgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 12:36:07 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1495554267.27369.9.camel@HansenPartnership.com>
References: <1495554267.27369.9.camel@HansenPartnership.com> <87zie3mxkc.fsf@xmission.com> <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de> <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk> <1495472039.2757.19.camel@HansenPartnership.com> <2446.1495551216@warthog.procyon.org.uk> <2961.1495552481@warthog.procyon.org.uk> <87bmqjmwl5.fsf@xmission.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: dhowells@redhat.com, "Eric W. Biederman" <ebiederm@xmission.com>,
        Aleksa Sarai <asarai@suse.de>, trondmy@primarydata.com,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2017 17:36:03 +0100
Message-ID: <3860.1495557363@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> What David is pointing out is that the kernel has a DNS cache
> (net/dns_resolver/) it can do name to IP translations, but isn't
> namespaced.  Once it has one entry all containers would see it if they
> cause a lookup to go through the kernel cache, so going through the
> cache you can't have a name resolving to different IP addresses on a
> per container basis.

Yes - and the transport to userspace, the request_key() upcall, isn't
namespaced either.  Namespacing it isn't entirely simple since we have to set
the right mount namespace (for execve, config, etc.), plus any other relevant
namespaces (such as network) - which is dependent on key type.

I can't record the mount namespace in the network namespace because that would
create a dependency loop:

	mnt_ns -> mnt -> sb -> net_ns -> mnt_ns

> I think Eric's point is that if you need the same DNS names resolving
> to different IP addresses on a per container basis, you can do this in
> userspace today but you have to disable the in-kernel DNS cache.

You could disable the in-kernel dns resolver in your config, but then you
don't get referrals in NFS.  Also, CIFS, AFS and other filesystems would be
affected.  If you're fine with the restrictions, then there is no problem.

David
