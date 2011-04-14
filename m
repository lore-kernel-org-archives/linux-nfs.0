Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:44862 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab1DNVbC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2011 17:31:02 -0400
Message-ID: <4DA76790.8040909@suse.cz>
Date: Thu, 14 Apr 2011 23:30:56 +0200
From: Jiri Slaby <jslaby@suse.cz>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Bryan Schumaker <bjschuma@netapp.com>, Jiri Slaby <jirislaby@gmail.com>,
        linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
        mm-commits@vger.kernel.org, ML netdev <netdev@vger.kernel.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>	 <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org>	 <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>	 <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>	 <4DA48EB0.40600@netapp.com>  <4DA4946D.5020403@suse.cz>	 <1302633088.4801.48.camel@lade.trondhjem.org> <4DA49B49.1020005@suse.cz>	 <4DA49D3A.7090800@netapp.com> <4DA49F7F.8060005@suse.cz>	 <4DA60AB9.1050104@netapp.com>  <4DA75AFC.3040000@suse.cz> <1302816095.24028.87.camel@lade.trondhjem.org>
In-Reply-To: <1302816095.24028.87.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/14/2011 11:21 PM, Trond Myklebust wrote:
> On Thu, 2011-04-14 at 22:37 +0200, Jiri Slaby wrote:
>> On 04/13/2011 10:42 PM, Bryan Schumaker wrote:
>>> On 04/12/2011 02:52 PM, Jiri Slaby wrote:
>>>> On 04/12/2011 08:43 PM, Bryan Schumaker wrote:
>>>>> On 04/12/2011 02:34 PM, Jiri Slaby wrote:
>>>>>> On 04/12/2011 08:31 PM, Trond Myklebust wrote:
>>>>>>>> Yes, it fixes the problem. But it waits 15s before it times out. This is
>>>>>>>> inacceptable for automounted NFS dirs.
>>>>>>>
>>>>>>> I'm still confused as to why you are hitting it at all. In the normal
>>>>>>> autonegotiation case, the client should be trying to use AUTH_SYS first
>>>>>>> and then trying rpcsec_gss if and only if that fails.
>>>>>>>
>>>>>>> Are you really exporting a filesystem using AUTH_NULL as the only
>>>>>>> supported flavour?
>>>>>>
>>>>>> I don't know, I connect to a nfs server which is not maintained by me.
>>>>>> It looks like that. How can I find out?
>>>>>
>>>>> If you're not using gss for anything, you could try rmmod-ing rpcsec_gss_krb5 (and other rpcsec_gss_* modules).
>>>>
>>>> I don't have NFS in modules. It's all built-in. And this one is
>>>> unconditionally selected because of CONFIG_NFS_V4.
>>>
>>> Does this patch help?
>>
>> Nope, it makes things even worse:
>> # mount -oro,intr XXX:/yyy /mnt/c/
>> <15s delay here>
>> mount.nfs: access denied by server while mounting XXX:/yyy
>>
>> So in nfs4_proc_get_root I do:
>>   printk("%s: %d %u\n", __func__, i, flav_array[i]);
>>   status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
>>   printk("%s: res=%d\n", __func__, status);
>> and get:
>> [   18.159818] nfs4_proc_get_root: 0 1
>> [   18.214872] nfs4_proc_get_root: res=-1
>> [   18.214875] nfs4_proc_get_root: 1 0
>> [   18.254636] nfs4_proc_get_root: res=-1
>> [   18.254639] nfs4_proc_get_root: 2 390003
>> [   33.252174] RPC: AUTH_GSS upcall timed out.
>> [   33.252177] Please check user daemon is running.
>> [   33.252192] nfs4_proc_get_root: res=-13
>>
>> If I revert that back and do the same:
>> [   28.275569] nfs4_proc_get_root: 0 1
>> [   28.296545] nfs4_proc_get_root: res=-1
>> [   28.296548] nfs4_proc_get_root: 1 390003
>> [   43.296107] RPC: AUTH_GSS upcall timed out.
>> [   43.296108] Please check user daemon is running.
>> [   43.296121] nfs4_proc_get_root: res=-13
>> [   43.296122] nfs4_proc_get_root: 2 0
>> [   43.318201] nfs4_proc_get_root: res=-1
>>
>> I.e. all methods fail. And what matters is the last retval. From NULL it
>> is EPERM, from GSS it is EACCESS. For EPERM, mount(8) falls back to
>> nfs3, for EACCESS it dies terrible death.
> 
> OK. That's good information. Thanks for testing!
> 
> I'm still curious as to why that NFS server is refusing all NFSv4 mounts
> with NFS4ERR_WRONGSEC. Unless NFSv4 really is configured only to export
> the root filesystem with RPCSEC_GSS, then that definitely sounds like a
> bug...

With gssd running if that helps:
[  229.806528] nfs4_proc_get_root: 0 1
[  229.828491] nfs4_proc_get_root: res=-1
[  229.828494] nfs4_proc_get_root: 1 390003
[  229.896994] nfs4_proc_get_root: res=-13
[  229.896997] nfs4_proc_get_root: 2 0
[  229.920344] nfs4_proc_get_root: res=-1

thanks,
-- 
js
suse labs
