From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Regression, bisected: sqlite locking failure on nfs
Date: Mon, 1 Nov 2010 14:07:18 -0400
Message-ID: <D68536EB-6BE9-4DE4-B325-39FEF747092E@oracle.com>
References: <20101101175854.GA3550@elliptictech.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: LKML Kernel <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Nick Bowler <nbowler@elliptictech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42035 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753084Ab0KASHl convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Nov 2010 14:07:41 -0400
In-Reply-To: <20101101175854.GA3550@elliptictech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 1, 2010, at 1:58 PM, Nick Bowler wrote:

> After installing 2.6.37-rc1, attempting to use sqlite in any capacity on
> NFS gives a locking error:
> 
>  % echo 'select * from blah;' | sqlite3 blah.sqlite
>  Error: near line 1: database is locked
> 
>  % echo 'create table blargh(INT);' | sqlite3 blargh.sqlite
>  Error: near line 1: database is locked
> 
> The result is that a lot of high-profile applications which make use of
> sqlite fail mysteriously.  Bisection reveals the following, and
> reverting the implicated commit solves the issue:

Nick, thanks for the report.  Is 2.6.37-rc1 running on your clients or on your server?  Does anything interesting appear in the kernel log when your test case fails?

> 9247685088398cf21bcb513bd2832b4cd42516c4 is the first bad commit
> commit 9247685088398cf21bcb513bd2832b4cd42516c4
> Author: Chuck Lever <chuck.lever@oracle.com>
> Date:   Wed Oct 20 11:53:01 2010 -0400
> 
>    SUNRPC: Properly initialize sock_xprt.srcaddr in all cases
> 
>    The source address field in the transport's sock_xprt is initialized
>    ONLY IF the RPC application passed a pointer to a source address
>    during the call to rpc_create().  However, xs_bind() subsequently uses
>    the value of this field without regard to whether the source address
>    was initialized during transport creation or not.
> 
>    So far we've been lucky: the uninitialized value of this field is
>    zeroes.  xs_bind(), until recently, used only the sin[6]_addr field in
>    this sockaddr, and all zeroes is a valid value for this: it means
>    ANYADDR.  This is a happy coincidence.
> 
>    However, xs_bind() now wants to use the sa_family field as well, and
>    expects it to be initialized to something other than zero.
> 
>    Therefore, the source address sockaddr field should be fully
>    initialized at transport create time in _every_ case, not just when
>    the RPC application wants to use a specific bind address.
> 
>    Bruce added a workaround for this missing initialization by adjusting
>    commit 6bc9638a, but the "right" way to do this is to ensure that the
>    source address sockaddr is always correctly initialized from the
>    get-go.
> 
>    This patch doesn't introduce a behavior change.  It's simply a
>    clean-up of Bruce's fix, to prevent future problems of this kind.  It
>    may look like overkill, but
> 
>      a) it clearly documents the default initial value of this field,
> 
>      b) it doesn't assume that the sockaddr_storage memory is first
>         initialized to any particular value, and
> 
>      c) it will fail verbosely if some unknown address family is passed
>         in
> 
>    Originally introduced by commit d3bc9a1d.
> 
>    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> :040000 040000 843e2423b5a45f7bc13b9e30cc8e5bcb072dbb8f 7148b5256ce78fd5c98a01f1bdcac46faa80f773 M	net
> 
> git bisect start
> # bad: [c8ddb2713c624f432fa5fe3c7ecffcdda46ea0d4] Linux 2.6.37-rc1
> git bisect bad c8ddb2713c624f432fa5fe3c7ecffcdda46ea0d4
> # good: [f6f94e2ab1b33f0082ac22d71f66385a60d8157f] Linux 2.6.36
> git bisect good f6f94e2ab1b33f0082ac22d71f66385a60d8157f
> # good: [33081adf8b89d5a716d7e1c60171768d39795b39] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6
> git bisect good 33081adf8b89d5a716d7e1c60171768d39795b39
> # bad: [00ebb6382b8d9c7c15b5f8ad230670d8161d38dd] Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc
> git bisect bad 00ebb6382b8d9c7c15b5f8ad230670d8161d38dd
> # bad: [520045db940a381d2bee1c1b2179f7921b40fb10] Merge branches 'upstream/xenfs' and 'upstream/core' of git://git.kernel.org/pub/scm/linux/kernel/git/jeremy/xen
> git bisect bad 520045db940a381d2bee1c1b2179f7921b40fb10
> # bad: [4390110fef9e5c64e10c6ca19d586932242c9a8a] Merge branch 'for-2.6.37' of git://linux-nfs.org/~bfields/linux
> git bisect bad 4390110fef9e5c64e10c6ca19d586932242c9a8a
> # good: [7b6181e06841f5ad15c4ff708b967b4db65a64de] Merge branch 'omap-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tmlind/linux-omap-2.6
> git bisect good 7b6181e06841f5ad15c4ff708b967b4db65a64de
> # good: [e0e170bd7ded2ec16e2813d63c0faff43193fde8] Merge branch 'next' of git://git.monstr.eu/linux-2.6-microblaze
> git bisect good e0e170bd7ded2ec16e2813d63c0faff43193fde8
> # good: [22f793268de3b4dff8abfcd873ba7afc1f34224f] sunrpc: Factor out v4 sockets creation
> git bisect good 22f793268de3b4dff8abfcd873ba7afc1f34224f
> # good: [a4dd8dce14014665862ce7911b38cb2c69e366dd] Merge branch 'nfs-for-2.6.37' of git://git.linux-nfs.org/projects/trondmy/nfs-2.6
> git bisect good a4dd8dce14014665862ce7911b38cb2c69e366dd
> # bad: [cd5b814458e5554457c6e62f17aed122145b065e] nfsd4: don't cache seq_misordered replies
> git bisect bad cd5b814458e5554457c6e62f17aed122145b065e
> # good: [8c14ff2aaf26d58aa2258a59bd419c906d105938] sunrpc: Remove UDP worker wrappers
> git bisect good 8c14ff2aaf26d58aa2258a59bd419c906d105938
> # good: [8f3a6de313391b6910aa7db185eb9f3e930a51cf] sunrpc: Turn list_for_each-s into the ..._entry-s
> git bisect good 8f3a6de313391b6910aa7db185eb9f3e930a51cf
> # good: [4232e8634ad82c5a53389e4016de15a8b15c09c3] SUNRPC: Use conventional switch statement when reclassifying sockets
> git bisect good 4232e8634ad82c5a53389e4016de15a8b15c09c3
> # bad: [9247685088398cf21bcb513bd2832b4cd42516c4] SUNRPC: Properly initialize sock_xprt.srcaddr in all cases
> git bisect bad 9247685088398cf21bcb513bd2832b4cd42516c4
> 
> -- 
> Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




