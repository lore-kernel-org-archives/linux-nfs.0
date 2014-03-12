Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752771AbaCLNLv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Mar 2014 09:11:51 -0400
Message-ID: <53205D0C.1090807@RedHat.com>
Date: Wed, 12 Mar 2014 09:11:40 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: Brown Neil <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>,
        Dr Fields James Bruce <bfields@fieldses.org>,
        Lever Charles Edward <chuck.lever@oracle.com>,
        Carsten Ziepke <kieltux@gmail.com>
Subject: Re: [PATCH - v2] mount.nfs: Fix fallback from tcp to udp
References: <20140224142349.784345f9@notabene.brown> <531E2E3F.2020805@RedHat.com> <20140311090124.05409b1b@notabene.brown> <531F2334.2030203@RedHat.com> <20140312163803.0e911784@notabene.brown> <BAE0F586-4E03-43EB-AC7F-81123D757BDE@primarydata.com> <53203D97.6090005@RedHat.com> <0AC6E29F-B377-4EE0-9599-26A72A8F85DA@primarydata.com> <53205C91.3080603@RedHat.com>
In-Reply-To: <53205C91.3080603@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/12/2014 09:09 AM, Steve Dickson wrote:
> 
> 
> On 03/12/2014 07:22 AM, Trond Myklebust wrote:
>>
>> On Mar 12, 2014, at 6:57, Steve Dickson <SteveD@redhat.com> wrote:
>>
>>>
>>>
>>> On 03/12/2014 05:15 AM, Trond Myklebust wrote:
>>>>
>>>> On Mar 12, 2014, at 1:38, NeilBrown <neilb@suse.de> wrote:
>>>>
>>>>> On Tue, 11 Mar 2014 10:52:36 -0400 Steve Dickson <SteveD@redhat.com> wrote:
>>>>>
>>>>>> On 03/10/2014 06:01 PM, NeilBrown wrote:
>>>>>>>
>>>>>>> With  a 3.11.10 client talking to a 3.2.0 server I run
>>>>>>> rpc.nfsd 0
>>>>>>> rpc.nfsd -T -N4
>>>>>>> on the server, then
>>>>>>> rpcinfo -p SERVER | grep nfs
>>>>>>> shows
>>>>>>>   100003    2   udp   2049  nfs
>>>>>>>   100003    3   udp   2049  nfs
>>>>>>>   100227    2   udp   2049  nfs_acl
>>>>>>>   100227    3   udp   2049  nfs_acl
>>>>>>>
>>>>>>> On client I run
>>>>>>>   mount -v SERVER:/PATH /mnt
>>>>>>> and I get
>>>>>>> mount.nfs: trying text-based options 'vers=4,addr=192.168.1.3,clientaddr=192.168.1.2'
>>>>>>> mount.nfs: mount(2): Connection refused
>>>>>>>
>>>>>>> repeating ever 10 seconds or so.  It eventually times out after 2 minutes.
>>>>>>>
>>>>>>> Same client to a 3.10 server I get the same behaviour.
>>>>>>> 3.2.0 client and 3.10 server, same behaviour again.
>>>>>>>
>>>>>>> I have noticed that sometimes when I stop the NFS server the registration
>>>>>>> with rpcbind doesn't go away.  Not often, but sometimes.  I wonder if that
>>>>>>> could be confusing something?  Can you check that nfsv4 has been
>>>>>>> de-registered from rpcbind?
>>>>>>>
>>>>>>> I note you are getting the error:
>>>>>>>
>>>>>>>> mount.nfs: portmap query failed: RPC: Remote system error - Connection refused
>>>>>>>
>>>>>>> This seems to suggest that rpcbind isn't running.  Yet when I kill rpcbind
>>>>>>> and try a v3 mount I get
>>>>>>>
>>>>>>> mount.nfs: portmap query failed: RPC: Unable to receive - Connection refused
>>>>>>>
>>>>>>> which is slightly different, so presumably there is a different cause in your
>>>>>>> case.
>>>>>>>
>>>>>>> Maybe you could turn on some rpcdebug tracing to see what is happening?
>>>>>> Ok... I had to dial back my client to an older kernel (3.12)
>>>>>> to start seeing what you were seeing... 
>>>>>>
>>>>>> I would make one change and one comment... The change I would
>>>>>> like to make (I'll re-post it) is to ping the server to see
>>>>>> if v4 came up instead of asking rpcbind if its registered. 
>>>>>> Code wise I think it cleaner and quicker plus I'm not sure
>>>>>> its a good idea to tie v4 and rpcbind together... 
>>>>>
>>>>> My logic was that if rpcbind was running at all, then any v4 server should
>>>>> register with it.  It would seem odd for rpcbind to report "v2 or v3" but for
>>>>> v4 to be running anyway.
>>>>> However I don't object in principle to your approach.
>>>>> I'll have a look at the code.
>>>>>
>>>>>
>>>>>>
>>>>>> My comment is this... This code become obsolete with the 3.13
>>>>>> kernel because the kernel never returns the timeout or the
>>>>>> ECONNREFUSED... The mount just spins in the kernel until
>>>>>> interrupted. 
>>>>>
>>>>> This sounds like a regression to me.  For a systemcall that used to fail to
>>>>> now hang sounds like an API change, and we usually discourage those.
>>>>>
>>>>> Can it be fixed?  Trond?
>>>>
>>>> Can someone please provide a test case that confirms that there has been such a change? 
>>> On the server:
>>> rpc.nfsd 0
>>> rpc.nfsd -N4
>>>
>>> On the client 
>>> mount <server>:/export /mnt
>>>
>>> I have a mount hanging/spinning since yesterday 
>>> 19178 pts/2    D+     0:26 /sbin/mount.nfs fedora:/home /mnt/home -v -o rw
>>>
>>> A stack dump from crash:
>>> PID: 19178    TASK: ffff8800ba2b41a0  CPU: 0   COMMAND: "mount.nfs"
>>> #0 [ffff8800b93115f8] __schedule at ffffffff815f0c3d
>>> #1 [ffff8800b9311660] schedule at ffffffff815f1179
>>> #2 [ffff8800b9311670] rpc_wait_bit_killable at ffffffffa03f7a35 [sunrpc]
>>> #3 [ffff8800b9311688] __wait_on_bit at ffffffff815ef200
>>> #4 [ffff8800b93116c8] out_of_line_wait_on_bit at ffffffff815ef2b7
>>> #5 [ffff8800b9311738] __rpc_execute at ffffffffa03f890a [sunrpc]
>>> #6 [ffff8800b9311798] rpc_execute at ffffffffa03f9fce [sunrpc]
>>> #7 [ffff8800b93117c8] rpc_run_task at ffffffffa03f01c0 [sunrpc]
>>> #8 [ffff8800b93117e8] rpc_call_sync at ffffffffa03f0230 [sunrpc]
>>> #9 [ffff8800b9311840] nfs4_proc_setclientid at ffffffffa06c9c49 [nfsv4]
>>> #10 [ffff8800b9311988] nfs40_discover_server_trunking at ffffffffa06d8489 [nfsv4]
>>> #11 [ffff8800b93119d0] nfs4_discover_server_trunking at ffffffffa06daf2d [nfsv4]
>>> #12 [ffff8800b9311a28] nfs4_init_client at ffffffffa06e29a4 [nfsv4]
>>> #13 [ffff8800b9311b20] nfs_get_client at ffffffffa06816ba [nfs]
>>> #14 [ffff8800b9311b80] nfs4_set_client at ffffffffa06e1fb0 [nfsv4]
>>> #15 [ffff8800b9311c00] nfs4_create_server at ffffffffa06e34ce [nfsv4]
>>> #16 [ffff8800b9311c88] nfs4_remote_mount at ffffffffa06db90e [nfsv4]
>>> #17 [ffff8800b9311cb0] mount_fs at ffffffff811b3c89
>>> #18 [ffff8800b9311cf8] vfs_kern_mount at ffffffff811cea8f
>>> #19 [ffff8800b9311d30] nfs_do_root_mount at ffffffffa06db836 [nfsv4]
>>> #20 [ffff8800b9311d70] nfs4_try_mount at ffffffffa06dbc24 [nfsv4]
>>> #21 [ffff8800b9311da0] nfs_fs_mount at ffffffffa068dcc5 [nfs]
>>> #22 [ffff8800b9311e28] mount_fs at ffffffff811b3c89
>>> #23 [ffff8800b9311e70] vfs_kern_mount at ffffffff811cea8f
>>> #24 [ffff8800b9311ea8] do_mount at ffffffff811d0e3e
>>> #25 [ffff8800b9311f28] sys_mount at ffffffff811d16b6
>>> #26 [ffff8800b9311f80] system_call_fastpath at ffffffff815fc0d9
>>>
>>>
>>>> I would expect the timeouts to have changed due to the NFSv4 trunking detection (which is 
>>>> exactly why it is wrong to rely on the kernel timeouts here anyway), but I would not expect 
>>>> the kernel to never time out at all.
>>> It appears it started with 3.13 kernels... The above stack is from a 3.14-ish client. 
>>>
>>
>> Which patch caused the behaviour to change?
> IDK.... I just know 3.12 (f19) kernel does return timeouts and 3.13 (f20) do not....
This goes for  a 3.14 kernels as well....

steved
