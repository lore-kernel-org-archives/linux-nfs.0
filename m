Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:34366 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030992AbdEWPYJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:24:09 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: Aleksa Sarai <asarai@suse.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <87zie3mxkc.fsf@xmission.com>
        <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
        <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
        <1495472039.2757.19.camel@HansenPartnership.com>
        <2446.1495551216@warthog.procyon.org.uk>
        <2961.1495552481@warthog.procyon.org.uk>
Date: Tue, 23 May 2017 10:17:26 -0500
In-Reply-To: <2961.1495552481@warthog.procyon.org.uk> (David Howells's message
        of "Tue, 23 May 2017 16:14:41 +0100")
Message-ID: <87bmqjmwl5.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>
>> > As an example, I could set up a client machine with two ethernet ports,
>> > set up two DNS+NFS servers, each of which think they're called "foo.bar"
>> > and attach each server to a different port on the client machine.  Then I
>> > could create a pair of containers on the client machine and route the
>> > network in each container to a different port.  Now there's a problem
>> > because the names of the cached DNS records for each port overlap.
>> 
>> Please look at ip netns add.
>
> 	warthog>man ip | grep setns
> 	warthog1>

Not setns netns


>> It does solve this in userspace rather simply.
>
> Ummm...  How?  The kernel DNS resolver is not namespace aware.

But it works fine if called in the proper context and we have a defacto
standard for where to put all of the files (the tricky part) if you are
dealing with multiple network namespaces simultaneously.

Eric
