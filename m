Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bedivere.hansenpartnership.com ([66.63.167.143]:42056 "EHLO
        bedivere.hansenpartnership.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750885AbdEWPob (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:44:31 -0400
Message-ID: <1495554267.27369.9.camel@HansenPartnership.com>
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>,
        David Howells <dhowells@redhat.com>
Cc: Aleksa Sarai <asarai@suse.de>, trondmy@primarydata.com,
        mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Date: Tue, 23 May 2017 08:44:27 -0700
In-Reply-To: <87bmqjmwl5.fsf@xmission.com>
References: <87zie3mxkc.fsf@xmission.com>
         <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
         <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
         <1495472039.2757.19.camel@HansenPartnership.com>
         <2446.1495551216@warthog.procyon.org.uk>
         <2961.1495552481@warthog.procyon.org.uk> <87bmqjmwl5.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-05-23 at 10:17 -0500, Eric W. Biederman wrote:
> David Howells <dhowells@redhat.com> writes:
> > Eric W. Biederman <ebiederm@xmission.com> wrote:
> > > It does solve this in userspace rather simply.
> > 
> > Ummm...  How?  The kernel DNS resolver is not namespace aware.
> 
> But it works fine if called in the proper context and we have a 
> defacto standard for where to put all of the files (the tricky part) 
> if you are dealing with multiple network namespaces simultaneously.

I think you're missing each other's points slightly.

What David is pointing out is that the kernel has a DNS cache
(net/dns_resolver/) it can do name to IP translations, but isn't
namespaced.  Once it has one entry all containers would see it if they
cause a lookup to go through the kernel cache, so going through the
cache you can't have a name resolving to different IP addresses on a
per container basis.

I think Eric's point is that if you need the same DNS names resolving
to different IP addresses on a per container basis, you can do this in
userspace today but you have to disable the in-kernel DNS cache.

James


