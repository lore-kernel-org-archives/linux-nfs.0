Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:55101 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629Ab1CaHrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Mar 2011 03:47:04 -0400
Message-ID: <4D943164.40800@parallels.com>
Date: Thu, 31 Mar 2011 02:46:44 -0500
From: Rob Landley <rlandley@parallels.com>
To: <linux-kernel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <containers@lists.linux-foundation.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Tim Spriggs <tims@uahirise.org>, Kir Kolyshkin <kir@parallels.com>,
        Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/3] Fix NFSv3 to work with network namespaces.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch series makes NFSv3 work inside an lxc container that uses a
different network namespace than the host.

The series contains three patches.  The first adds network namespace
information to the NFSv3 code under fs/nfs (copying the network context
from the mount process during options parsing, saving it with
appropriate reference counting in the persistent nfs_client struct, and
supplying it to the RPC functions).  The second and third patches add
additional network namespace information to the sunrpc code under
net/sunrpc (which already had partial support for network namespaces).

1) Add network context to struct nfs_client and make NFSv3 use it.
2) Supply network namespace to rpcbind.
3) Compare network namespace in auth_unix cache address checks.

My containers test environment setup is described at:

  http://landley.net/lxc

I exported the NFS share from the "Laptop" layer using knfsd with the
/etc/exports line:

  /home/landley/nfs 192.168.254.2(rw,no_root_squash,insecure)

And the mount command I ran in the container is:

  mount -t nfs -o nfsvers=3 10.0.2.2:/home/landley/nfs nfstest

(You don't need the -o if you haven't compiled NFSv4 support into your
kernel.)

I've tested NFSv2 and NFSv3 with UDP and TCP transports.  This series
does not address using NFSv4, pNFS, or knfsd from container context.
I haven't fixed lockd or kerberos authentication yet.
