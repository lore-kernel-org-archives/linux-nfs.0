Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:34507 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1762701AbdEWPDA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:03:00 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: Aleksa Sarai <asarai@suse.de>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Linux Containers <containers@lists.linux-foundation.org>,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
References: <f167feeb-e653-12e3-eec8-24162f7f7c07@suse.de>
        <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
        <1495472039.2757.19.camel@HansenPartnership.com>
        <2446.1495551216@warthog.procyon.org.uk>
Date: Tue, 23 May 2017 09:56:19 -0500
In-Reply-To: <2446.1495551216@warthog.procyon.org.uk> (David Howells's message
        of "Tue, 23 May 2017 15:53:36 +0100")
Message-ID: <87zie3mxkc.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Aleksa Sarai <asarai@suse.de> wrote:
>
>> >> The reason I think this is necessary is that the kernel has no idea
>> >> how to direct upcalls to what userspace considers to be a container -
>> >> current Linux practice appears to make a "container" just an
>> >> arbitrarily chosen junction of namespaces, control groups and files,
>> >> which may be changed individually within the "container".
>> 
>> Just want to point out that if the kernel APIs for containers massively
>> change, then the OCI will have to completely rework how we describe containers
>> (and so will all existing runtimes).
>> 
>> Not to mention that while I don't like how hard it is (from a runtime
>> perspective) to actually set up a container securely, there are undoubtedly
>> benefits to having namespaces split out. The network namespace being separate
>> means that in certain contexts you actually don't want to create a new network
>> namespace when creating a container.
>
> Yep, I quite agree.
>
> However, certain things need to be made per-net namespace that *aren't*.  DNS
> results, for instance.
>
> As an example, I could set up a client machine with two ethernet ports, set up
> two DNS+NFS servers, each of which think they're called "foo.bar" and attach
> each server to a different port on the client machine.  Then I could create a
> pair of containers on the client machine and route the network in each
> container to a different port.  Now there's a problem because the names of the
> cached DNS records for each port overlap.

Please look at ip netns add.  It does solve this in userspace rather
simply.

> Further, the NFS idmapper needs to be able to direct its calls to the
> appropriate network.

Eric
