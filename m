Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59287 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751053AbdEaN7G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 May 2017 09:59:06 -0400
Message-Id: <1496239145.289295.994170312.57409998@webmail.messagingengine.com>
From: Colin Walters <walters@verbum.org>
To: David Howells <dhowells@redhat.com>,
        James.Bottomley@HansenPartnership.com, ebiederm@xmission.com
Cc: linux-nfs@vger.kernel.org, containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, keyrings@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Subject: Re: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service
 request_key upcalls
In-Reply-To: <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
Date: Wed, 31 May 2017 09:59:05 -0400
References: <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 30, 2017, at 12:08 PM, David Howells wrote:
>
> 	KEY_SERVICE_NS_UTS
> 	KEY_SERVICE_NS_IPC
> 	KEY_SERVICE_NS_MNT
> 	KEY_SERVICE_NS_PID
> 	KEY_SERVICE_NS_NET
> 	KEY_SERVICE_NS_CGROUP

Any reasons not to reuse the CLONE_ flags?

> which select those namespaces of the caller that must match for the daemon
> to be given the request.  So, for example, a daemon that wanted to service
> DNS requests from the kernel would do something like:
> 
> 	keyctl(KEYCTL_SERVICE_ADD, fd, "dns_resolver", KEY_SERVICE_NS_NET);

At least to me, it's not clear what the use cases really are.  Do we expect
people to e.g. set up NFS mounts that require keys/DNS inside "a container"
(and if in a container, with what namespaces?)

My offhand feeling is that most of the mounting-in-container case is mostly
"init container" where you migrate a VM -> container and run sshd etc.
in the container.  

There's a whole thread on extending what filesystems can be mounted with
a userns CAP_SYS_ADMIN but personally I doubt that's going to really happen
given how unrealistic it is for the kernel to parse potentially hostile filesystems.

So if the mount-in-container is mostly init containers, and for init
containers you have *all* namespaces usually, does it make
sense to have the capability to match namespaces for key services?

Something that worries me a lot here is for e.g. Docker today, the default
is uid 0 but not CAP_SYS_ADMIN.  We don't want a container that I run
with --host=net to be able to read the "host" keyrings, even if it shares
the host network namespace.

Today for Docker the default seccomp policy prevents access to keyctl()
at all because it's only with user namespaces that the kerying is namespaced.

Basically my instinct here is to be conservative and have KEYCTL_SERVICE_ADD
require CAP_SYS_ADMIN and only affect the userns keyring.
