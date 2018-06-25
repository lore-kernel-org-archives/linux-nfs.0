Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:54284 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754918AbeFYRDS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2018 13:03:18 -0400
Subject: Re: [PATCH 2/2] nfsd: return ENOSPC if unable to allocate a session
 slot
To: Chuck Lever <chucklever@gmail.com>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
References: <1529598933-16506-1-git-send-email-manjunath.b.patil@oracle.com>
 <1529598933-16506-2-git-send-email-manjunath.b.patil@oracle.com>
 <20180622175416.GA7119@fieldses.org>
 <148E65CF-D3D4-4E43-A190-822C5F7824B9@gmail.com>
 <180d25ce5474539f15a84a23258d15c71ec11ad9.camel@hammerspace.com>
 <B3031B82-6CCC-4A11-938F-AD052CC360CD@gmail.com>
 <d60d8566d215a70d63a31faf8da9ea9126324fa9.camel@hammerspace.com>
 <1131E2BE-162D-45BB-BC24-49097733ACC3@gmail.com>
From: Manjunath Patil <manjunath.b.patil@oracle.com>
Message-ID: <3ab9ddf4-f51a-12f0-8d33-256c2bded552@oracle.com>
Date: Mon, 25 Jun 2018 10:03:10 -0700
MIME-Version: 1.0
In-Reply-To: <1131E2BE-162D-45BB-BC24-49097733ACC3@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/25/2018 8:39 AM, Chuck Lever wrote:

>
>> On Jun 24, 2018, at 9:56 AM, Trond Myklebust <trondmy@hammerspace.com> wrote:
>>
>> On Sat, 2018-06-23 at 15:00 -0400, Chuck Lever wrote:
>>>> On Jun 22, 2018, at 6:31 PM, Trond Myklebust <trondmy@hammerspace.c
>>>> om> wrote:
>>>>
>>>> On Fri, 2018-06-22 at 17:49 -0400, Chuck Lever wrote:
>>>>> Hi Bruce-
>>>>>
>>>>>
>>>>>> On Jun 22, 2018, at 1:54 PM, J. Bruce Fields <bfields@fieldses.
>>>>>> org>
>>>>>> wrote:
>>>>>>
>>>>>> On Thu, Jun 21, 2018 at 04:35:33PM +0000, Manjunath Patil
>>>>>> wrote:
>>>>>>> Presently nfserr_jukebox is being returned by nfsd for
>>>>>>> create_session
>>>>>>> request if server is unable to allocate a session slot. This
>>>>>>> may
>>>>>>> be
>>>>>>> treated as NFS4ERR_DELAY by the clients and which may
>>>>>>> continue to
>>>>>>> re-try
>>>>>>> create_session in loop leading NFSv4.1+ mounts in hung state.
>>>>>>> nfsd
>>>>>>> should return nfserr_nospc in this case as per
>>>>>>> rfc5661(section-
>>>>>>> 18.36.4
>>>>>>> subpoint 4. Session creation).
>>>>>> I don't think the spec actually gives us an error that we can
>>>>>> use
>>>>>> to say
>>>>>> a CREATE_SESSION failed permanently for lack of resources.
>>>>> The current situation is that the server replies NFS4ERR_DELAY,
>>>>> and the client retries indefinitely. The goal is to let the
>>>>> client choose whether it wants to try the CREATE_SESSION again,
>>>>> try a different NFS version, or fail the mount request.
>>>>>
>>>>> Bill and I both looked at this section of RFC 5661. It seems to
>>>>> us that the use of NFS4ERR_NOSPC is appropriate and unambiguous
>>>>> in this situation, and it is an allowed status for the
>>>>> CREATE_SESSION operation. NFS4ERR_DELAY OTOH is not helpful.
>>>> There are a range of errors which we may need to handle by
>>>> destroying
>>>> the session, and then creating a new one (mainly the ones where the
>>>> client and server slot handling get out of sync). That's why
>>>> returning
>>>> NFS4ERR_NOSPC in response to CREATE_SESSION is unhelpful, and is
>>>> why
>>>> the only sane response by the client will be to treat it as a
>>>> temporary
>>>> error.
>>>> IOW: these patches will not be acceptable, even with a rewrite, as
>>>> they
>>>> are based on a flawed assumption.
>>> Fair enough. We're not attached to any particular solution/fix.
>>>
>>> So let's take "recovery of an active mount" out of the picture
>>> for a moment.
>>>
>>> The narrow problem is behavioral: during initial contact with an
>>> unfamiliar server, the server can hold off a client indefinitely
>>> by sending NFS4ERR_DELAY for example until another client unmounts.
>>> We want to find a way to allow clients to make progress when a
>>> server is short of resources.
>>>
>>> It appears that the mount(2) system call does not return as long
>>> as the server is still returning NFS4ERR_DELAY. Possibly user
>>> space is never given an opportunity to stop retrying, and thus
>>> mount.nfs gets stuck.
>>>
>>> It appears that DELAY is OK for EXCHANGE_ID too. So if a server
>>> decides to return DELAY to EXCHANGE_ID, I wonder if our client's
>>> trunking detection would be hamstrung by one bad server...
>> The 'mount' program has the 'retry' option in order to set a timeout
>> for the mount operation itself. Is that option not working correctly?
> Manjunath will need to confirm that, but my understanding is that
> mount.nfs is not regaining control when the server returns DELAY
> to CREATE_SESSION. My conclusion was that mount(2) is not returning.
>
yes. this is true. Even with setting a retry the mount calls blocks on 
client side indefinitely.
On the wire I can see CREATE_SESSION and NFS4ERR_DELAY exchanges 
happening continuously.

I am not sure about the effects, but a NFSv4.0 mount to same server at 
this moment succeeds.

More information:
...
2144  09:54:32.473054 write(1, "mount.nfs: trying text-based opt"..., 
113) = 113 <0.000337>
2144  09:54:32.473468 mount("10.211.47.123:/exports", "/NFSMNT", "nfs", 
0, "retry=1,vers=4,minorversion=1,ad"... <unfinished ...>
2143  09:56:42.253947 <... wait4 resumed> 0x7fffb2e13ec8, 0, NULL) = ? 
ERESTARTSYS (To be restarted if SA_RESTART is set) <129.800036>
2143  09:56:42.254142 --- SIGINT {si_signo=SIGINT, si_code=SI_KERNEL} ---
...

The client mount call hangs here -
[<ffffffffa05204d2>] nfs_wait_client_init_complete+0x52/0xc0 [nfs]
[<ffffffffa05872ed>] nfs41_discover_server_trunking+0x6d/0xb0 [nfsv4]
[<ffffffffa0587802>] nfs4_discover_server_trunking+0x82/0x2e0 [nfsv4]
[<ffffffffa058f8d6>] nfs4_init_client+0x136/0x300 [nfsv4]
[<ffffffffa05210bf>] nfs_get_client+0x24f/0x2f0 [nfs]
[<ffffffffa058eeef>] nfs4_set_client+0x9f/0xf0 [nfsv4]
[<ffffffffa059039e>] nfs4_create_server+0x13e/0x3b0 [nfsv4]
[<ffffffffa05881b2>] nfs4_remote_mount+0x32/0x60 [nfsv4]
[<ffffffff8121df3e>] mount_fs+0x3e/0x180
[<ffffffff8123a6db>] vfs_kern_mount+0x6b/0x110
[<ffffffffa05880d6>] nfs_do_root_mount+0x86/0xc0 [nfsv4]
[<ffffffffa05884c4>] nfs4_try_mount+0x44/0xc0 [nfsv4]
[<ffffffffa052ed6b>] nfs_fs_mount+0x4cb/0xda0 [nfs]
[<ffffffff8121df3e>] mount_fs+0x3e/0x180
[<ffffffff8123a6db>] vfs_kern_mount+0x6b/0x110
[<ffffffff8123d5c1>] do_mount+0x251/0xcf0
[<ffffffff8123e3a2>] SyS_mount+0xa2/0x110
[<ffffffff81751f4b>] tracesys_phase2+0x6d/0x72
[<ffffffffffffffff>] 0xffffffffffffffff

I have a setup to reproduce this. If you need any more info, please let 
me know.

-Thanks,
Manjunath
>> If so, we should definitely fix that.
> My recollection is that mount.nfs polls, it does not set a timer
> signal. So it will call mount(2) repeatedly until either "retry"
> minutes has passed, or mount(2) succeeds. I don't think it will
> deal with mount(2) not returning, but I could be wrong about that.
>
> My preference would be to make the kernel more reliable (ie mount(2)
> fails immediately in this case). That gives mount.nfs some time to
> try other things (like, try the original mount again after a few
> moments, or fall back to NFSv4.0, or fail).
>
> We don't want mount.nfs to wait for the full retry= while doing
> nothing else. That would make this particular failure mode behave
> differently than all the other modes we have had, historically, IIUC.
>
> Also, I agree with Bruce that the server should make CREATE_SESSION
> less likely to fail. That would also benefit state recovery.
>
>
>> We might also want to look into making it take values < 1 minute. That
>> could be accomplished either by extending the syntax of the 'retry'
>> option (e.g.: 'retry=<minutes>:<seconds>') or by adding a new option
>> (e.g. 'sretry=<seconds>').
>>
>> It would then be up to the caller of mount to decide the policy of what
>> to do after a timeout.
> I agree that the caller of mount(2) should be allowed to provide the
> policy.
>
>
>> Renegotiation downward to NFSv3 might be an
>> option, but it's not something that most people want to do in the case
>> where there are lots of clients competing for resources since that's
>> precisely the regime where the NFSv3 DRC scheme breaks down (lots of
>> disconnections, combined with a high turnover of DRC slots).
> --
> Chuck Lever
> chucklever@gmail.com
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

