From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: lockd: couldn't create RPC handle for (host)
Date: Fri, 16 Dec 2005 15:55:36 -0500
Message-ID: <20051216205536.GA20497@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, ryan@tau.solarneutrino.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932407AbVLPUzi@vger.kernel.org>
To: nfs@lists.sourceforge.net
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Hi, nfs locking stopped working on my file server running 2.6.15-rc5
today.  All clients that try locking operations hang, and I get the
message from the server:

lockd: couldn't create RPC handle for w.x.y.z

Also, the lockd process is unkillable, it looks like I'll have to
reboot.

The nfs mounts look like:

rw,nosuid,nodev,v3,rsize=8192,wsize=8192,hard,intr,udp,lock

I've recently posted the kernel .config and dmesg for both the server
and clients for other bug reports.  For the server:

Message-ID: <20051129200013.GB6326@tau.solarneutrino.net>

and the clients:

Message-ID: <20051208022624.GA12944@tau.solarneutrino.net>

Any help would be appreciated.

Thanks,
-ryan
