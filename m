Return-Path: <zpierzycki@acg999.com>
MIME-Version: 1.0
Sender: zpierzycki@acg999.com
In-Reply-To: <alpine.OSX.2.19.9992.1604141506460.55780@planck>
References: <loom.20160414T205732-249@post.gmane.org>
	<alpine.OSX.2.19.9992.1604141506460.55780@planck>
Date: Thu, 14 Apr 2016 14:15:01 -0500
Message-ID: <CAOiTGHmsmwLsA9wOzpVi50YG4=C9Cd80Tg=e1JCJLjwXxj9k4g@mail.gmail.com>
Subject: Re: What is a 10.10.10.20-man process?
From: Ziemowit Pierzycki <ziemowit@pierzycki.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
List-ID: <linux-nfs.vger.kernel.org>

[<ffffffffa012d158>] rpc_wait_bit_killable+0x38/0x80 [sunrpc]
[<ffffffffa012d11d>] __rpc_wait_for_completion_task+0x2d/0x30 [sunrpc]
[<ffffffffa05caf30>] nfs4_run_open_task+0x130/0x1a0 [nfsv4]
[<ffffffffa05cd77d>] nfs4_open_recover_helper+0x16d/0x230 [nfsv4]
[<ffffffffa05cd875>] nfs4_open_recover+0x35/0xb0 [nfsv4]
[<ffffffffa05cff5d>] nfs4_open_expired.isra.60+0xcd/0x180 [nfsv4]
[<ffffffffa05d003e>] nfs40_open_expired+0x2e/0x40 [nfsv4]
[<ffffffffa05e3805>] nfs4_do_reclaim+0x175/0x5f0 [nfsv4]
[<ffffffffa05e416e>] nfs4_run_state_manager+0x4ee/0x7d0 [nfsv4]
[<ffffffff810bc8b8>] kthread+0xd8/0xf0
[<ffffffff8177999f>] ret_from_fork+0x3f/0x70
[<ffffffffffffffff>] 0xffffffffffffffff

Waiting for something to complete but it can't?

On Thu, Apr 14, 2016 at 2:08 PM, Benjamin Coddington
<bcodding@redhat.com> wrote:
>
> On Thu, 14 Apr 2016, Ziemowit PIerzycki wrote:
>
> > I have a strange issue when NFS4 mounts to a Netapp filer freeze on my Linux
> > KVMs.  Looking over few things I noticed a process "10.10.10.20-man" is in D
> > state but I can't find anything information about it.  Mainly because
> > 10.10.10.20 is the IP of the filer and searching for "-man" is too generic.
> >
> > Why would this process be frozen?
>
> This is the nfs4 state manager process.  What's in the file:
> /proc/<pid of that process>/stack
>
> Ben
