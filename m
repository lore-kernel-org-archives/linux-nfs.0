Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38013 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757725AbaCRSrY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Mar 2014 14:47:24 -0400
Message-ID: <532894B9.6090606@RedHat.com>
Date: Tue, 18 Mar 2014 14:47:21 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out correctly
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com> <53286A9D.2020007@RedHat.com> <362845B0-35A4-4DDF-96F6-42582D66334B@primarydata.com> <53288146.4010601@RedHat.com>
In-Reply-To: <53288146.4010601@RedHat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/18/2014 01:24 PM, Steve Dickson wrote:
>> The trunking code's handling of ETIMEDOUT has been there since Linux 3.7 
>> > and hasn’t changed, so I really don’t see how it can have worked at one time before 3.12.
> Maybe it been broken that long.... :-) 
> 
> But here is the obvious loop that stop that hangs a mount forever:
> 
>  #8 [ffff88007a22b7e8] rpc_call_sync at ffffffffa0220210 [sunrpc]
>  #9 [ffff88007a22b840] nfs4_proc_setclientid at ffffffffa0505c49 [nfsv4]
> #10 [ffff88007a22b988] nfs40_discover_server_trunking at ffffffffa0514489 [nfsv4]
> #11 [ffff88007a22b9d0] nfs4_discover_server_trunking at ffffffffa0516f2d [nfsv4]
> #12 [ffff88007a22ba28] nfs4_init_client at ffffffffa051e9a4 [nfsv4]
> #13 [ffff88007a22bb20] nfs_get_client at ffffffffa04bd6ba [nfs]
> #14 [ffff88007a22bb80] nfs4_set_client at ffffffffa051dfb0 [nfsv4]
> #15 [ffff88007a22bc00] nfs4_create_server at ffffffffa051f4ce [nfsv4]
> #16 [ffff88007a22bc88] nfs4_remote_mount at ffffffffa051790e [nfsv4]
> #17 [ffff88007a22bcb0] mount_fs at ffffffff811b3dd9
> 
> The SETCLIENT times out 
>    NFS call  setclientid auth=UNIX, 'Linux NFSv4.0 10.19.60.77/10.19.60.33 tcp'
>    NFS reply setclientid: -110
> 
> The nfs4_discover_server_trunking() retries 
>    NFS: nfs4_discover_server_trunking after status -110, retrying
> 
> The happens when there server is down and so the connections 
> fail with ECONNREFUSED:
>    RPC:     2 call_connect_status (status -111)
> 
> The mount system call never times out in which it did in the past. 
> 
> So who do I get the system call to time out again?
I'm thinking the problem here is the ECONNREFUSED is never
being passed up to the trunking code. The major timeout 
in call_timeout() turns the ECONNREFUSED into a ETIMEDOUT
So the trunking code never know the server is refusing
the connection... 

Why are ECONNREFUSED masked into ETIMEDOUTs? Should the 
ECONNREFUSED passed up?

steved.




> 
> steved.
