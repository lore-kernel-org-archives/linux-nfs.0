Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:35596 "EHLO
        out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760110AbdEWPac (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 May 2017 11:30:32 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: David Howells <dhowells@redhat.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>,
        trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
        Linux Containers <containers@lists.linux-foundation.org>
References: <1495472039.2757.19.camel@HansenPartnership.com>
        <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
        <32556.1495547529@warthog.procyon.org.uk>
Date: Tue, 23 May 2017 10:23:46 -0500
In-Reply-To: <32556.1495547529@warthog.procyon.org.uk> (David Howells's
        message of "Tue, 23 May 2017 14:52:09 +0100")
Message-ID: <87inkrlhq5.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> writes:

> Another thing that could be useful is a list of what device files a container
> may access, so that we can allow limited mounting by the container root user
> within the container.

That is totally not why that isn't allowed, and won't be allowed any
time soon.

The issue is that the filesystem implementations in the kernel are not
prepared to handle hostile filesystem data structures so that that is
the definition of a kernel exploit.  The attack surface of the kernel
gets quite a bit larger in that case.

Perhaps if all of the filesystems data structures had a hmac on them we
could allow something like this.

Once we can make it safe it is easy to add an appropriate interface.  We
most defintiely don't need a ``container'' data structure in the kernel
to do that.

A completely unprivileged fuse is much more likely to work for this use
case.

And we do already have have the device cgroup which sort of does
this.

Eric


