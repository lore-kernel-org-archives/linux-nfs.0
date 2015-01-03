Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:64084 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbACVTx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Jan 2015 16:19:53 -0500
Received: by mail-vc0-f179.google.com with SMTP id le20so7717242vcb.10
        for <linux-nfs@vger.kernel.org>; Sat, 03 Jan 2015 13:19:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3BD973EC-26C6-4EBE-BB14-0B8A483543E9@oracle.com>
References: <1420234772-13083-1-git-send-email-trond.myklebust@primarydata.com>
	<7BF7AAE6-8DE2-4664-AFFB-6A84F51F97DC@oracle.com>
	<CAHQdGtQu2f8ULEMFqztuzr2YhdctJLazmGvJZ_PrCcKnwtAbqQ@mail.gmail.com>
	<3BD973EC-26C6-4EBE-BB14-0B8A483543E9@oracle.com>
Date: Sat, 3 Jan 2015 16:19:52 -0500
Message-ID: <CAHQdGtQgEbLtAkfpNtc8uCPpb1u3EoQ4m9ytn=siUZKC_eUryg@mail.gmail.com>
Subject: Re: [PATCH] NFSv4.1: Fix client id trunking on Linux
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 2, 2015 at 6:36 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Jan 2, 2015, at 5:09 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Fri, Jan 2, 2015 at 4:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>> On Jan 2, 2015, at 4:39 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>>>
>>>> Currently, our trunking code will check for session trunking, but will
>>>> fail to detect client id trunking. This is a problem, because it means
>>>> that the client will fail to recognise that the two connections represent
>>>> shared state, even if they do not permit a shared session.
>>>> By removing the check for the server minor id, and only checking the
>>>> major id, we will end up doing the right thing in both cases: we close
>>>> down the new nfs_client and fall back to using the existing one.
>>>
>>> Fair enough.
>>>
>>> Does this detect the case where two concurrent NFSv4.1 mounts
>>> of the same server use different transport protocols?
>>
>> I'm not sure I understand what you mean. The client should completely
>> ignore the transport protocol when doing trunking detection.
>
> Quite right, the problem seems to be earlier than that.
>
> nfs_match_client() checks the transport protocol setting, and
> forces creation of a new struct nfs_client if the transport
> protocol is not the same as an existing and otherwise compatible
> struct nfs_client for the server being mounted.
>
> OK for NFSv2 and NFSv3, which can have a unique struct nfs_clients
> each for UDP, TCP, and RDMA mounts.
>
> For NFSv4, RDMA means the nfs_match_client() check forces the
> creation of a separate struct nfs_client for RDMA and TCP (if
> admin requests both types of mounts).
>
> An RDMA connection and a TCP connection would be created. Both
> connections would send the same nfs_client_id4.
>
> This doesn’t seem to be an issue for non-UCS NFSv4.0, but it
> probably is a problem with UCS.

The problem isn't so much the check in nfs_match_client(). The problem
is rather those same checks in nfs4[01]_walk_client_list().

>> The only
>> thing that it cares about is whether or not the server believes we
>> should be sharing state, in which case the client should fall back to
>> using the existing connection for the new mount point.
>
> While working on the NFSv4.1 on RDMA prototype, I noticed that
> trunking detection would allow concurrent mounts of the same
> server with both RDMA and TCP transports. My hack-neyed attempt
> to fix that was posted back in October:
>
>   http://marc.info/?l=linux-nfs&m=141348837927749&w=2
>
> Your patch very likely addresses the issue for NFSv4.1, but I
> wonder how to do it for NFSv4.0 with UCS (if it is a problem,
> at the time I think I only checked NFSv4.1 behavior).

There is a third problem, and that is what if someone plays with
-omigration or /sys/module/nfs/parameters/nfs4_unique_id after the
server is already mounted. We know that the server will not identify
us as being the same client in that case, and so we should try to
ascertain that we don't create any false positives.
The new patchset (v2) therefore attempts to address all of the above issues.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
