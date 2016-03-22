Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:42344 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156AbcCVVwu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Mar 2016 17:52:50 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Subject: Re: [PATCH] nfs: add nfs IPv6 rdma6 mount option support
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAHQdGtSBamfGKNHDztCwE5JQcwwAiw66KJ0NgsTuSffCOBtF6Q@mail.gmail.com>
Date: Tue, 22 Mar 2016 17:52:38 -0400
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Shirley Ma <shirley.ma@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>, Leon Romanovsky <leon@leon.nu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9414CE65-D41C-4497-9111-BCAB54FB6C7B@oracle.com>
References: <56E9A650.7060409@oracle.com> <56F19F28.9020504@Netapp.com> <D0E8CDCF-19AE-444D-87D6-4C2730318A1A@oracle.com> <CAHQdGtSBamfGKNHDztCwE5JQcwwAiw66KJ0NgsTuSffCOBtF6Q@mail.gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Mar 22, 2016, at 5:46 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> On Tue, Mar 22, 2016 at 5:24 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> On Mar 22, 2016, at 3:38 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>> 
>>> Hi Shirley,
>>> 
>>> Sorry for the delay in looking at this patch.  Comments are below:
>>> 
>>> On 03/16/2016 02:30 PM, Shirley Ma wrote:
>>>> Add rdma6 option to support NFS/RDMA IPv6.
>>>> 
>>>> Signed-off-by: Shirley Ma <shirley.ma@oracle.com>
>>> 
>>> Can you add a little more to the patch description to describe when RDMA with IPv6 would be used?
>>> 
>>>> ---
>>>> 
>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>> index f126828..62a55d0 100644
>>>> --- a/fs/nfs/super.c
>>>> +++ b/fs/nfs/super.c
>>>> @@ -191,6 +191,7 @@ static const match_table_t nfs_mount_option_tokens = {
>>>> 
>>>> enum {
>>>>     Opt_xprt_udp, Opt_xprt_udp6, Opt_xprt_tcp, Opt_xprt_tcp6, Opt_xprt_rdma,
>>>> +    Opt_xprt_rdma6,
>>>> 
>>>>     Opt_xprt_err
>>>> };
>>>> @@ -201,6 +202,7 @@ static const match_table_t nfs_xprt_protocol_tokens = {
>>>>     { Opt_xprt_tcp, "tcp" },
>>>>     { Opt_xprt_tcp6, "tcp6" },
>>>>     { Opt_xprt_rdma, "rdma" },
>>>> +    { Opt_xprt_rdma6, "rdma6" },
>>>> 
>>>>     { Opt_xprt_err, NULL }
>>>> };
>>>> @@ -1456,6 +1458,8 @@ static int nfs_parse_mount_options(char *raw,
>>>>                             mnt->flags |= NFS_MOUNT_TCP;
>>>>                             mnt->nfs_server.protocol = XPRT_TRANSPORT_TCP;
>>>>                             break;
>>>> +                    case Opt_xprt_rdma6:
>>>> +                            protofamily = AF_INET6;
>>>>                     case Opt_xprt_rdma:
>>>>                             /* vector side protocols to TCP */
>>>>                             mnt->flags |= NFS_MOUNT_TCP;
>>>> @@ -1490,6 +1494,8 @@ static int nfs_parse_mount_options(char *raw,
>>>>                     case Opt_xprt_tcp:
>>>>                             mnt->mount_server.protocol = XPRT_TRANSPORT_TCP;
>>>>                             break;
>>>> +                    case Opt_xprt_rdma6:
>>>> +                            mountfamily = AF_INET6;
>>>>                     case Opt_xprt_rdma: /* not used for side protocols */
>>>                                           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>>> Do we need to be setting mountfamily here?  The comment next to Opt_xprt_rdma makes it sound like this code doesn't apply to RDMA.
>> 
>> I wondered this too.
>> 
>> But what's going on is that for NFSv3 on RDMA, when IPv6 is
>> used for the main protocol, IPv6 needs to be used for the
>> mount protocol as well, even though it is going over TCP.
> 
> It causes nfs_mount_parse_options to immediately stop further parsing
> and return '0' == error encountered. The mount is supposed to fail in
> that case.

Ah, a break; is needed there too.

--
Chuck Lever



