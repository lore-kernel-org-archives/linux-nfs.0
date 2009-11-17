Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.229.18]:33164 "EHLO dot.freshdot.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754024AbZKQPjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Nov 2009 10:39:23 -0500
Date: Tue, 17 Nov 2009 16:39:28 +0100
From: Sander Smeenk <ssmeenk@freshdot.net>
To: linux-nfs@vger.kernel.org
Subject: rpc.mountd --manage-gids breaks on UID differences
Message-ID: <20091117153928.GA12493@dot.freshdot.net>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I ran into this problem the other day which i'd like to report as a
possible bug or at least an inconvenience. Please read and spill your
thoughts if you want.

In this situation i had a x86_64 Linux machine running Ubuntu 8.04.3 LTS
with kernel 2.6.24-25-generic and nfs-utils 1:1.1.2-2ubuntu2.
/usr/sbin/rpc.mountd identifies itself as 'kmountd 1.1.2'.
This machine acts as the server and has '--manage-gids' specified in
/etc/default/nfs-kernel-server's RPCMOUNTDOPTS. It exports one share
to a /24 subnet with (rw,sync,no_subtree_check,no_root_squash) options.

I have another machine acting as client, same OS-release, same kernel,
this machine only has nfs-common utilities installed and thus does not
run rpc.mountd. It mounts the NFS-server with 'rw,addr=172.17.145.210'
mountoptions. Nothing fancy there either.

There's no firewall between the machines.

On the server i have a user 'foo' with UID '1000' and GID '65000',
On the client i have a user 'foo' with UID '1001' and GID '65000'.
Username is identical as is the GID, the UID isn't.

If user 'foo' on the nfs-client tries to reach the mountpoint where the
nfs-server is mounted the shell of this user will freeze. For example,
user 'foo' on the nfs-client types 'cd /mnt/nfs/ap<tabtab>' and stalls.

The clientmachine then begins to log 'nfs: server 172.17.145.210 not
responding, still trying' and this user's shell doesn't recover in any
way until forcefully killed.

Funny thing is, a user 'bar' with the same UID on the server- and
client machine can still access the NFS-mount on the client even when
the session for user 'foo' is stalling. Also, running 'rpcinfo -p' or
'rpcinfo -u <host> <progid>' on the server reports all normal values.

The server logs nothing.

Aparently this has to do with UIDs being different on the nfs-server and
the nfs-client as i discovered debugging this problem in two VMs. It's
quite easy to reproduce and also seems to happen if the user on the
clientmachine is nonexistant on the servermachine.

Disabling '--manage-gids' and remouting, restarting or rebooting
completely fixes the problem. Reintroducing '--manage-gids' breaks it
again.

It appears to me '--manage-gids' is completely broken in this setup, or
i misunderstand what --manage-gids does, completely.  I haven't tried
this on newer kernels (2.6.31-14-generic f.e.).

I do have kernel debug logs during broken and working NFS transactions
which i got by echoing the correct bitmask to /proc/sys/sunrpc/*debug.

http://www.freshdot.net/tmp/client-broken-syslog
http://www.freshdot.net/tmp/server-broken-syslog
vs
http://www.freshdot.net/tmp/client-working-syslog
http://www.freshdot.net/tmp/server-working-syslog

Is this behaviour intended?
Hope to hear from you!

With regards,
Sander Smeenk.
-- 
| When you've seen one shopping center you've seen a mall.
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
