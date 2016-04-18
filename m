Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:36826 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbcDRT6M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Apr 2016 15:58:12 -0400
Received: by mail-ob0-f171.google.com with SMTP id j9so102661698obd.3
        for <linux-nfs@vger.kernel.org>; Mon, 18 Apr 2016 12:58:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460718977.9124.1.camel@poochiereds.net>
References: <loom.20160414T205732-249@post.gmane.org>
	<alpine.OSX.2.19.9992.1604141506460.55780@planck>
	<CAOiTGHmsmwLsA9wOzpVi50YG4=C9Cd80Tg=e1JCJLjwXxj9k4g@mail.gmail.com>
	<1460718977.9124.1.camel@poochiereds.net>
Date: Mon, 18 Apr 2016 14:58:11 -0500
Message-ID: <CAOiTGHkojJ=Er9Tk-xVwB=h2NJf82aWk2u20+1GD_XVShHJO1w@mail.gmail.com>
Subject: Re: What is a 10.10.10.20-man process?
From: Ziemowit Pierzycki <ziemowit@pierzycki.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is interesting.  Sniffing the network shows:

14:57:05.802390 IP hypervisor3-bus.843 > netapp-bus.nfs: Flags [.],
ack 193, win 58, length 0
14:57:10.802218 IP hypervisor3-bus.843 > netapp-bus.nfs: Flags [P.],
seq 464:580, ack 193, win 58, length 116: NFS request xid 2773655640
112 getattr [|nfs]
14:57:10.802321 IP netapp-bus.nfs > hypervisor3-bus.843: Flags [P.],
seq 193:241, ack 580, win 33580, length 48: NFS reply xid 2773655640
reply ok 44 getattr ERROR: unk 10011
14:57:10.802335 IP hypervisor3-bus.843 > netapp-bus.nfs: Flags [.],
ack 241, win 58, length 0

I turned on some logging for rpc and nfs:

Apr 18 14:49:55 hypervisor3 kernel: nfs4_renew_state: start
Apr 18 14:49:55 hypervisor3 kernel: RPC:       new task initialized,
procpid 30181
Apr 18 14:49:55 hypervisor3 kernel: RPC:       allocated task ffff880aa3b67c00
Apr 18 14:49:55 hypervisor3 kernel: nfs4_renew_state: done
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 __rpc_execute flags=0x5281
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_start nfs4 proc
RENEW (async)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_reserve (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 reserved req
ffff883f4de15c00 xid 4e52a058
Apr 18 14:49:55 hypervisor3 kernel: RPC:
wake_up_first(ffff883f65d4c990 "xprt_sending")
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_reserveresult (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_refresh (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 refreshing UNIX cred
ffff883f6637e300
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_refreshresult (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_allocate (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 allocated buffer of
size 444 at ffff8841c052d000
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_bind (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_connect xprt
ffff883f65d4c800 is connected
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_transmit (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 xprt_prepare_transmit
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 rpc_xdr_encode (status 0)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 marshaling UNIX cred
ffff883f6637e300
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 using AUTH_UNIX cred
ffff883f6637e300 to wrap rpc data
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 xprt_transmit(116)
Apr 18 14:49:55 hypervisor3 kernel: RPC:       xs_tcp_send_request(116) = 0
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 xmit complete
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 sleep_on(queue
"xprt_pending" time 13230578520)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 added to queue
ffff883f65d4ca58 "xprt_pending"
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 setting alarm for 60000 ms
Apr 18 14:49:55 hypervisor3 kernel: RPC:
wake_up_first(ffff883f65d4c990 "xprt_sending")
Apr 18 14:49:55 hypervisor3 kernel: RPC:       xs_tcp_data_ready...
Apr 18 14:49:55 hypervisor3 kernel: RPC:       xs_tcp_data_recv started
Apr 18 14:49:55 hypervisor3 kernel: RPC:       reading TCP record
fragment of length 44
Apr 18 14:49:55 hypervisor3 kernel: RPC:       reading XID (4 bytes)
Apr 18 14:49:55 hypervisor3 kernel: RPC:       reading reply for XID 4e52a058
Apr 18 14:49:55 hypervisor3 kernel: RPC:       reading CALL/REPLY flag (4 bytes)
Apr 18 14:49:55 hypervisor3 kernel: RPC:       read reply XID 4e52a058
Apr 18 14:49:55 hypervisor3 kernel: RPC:       XID 4e52a058 read 36 bytes
Apr 18 14:49:55 hypervisor3 kernel: RPC:       xprt =
ffff883f65d4c800, tcp_copied = 44, tcp_offset = 44, tcp_reclen = 44
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 xid 4e52a058 complete
(44 bytes received)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 __rpc_wake_up_task (now
13230578520)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 disabling timer
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 removed from queue
ffff883f65d4ca58 "xprt_pending"
Apr 18 14:49:55 hypervisor3 kernel: RPC:       __rpc_wake_up_task done
Apr 18 14:49:55 hypervisor3 kernel: RPC:       xs_tcp_data_recv done
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 __rpc_execute flags=0x5a81
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_status (status 44)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_decode (status 44)
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 validating UNIX cred
ffff883f6637e300
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 using AUTH_UNIX cred
ffff883f6637e300 to unwrap rpc data
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 call_decode result -10011
Apr 18 14:49:55 hypervisor3 kernel: nfs4_schedule_lease_recovery:
scheduling lease recovery for server hypervisor3-bus
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 return 0, status -10011
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 release task
Apr 18 14:49:55 hypervisor3 kernel: RPC:       freeing buffer of size
444 at ffff8841c052d000
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 release request ffff883f4de15c00
Apr 18 14:49:55 hypervisor3 kernel: RPC:
wake_up_first(ffff883f65d4cb20 "xprt_backlog")
Apr 18 14:49:55 hypervisor3 kernel: RPC:
rpc_release_client(ffff883f64653600)
Apr 18 14:49:55 hypervisor3 kernel: nfs4_schedule_state_renewal:
requeueing work. Lease period = 5
Apr 18 14:49:55 hypervisor3 kernel: --> nfs_put_client({4})
Apr 18 14:49:55 hypervisor3 kernel: RPC:  8269 freeing task

Is this an authentication issue on the NFS server (Netapp)?

On Fri, Apr 15, 2016 at 6:16 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Thu, 2016-04-14 at 14:15 -0500, Ziemowit Pierzycki wrote:
>> [<ffffffffa012d158>] rpc_wait_bit_killable+0x38/0x80 [sunrpc]
>> [<ffffffffa012d11d>] __rpc_wait_for_completion_task+0x2d/0x30
>> [sunrpc]
>> [<ffffffffa05caf30>] nfs4_run_open_task+0x130/0x1a0 [nfsv4]
>> [<ffffffffa05cd77d>] nfs4_open_recover_helper+0x16d/0x230 [nfsv4]
>> [<ffffffffa05cd875>] nfs4_open_recover+0x35/0xb0 [nfsv4]
>> [<ffffffffa05cff5d>] nfs4_open_expired.isra.60+0xcd/0x180 [nfsv4]
>> [<ffffffffa05d003e>] nfs40_open_expired+0x2e/0x40 [nfsv4]
>> [<ffffffffa05e3805>] nfs4_do_reclaim+0x175/0x5f0 [nfsv4]
>> [<ffffffffa05e416e>] nfs4_run_state_manager+0x4ee/0x7d0 [nfsv4]
>> [<ffffffff810bc8b8>] kthread+0xd8/0xf0
>> [<ffffffff8177999f>] ret_from_fork+0x3f/0x70
>> [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> Waiting for something to complete but it can't?
>>
>
> Yes. That stack means that it's trying to reclaim an open file (on
> NFSv4.0), and is waiting on the reply.
>
>> On Thu, Apr 14, 2016 at 2:08 PM, Benjamin Coddington
>> <bcodding@redhat.com> wrote:
>> >
>> >
>> > On Thu, 14 Apr 2016, Ziemowit PIerzycki wrote:
>> >
>> > >
>> > > I have a strange issue when NFS4 mounts to a Netapp filer freeze
>> > > on my Linux
>> > > KVMs.  Looking over few things I noticed a process "10.10.10.20-
>> > > man" is in D
>> > > state but I can't find anything information about it.  Mainly
>> > > because
>> > > 10.10.10.20 is the IP of the filer and searching for "-man" is
>> > > too generic.
>> > >
>> > > Why would this process be frozen?
>> > This is the nfs4 state manager process.  What's in the file:
>> > /proc/<pid of that process>/stack
>> >
>> > Ben
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Jeff Layton <jlayton@poochiereds.net>
>
