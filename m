Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f68.google.com ([209.85.219.68]:48792 "EHLO
	mail-oa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256Ab3FYQ7B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 12:59:01 -0400
Received: by mail-oa0-f68.google.com with SMTP id i7so5377156oag.7
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 09:59:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+uAZNMXLXcV6VNqOqVJEbOoKwj-fdmBp4mLz25W7nRxaB9A9w@mail.gmail.com>
References: <CA+uAZNMXLXcV6VNqOqVJEbOoKwj-fdmBp4mLz25W7nRxaB9A9w@mail.gmail.com>
Date: Tue, 25 Jun 2013 22:29:00 +0530
Message-ID: <CA+uAZNMgUQ7mWQOeD4EGcgWfwhUFeaBrXregUmbNP15gt2-yjw@mail.gmail.com>
Subject: Re: NFSD server is constantly returning nfserr_bad_stateid on 3.2 kernel
From: Shyam Kaushik <shyamnfs1@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I looked up at this issue further & see the problem is this:
# Client sends OPEN() of a file & as part of this NFSD server sets up
a stateid & returns to the client.
# Client comes back immediately with OPEN_CONFIRM() presenting the
same stateid & NFSD server replies back that its a bad-stateid.

Here are some pieces from tcpdump:
NFS client comes with an OPEN of a file
10.189253 10.0.27.163 172.31.240.116 NFS 326 V4 Call (Reply In 8264)
OPEN DH:0xfe4b0254/index.html
         share_access: OPEN4_SHARE_ACCESS_READ (1)
         share_deny: OPEN4_SHARE_DENY_NONE (0)
         clientid: 0xcb76ab5114000000
         Claim Type: CLAIM_NULL (0)

NFS server reply
10.457226 172.31.240.116 10.0.27.163 NFS 498 V4 Reply (Call In 8057)
OPEN StateID:0x50ee
        Status: NFS4_OK (0)
        StateID Hash: 0x50ee
        seqid: 0x00000001
        Data: cb76ab5114000000c4ca2540
        1. = OPEN4_RESULT_CONFIRM
        Delegation Type: OPEN_DELEGATE_NONE (0)


Client comes back with OPEN_CONFIRM
10.459343 10.0.27.163 172.31.240.116 NFS 238 V4 Call (Reply In 8465)
OPEN_CONFIRM
        StateID Hash: 0x50ee
        seqid: 0x00000001
        Data: cb76ab5114000000c4ca2540

Server replies with bad-stateid
10.733341 172.31.240.116 10.0.27.163 NFS 122 V4 Reply (Call In 8275)
OPEN_CONFIRM Status: NFS4ERR_BAD_STATEID
        Status: NFS4ERR_BAD_STATEID (10025)


This keeps happening & nothing really progresses.

Any thoughts/ideas on how to debug this further greatly appreciated.

Thanks.

--Shyam

On Mon, Jun 24, 2013 at 10:43 PM, Shyam Kaushik <shyamnfs1@gmail.com> wrote:
> Hi Folks,
>
> Need help regarding a strange NFS server issue on 3.2 kernel.
>
> We are running a NFS server on Ubuntu precise with 3.2.0-25-generic
> #40-Ubuntu kernel.
>
> We have several NFS exports out of this server & multiple clients
> running different versions of linux kernel consume these exports. We
> use ext4 with sync mount as the filesystem.
>
> We periodically see that all NFS activity comes to a standstill on all
> NFS exports. Enabling NFS debug shows that there are numerous
> nfserr_bad_stateid on almost all operations. This makes all of the
> NFSD threads to consume all of CPU on the server.
>
> Jun 24 01:50:42 srv007 kernel: [5753609.342457] nfsd_dispatch: vers 4 proc 1
> Jun 24 01:50:42 srv007 kernel: [5753609.342457] nfsv4 compound op
> #1/7: 22 (OP_PUTFH)
> Jun 24 01:50:42 srv007 kernel: [5753609.342467] nfsv4 compound op
> ffff880095744078 opcnt 3 #1: 22: status 0
> Jun 24 01:50:42 srv007 kernel: [5753609.342472] nfsv4 compound op
> #2/3: 38 (OP_WRITE)
> Jun 24 01:50:42 srv007 kernel: [5753609.342472] nfsd: fh_verify(36:
> 01070001 00d40001 00000000 ac63c188 0a4859a1 feb41e83)
> Jun 24 01:50:42 srv007 kernel: [5753609.342484] renewing client
> (clientid 51ab76cb/00005fc9)
> Jun 24 01:50:42 srv007 kernel: [5753609.342486] NFSD: nfsd4_write:
> couldn't process stateid!
> Jun 24 01:50:42 srv007 kernel: [5753609.342529] nfsv4 compound op
> ffff880095744078 opcnt 3 #2: 38: status 10025
> Jun 24 01:50:42 srv007 kernel: [5753609.342544] nfsv4 compound returned 10025
>
> Jun 24 01:50:42 srv007 kernel: [5753609.444116] nfsd_dispatch: vers 4 proc 1
> Jun 24 01:50:42 srv007 kernel: [5753609.444122] nfsv4 compound op
> #1/3: 22 (OP_PUTFH)
> Jun 24 01:50:42 srv007 kernel: [5753609.444125] nfsd: fh_verify(36:
> 01070001 00020001 00000000 eb3726ca c8497c28 911b4a8d)
> Jun 24 01:50:42 srv007 kernel: [5753609.444134] nfsv4 compound op
> ffff880093436078 opcnt 3 #1: 22: status 0
> Jun 24 01:50:42 srv007 kernel: [5753609.444136] nfsv4 compound op
> #2/3: 38 (OP_WRITE)
> Jun 24 01:50:42 srv007 kernel: [5753609.446920] nfsd4_process_open2:
> stateid=(51ab76cb/0000000b/40259544/00000001)
> Jun 24 01:50:42 srv007 kernel: [5753609.446925] nfsv4 compound op
> ffff880095027078 opcnt 7 #3: 18: status 0
> Jun 24 01:50:42 srv007 kernel: [5753609.446929] renewing client
> (clientid 51ab76cb/00000022)
> Jun 24 01:50:42 srv007 kernel: [5753609.446929] NFSD: nfsd4_write:
> couldn't process stateid!
> Jun 24 01:50:42 srv007 kernel: [5753609.446929] nfsv4 compound op
> ffff880093436078 opcnt 3 #2: 38: status 10025
> Jun 24 01:50:42 srv007 kernel: [5753609.446929] nfsv4 compound returned 10025
>
> Jun 24 01:50:42 srv007 kernel: [5753609.447162] nfsd_dispatch: vers 4 proc 1
> Jun 24 01:50:42 srv007 kernel: [5753609.447163] nfsd: fh_verify(36:
> 01070001 00240001 00000000 a80fc170 1947ae6c 4fbf37b1)
> Jun 24 01:50:42 srv007 kernel: [5753609.447163] NFSD:
> nfs4_preprocess_seqid_op: seqid=1 stateid =
> (51ab76cb/00004b96/40259528/00000001)
> Jun 24 01:50:42 srv007 kernel: [5753609.447181] nfsv4 compound op
> #1/7: 22 (OP_PUTFH)
> Jun 24 01:50:42 srv007 kernel: [5753609.447185] nfsd: fh_verify(28:
> 00070001 00020001 00000000 53c0b8df a948fcb9 475e2cba)
> Jun 24 01:50:42 srv007 kernel: [5753609.447185] renewing client
> (clientid 51ab76cb/00004b96)
> Jun 24 01:50:42 srv007 kernel: [5753609.447187] nfsv4 compound op
> ffff88000813f078 opcnt 2 #2: 20: status 10025
> Jun 24 01:50:42 srv007 kernel: [5753609.447189] nfsv4 compound returned 10025
>
> NFSD stacks are like:
> [<ffffffffa022e765>] nfs4_lock_state+0x15/0x40 [nfsd]
> [<ffffffffa02234f4>] nfsd4_open+0xb4/0x440 [nfsd]
> [<ffffffffa0221bc8>] nfsd4_proc_compound+0x518/0x6d0 [nfsd]
> [<ffffffffa020fa0b>] nfsd_dispatch+0xeb/0x230 [nfsd]
> [<ffffffffa0131d95>] svc_process_common+0x345/0x690 [sunrpc]
> [<ffffffffa01321e2>] svc_process+0x102/0x150 [sunrpc]
> [<ffffffffa020f0bd>] nfsd+0xbd/0x160 [nfsd]
> [<ffffffff8108a59c>] kthread+0x8c/0xa0
> [<ffffffff81667db4>] kernel_thread_helper+0x4/0x10
> [<ffffffffffffffff>] 0xffffffffffffffff
>
> I couldnt exactly capture the running thread, but it appears that one
> thread of the NFSD thread pool runs & detects a bad-state-id & returns
> back.
>
> Is this a known issue or any help on how to dig in further is greatly
> appreciated.
>
> Thanks.
>
> --Shyam
