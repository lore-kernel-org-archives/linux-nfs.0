From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [2.6.31-rc5] oops: NFS4 client manager kthread...
Date: Mon, 17 Aug 2009 09:12:18 -0400
Message-ID: <1250514738.8475.26.camel@heimdal.trondhjem.org>
References: <6278d2220908161540h78f17424m592c5acf3420f906@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752315AbZHQNMT@vger.kernel.org>
In-Reply-To: <6278d2220908161540h78f17424m592c5acf3420f906@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2009-08-16 at 23:40 +0100, Daniel J Blueman wrote:
> After losing and regaining ethernet link a few times with 2.6.31-rc5
> [1], I've hit an oops in the NFS4 client manager kthread [2] on my
> client with NFS4 homedir mount.
> 
> Do you have a frequent test-case for when the client's manager kthread
> gets invoked (with and without succeeding callbacks, due to eg a
> firewall)? Server here is unpatched 2.6.30-rc6; I recall seeing
> problems when the manager kthread gets invoked, across quite a few
> kernel releases, just wasn't lucky enough to catch an oops.
> 
> Oppsing in allow_signal() suggests task state corruption perhaps? I'm
> downloading the debug kernel to match up the disassembly and line
> numbers, if that helps? This time, the client had no firewall (but
> have seen other issues when the callback has failed due to the
> firewall).

Those aren't Oopses. They are 'soft lockup' warnings. Basically, they're
saying that the CPU is getting stuck waiting for a spin lock or a mutex.

In this case, it is probably the fact that the state manager is going
nuts trying to recover, while the connection to the server keeps coming
up and going down.

What does 'netstat -t' say when you get into this situation?

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
