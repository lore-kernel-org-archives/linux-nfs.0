From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] showmount: try v3 before falling back to v1
Date: Wed, 6 Jan 2010 08:37:53 -0500
Message-ID: <E6CB515A-0407-4A1A-B5FC-296529AAAEDD@oracle.com>
References: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com> <4B43A3EF.4080401@RedHat.com> <F262923D-5E5F-403D-86FC-601AD8F464A1@oracle.com> <4B43CA10.8080907@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Dan McGee <dpmcgee@gmail.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:63181 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab0AFNia (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jan 2010 08:38:30 -0500
In-Reply-To: <4B43CA10.8080907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 5, 2010, at 6:24 PM, Steve Dickson wrote:

> On 01/05/2010 05:31 PM, Chuck Lever wrote:
>>
>> On Jan 5, 2010, at 3:41 PM, Steve Dickson wrote:
>>
>>> Revised patch incorporating the code review comments...
>>>
>>> steved.
>>>
>>> commit a96b79f57f49ce5b4d05b6b9da79bdec03b13764
>>> Author: Steve Dickson <steved@redhat.com>
>>> Date:   Tue Jan 5 15:39:00 2010 -0500
>>>
>>>   showmount: Try the highest mount version then fall back to lower  
>>> ones
>>>
>>>   Showmount should try the highest mount version first then fall
>>>   back to the lower ones when the server returns a  
>>> RPC_PROGVERSMISMATCH
>>>   error. The idea being not using the lower mount versions will  
>>> begin
>>>   the process of moving away from NFSv2 support.
>>>
>>>   Signed-off-by: Steve Dickson <steved@redhat.com>
>>>
>>> diff --git a/utils/showmount/showmount.c b/utils/showmount/ 
>>> showmount.c
>>> index 418e8b9..74cf116 100644
>>> --- a/utils/showmount/showmount.c
>>> +++ b/utils/showmount/showmount.c
>>> @@ -78,29 +78,36 @@ static void usage(FILE *fp, int n)
>>>    exit(n);
>>> }
>>>
>>> -static const char *nfs_sm_pgmtbl[] = {
>>> +static const char *mount_pgm_tbl[] = {
>>>    "showmount",
>>>    "mount",
>>>    "mountd",
>>>    NULL,
>>> };
>>>
>>> +static const rpcvers_t mount_vers_tbl[] = {
>>> +    MOUNTVERS_NFSV3,
>>> +    MOUNTVERS_POSIX,
>>> +    MOUNTVERS,
>>> +};
>>> +static const int max_vers_tblsz =
>>> +    (sizeof(mount_vers_tbl)/sizeof(mount_vers_tbl[0]));
>>> +
>>> /*
>>> * Generate an RPC client handle connected to the mountd service
>>> * at @hostname, or die trying.
>>> *
>>> * Supports both AF_INET and AF_INET6 server addresses.
>>> */
>>> -static CLIENT *nfs_get_mount_client(const char *hostname)
>>> +static CLIENT *nfs_get_mount_client(const char *hostname, rpcvers_t
>>> vers)
>>> {
>>> -    rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, nfs_sm_pgmtbl);
>>> +    rpcprog_t program = nfs_getrpcbyname(MOUNTPROG, mount_pgm_tbl);
>>>    CLIENT *client;
>>>
>>> -    client = clnt_create(hostname, program, MOUNTVERS, "tcp");
>>> +    client = clnt_create(hostname, program, vers, "tcp");
>>>    if (client)
>>>        return client;
>>> -
>>> -    client = clnt_create(hostname, program, MOUNTVERS, "udp");
>>> +    client = clnt_create(hostname, program, vers, "udp");
>>>    if (client)
>>>        return client;
>>>
>>> @@ -123,6 +130,7 @@ int main(int argc, char **argv)
>>>    int i;
>>>    int n;
>>>    int maxlen;
>>> +    int unsigned vers=0;
>>>    char **dumpv;
>>>
>>>    program_name = argv[0];
>>> @@ -185,7 +193,8 @@ int main(int argc, char **argv)
>>>        break;
>>>    }
>>>
>>> -    mclient = nfs_get_mount_client(hostname);
>>> +again:
>>> +    mclient = nfs_get_mount_client(hostname, mount_vers_tbl[vers]);
>>>    mclient->cl_auth = authunix_create_default();
>>>    total_timeout.tv_sec = TOTAL_TIMEOUT;
>>>    total_timeout.tv_usec = 0;
>>> @@ -197,6 +206,10 @@ int main(int argc, char **argv)
>>>            (xdrproc_t) xdr_void, NULL,
>>>            (xdrproc_t) xdr_exports, (caddr_t) &exportlist,
>>>            total_timeout);
>>> +        if (clnt_stat == RPC_PROGVERSMISMATCH) {
>>> +            if (++vers <  max_vers_tblsz)
>>> +                goto again;
>>> +        }
>>
>> If you're going to do this, you should destroy the clnt before
>> retrying.  Better yet you can use CLNT_CONTROL() to change the RPC
>> version of the clnt on the fly... that way you don't have to  
>> destroy the
>> clnt and create a new one, which has to try creating both "tcp" and
>> "udp" in some cases, making for a long timeout each time if the  
>> server
>> doesn't support "tcp".
> This is a very short lived command and 99.9% of the time this code  
> will
> not executed... so I guess I was not too worried about opening a  
> couple
> extra fd in the every unlikely case a server does not support v3...

Dude, come on.  How hard is it to add two extra clnt_destroy(3) calls?

What about the potential for additional hangs during retries when  
neither v3 nor TCP is supported?  CLNT_CONTROL() would allow you to  
create the client once, and then reuse it.  I can send you a patch on  
top of this one that does that.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



