Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:39837 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710Ab3JaVWs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 17:22:48 -0400
Received: by mail-pd0-f175.google.com with SMTP id g10so2927192pdj.6
        for <linux-nfs@vger.kernel.org>; Thu, 31 Oct 2013 14:22:48 -0700 (PDT)
Received: from [128.95.176.96] (moist.atmos.washington.edu. [128.95.176.96])
        by mx.google.com with ESMTPSA id i6sm6309599pbc.1.2013.10.31.14.22.47
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 31 Oct 2013 14:22:47 -0700 (PDT)
Message-ID: <5272CA26.8010304@uw.edu>
Date: Thu, 31 Oct 2013 14:22:46 -0700
From: Harry Edmon <harry@uw.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: clientid is in use
References: <51FBDB14.4040801@uw.edu> <BE9C4EAA-B835-4021-86C2-D91F66BFF7C8@oracle.com>
In-Reply-To: <BE9C4EAA-B835-4021-86C2-D91F66BFF7C8@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/04/13 12:20, Chuck Lever wrote:
> On Aug 2, 2013, at 12:15 PM, Harry Edmon <harry@uw.edu> wrote:
>
>> Occasionally I am seeing the following in our kernel log on a NFS client:
>>
>> [2321389.137595] NFS: Server enkf reports our clientid is in use
>> [2321389.137615] NFS: state manager: lease expired failed on NFSv4 server enkf with error 1
>>
>> The result is that the read of the file in question fails.   This occurs for multiple kernel versions on multiple machines.  Anyone have an idea how I should start debugging this?  How is the clientid calculated/assigned?
> It depends on the kernel version.  You can look in fs/nfs/nfs4proc.c for the nfs4_proc_setclientid function.
>
I am still occasionally seeing this error.   The last time was with the NFS client and server both running kernel 3.11.6.   The message was on the client.   Here is the mount info from /proc/mounts:

margaret:/home/margaret/margaret /home/disk/margaret nfs4
rw,relatime,vers=4.0,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=140.142.113.26,local_lock=none,addr=128.95.89.30
0 0

I am still looking for ideas on how to debug this.

-- 
Dr. Harry Edmon
harry@uw.edu, 206-543-0547, FAX: 206-543-0308
Director of IT, College of the Environment and
Director of Computing, Dept of Atmospheric Sciences
University of Washington, Box 351640, Seattle, WA 98195-1640
