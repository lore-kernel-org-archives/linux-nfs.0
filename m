Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f53.google.com ([209.85.213.53]:36336 "EHLO
	mail-vk0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcBFAUA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 19:20:00 -0500
Received: by mail-vk0-f53.google.com with SMTP id c3so20215295vkb.3
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 16:19:59 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 5 Feb 2016 16:19:59 -0800
Message-ID: <CAOFvWm-ZTOhWN6Pa_CdVYMs9n2AsEjj7p9RAdqnrLJeH4JHFTw@mail.gmail.com>
Subject: nfsd and containers
From: =?UTF-8?Q?Kjetil_J=C3=B8rgensen?= <kjetil@medallia.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

trying to fit everything into the same mold, we're trying to run the
in-kernel "nfs server" inside of docker containers. It works great -
with one exception, "unclean shutdown" of the container itself which
leaves behind the knfsd threads, which holds on to references to i.e.
the mount-namespace the filesystem it's exported lives within.

We've done some patching of docker, so we use ceph rbd devices,
mounted into the docker container, and a veth pair for networking. The
"init" process in the docker containers pid-namespace has a notion of
graceful shutdown, where echos 0 into /proc/fs/nfsd/threads.

In the case where the container init process gets an un-trappable
signal, the kernel threads not really being part of the pid-namespace
will be left behind, the knfsd threads holds on references to the
mount-namespace, which leaves the filesystem mounted.

Yes - we can from the outside signal the kernel NFSd threads which do
let them terminate, but it's not ideal.

A simple-ish test case: unshare -n -p -m -f --mount-proc -- /usr/sbin/rpc.nfsd

Wishful thinking: the kernel nfsd threads that were spawned by
rpc.nfsd goes away with the pid-namespace
Actual outcome: the kernel nfsd threads sticks around until signalled

The actual question(s):
- Am I missing something ?
- Is this folly, and should be abandoned post haste ? (In essence, go
find a userspace nfs implementation)
- In the case where this is folly but we still decide to plow ahead,
is there any way I can determine which namespaces the kernel nfsd
threads hold references to ? (Making killing signalling the "right"
nfsd threads easier, as I lost my reference to the correct
/proc/fs/nfsd with the process I had in the corresponding
pid-namespace)

Cheers,
-- 
Kjetil Joergensen <kjetil@medallia.com>
Medallia Inc
