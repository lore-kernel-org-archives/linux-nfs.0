From: Dheeraj Pandey <dheeraj@Zambeel.com>
Subject: RE: [PATCH] zerocopy NFS, ipv4 infrastructure
Date: Wed, 16 Oct 2002 06:08:40 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <233C89823A37714D95B1A891DE3BCE521423D4@xch-b.win.zambeel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: linux-net@vger.kernel.org, neilb@cse.unsw.edu.au,
	taka@valinux.co.jp
Return-path: <linux-net-owner@vger.kernel.org>
To: "'David S. Miller'" <davem@redhat.com>, nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

> Neil, other NFS developers.  I am about to push the following
> set of patches to Linus for 2.5.x
> 
> It implements several things, most important to NFS folks
> are the UDP cork/sendfile bits done by VA Linux Japan.
...

> I'm sending this so that you can start integrating the rest of the NFS
> zerocopy patches done by VA Linux Japan before this shows up for
> real in Linus's tree.
> 
> Have fun.

Hi Neil, what are you guys doing for the cksum-offload to the NIC? UDP
payloads that end up in IP fragments-- who is taking care of their
checksums? What network adapters out there are calculating running
checksum's for IP fragments that belong to the same NFS (UDP) payload?

Dheeraj 
