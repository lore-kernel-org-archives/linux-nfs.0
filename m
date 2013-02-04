Return-Path: linux-nfs-owner@vger.kernel.org
Received: from maui.cs.washington.edu ([128.208.5.86]:42379 "EHLO
	maui.cs.washington.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab3BDX4N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 18:56:13 -0500
Received: from maui.cs.washington.edu (localhost [127.0.0.1])
	by maui.cs.washington.edu (8.14.5/8.14.5/1.11) with ESMTP id r14Nj7V5007154
	for <linux-nfs@vger.kernel.org>; Mon, 4 Feb 2013 15:45:07 -0800
	(envelope-from oystr@cs.washington.edu)
Received: from maui.cs.washington.edu (localhost [127.0.0.1])
	by maui.cs.washington.edu (8.14.5/8.14.5/1.11) with ESMTP id r14Nj7Gr007151
	for <linux-nfs@vger.kernel.org>; Mon, 4 Feb 2013 15:45:07 -0800
	(envelope-from oystr@cs.washington.edu)
Date: 4 Feb 2013 15:44 PST
From: Jan Sanislo <oystr@cs.washington.edu>
Subject: Probable rpc.mountd regression in nfs-utils-1.2.6
To: linux-nfs@vger.kernel.org
Message-Id: <1360021461/oystr@maui.cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Attempting to NFSv4 mount a file system from an NFS server running the
rpc.mountd from nfs-utils-1.2.6 will hang indefinitely if the file
system in question is not exported to the client machine.  Attempting
to mount the same, non-exported file system using NFSv3 will produce
the expected error message: "mount.nfs: access denied by server while
mounting ....".

This problem seems to stem from a change in the 1.2.6 version of
the nfs-utils mountd program: utils/mountd/cache.c[auth_unix_ip()].

In the 1.2.5 version of auth_unix_ip the code is:

        /* addr is a valid, interesting address, find the domain name... */
        if (!use_ipaddr) {
                ai = client_resolve(tmp->ai_addr);
                client = client_compose(ai);
                freeaddrinfo(ai);
        }
        freeaddrinfo(tmp);

        qword_print(f, "nfsd");
	qword_print(f, ipaddr);
	....

I.e., mountd *always* wrote at least the ip address down the
/proc/net/rpc/auth.unix.ip/channel pipe in response to kernel upcall.

In the 1.2.6 version of auth_unix_ip the code is:

        /* addr is a valid, interesting address, find the domain name... */
        if (!use_ipaddr) {
                struct addrinfo *ai = NULL;

                ai = client_resolve(tmp->ai_addr);
                if (ai == NULL)
                        goto out;
                client = client_compose(ai);
                freeaddrinfo(ai);
                if (!client)
                        goto out;
        }
        qword_print(f, "nfsd");
        qword_print(f, ipaddr);
	...
  out:

In this latter case, the kernel upcall is responded to only if the
requesting IP address is associated with an exported file system.
Without the response the kernel waits about 5 seconds and then
drops the NFS request (PUTROOTFH,GETATTR,...) and leaves the client
hanging.

