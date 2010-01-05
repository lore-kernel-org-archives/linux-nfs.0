From: Dan McGee <dpmcgee@gmail.com>
Subject: Re: [PATCH] showmount: try v3 before falling back to v1
Date: Tue, 5 Jan 2010 15:36:31 -0600
Message-ID: <449c10961001051336xb9fa70fp50805f93785a9d55@mail.gmail.com>
References: <1262655247-16849-1-git-send-email-dpmcgee@gmail.com>
	 <6E89479D-45D6-4C59-9639-7C4B893F2A5E@oracle.com>
	 <4B438712.1080101@RedHat.com>
	 <3F8F085F-E90B-4568-9BB2-F820A7C71A4D@oracle.com>
	 <4B43A328.5000702@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.216.174]:48775 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932173Ab0AEVgc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2010 16:36:32 -0500
Received: by pxi4 with SMTP id 4so12436188pxi.33
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jan 2010 13:36:31 -0800 (PST)
In-Reply-To: <4B43A328.5000702-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 5, 2010 at 2:38 PM, Steve Dickson <SteveD@redhat.com> wrote=
:
> On 01/05/2010 02:23 PM, Chuck Lever wrote:
>>>
>>> Author: Steve Dickson <steved@redhat.com>
>>> Date: =C2=A0 Tue Jan 5 13:29:07 2010 -0500
>>>
>>> =C2=A0 =C2=A0showmount: Try the highest mount version then fall bac=
k to lower ones
>>>
>>> =C2=A0 =C2=A0Showmount should try the highest mount version first t=
hen fall
>>> =C2=A0 =C2=A0back to the lower ones when the server returns a RPC_P=
ROGVERSMISMATCH
>>> =C2=A0 =C2=A0error. The idea being not using the lower mount versio=
ns will begin
>>> =C2=A0 =C2=A0the process of moving away from NFSv2 support.
>>>
>>> =C2=A0 =C2=A0Signed-off-by: Steve Dickson <steved@redhat.com>
>>>
>>> diff --git a/utils/showmount/showmount.c b/utils/showmount/showmoun=
t.c
>>> index 418e8b9..17224a6 100644
>>> --- a/utils/showmount/showmount.c
>>> +++ b/utils/showmount/showmount.c
>>> @@ -85,22 +85,29 @@ static const char *nfs_sm_pgmtbl[] =3D {
>>> =C2=A0 =C2=A0 NULL,
>>> };
>>>
>>> +static const int mount_vers[] =3D {
>>
>> RPC version numbers are rpcvers_t, not int.
> True..
>
>>
>> The array above this one is called "nfs_sm_pgmtbl"... to be consiste=
nt
>> with existing code you should name this one "nfs_sm_verstbl".
>>
>>> + =C2=A0 =C2=A0MOUNTVERS_NFSV3,
>>> + =C2=A0 =C2=A0MOUNTVERS_POSIX,
>>> + =C2=A0 =C2=A0MOUNTVERS,
>>> +};
>>> +static const int max_vers =3D (sizeof(mount_vers)/sizeof(mount_ver=
s[0]));
>>
>> Array indices are unsigned.
> Sure...
>
>>
>> Calling this "max_vers" suggests it's actually a version number, and=
 not
>> an index into the version array; that's confusing.
> Its pretty simple code.. don't see this confusion.... but..
> It changed to =C2=A0mount_vers_tbl
>>
>> The array above this one has a NULL entry as it's final element. =C2=
=A0To be
>> consistent with existing code, you should copy that logic for this a=
rray
>> instead of using a separate "max_vers" variable.
> Having the NULL messes up the sizeof calculations
>
>>
>>> +
>>> /*
>>> =C2=A0* Generate an RPC client handle connected to the mountd servi=
ce
>>> =C2=A0* at @hostname, or die trying.
>>> =C2=A0*
>>> =C2=A0* Supports both AF_INET and AF_INET6 server addresses.
>>> =C2=A0*/
>>> -static CLIENT *nfs_get_mount_client(const char *hostname)
>>> +static CLIENT *nfs_get_mount_client(const char *hostname, int vers=
)
>>
>> RPC version numbers are rpcvers_t, not int. =C2=A0At the very least,
>> clnt_create(3t) takes an unsigned version number argument.
>>
>>> {
>>> =C2=A0 =C2=A0 rpcprog_t program =3D nfs_getrpcbyname(MOUNTPROG, nfs=
_sm_pgmtbl);
>>> =C2=A0 =C2=A0 CLIENT *client;
>>>
>>> - =C2=A0 =C2=A0client =3D clnt_create(hostname, program, MOUNTVERS,=
 "tcp");
>>> + =C2=A0 =C2=A0client =3D clnt_create(hostname, program, vers, "tcp=
");
>>> =C2=A0 =C2=A0 if (client)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return client;
>>>
>>> - =C2=A0 =C2=A0client =3D clnt_create(hostname, program, MOUNTVERS,=
 "udp");
>>> + =C2=A0 =C2=A0client =3D clnt_create(hostname, program, vers, "udp=
");
>>> =C2=A0 =C2=A0 if (client)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return client;
>>>
>>> @@ -122,7 +129,7 @@ int main(int argc, char **argv)
>>> =C2=A0 =C2=A0 mountlist list;
>>> =C2=A0 =C2=A0 int i;
>>> =C2=A0 =C2=A0 int n;
>>> - =C2=A0 =C2=A0int maxlen;
>>> + =C2=A0 =C2=A0int maxlen, vers=3D0;
>>
>> Array indices are unsigned integers.
>>
>> Calling this "vers" suggests it's actually a version number, and not=
 an
>> index into the version array; that's confusing.
> and an index call 'j' or 'i' is descriptive?? vers is clear enough im=
ho...
>
>>
>>> =C2=A0 =C2=A0 char **dumpv;
>>>
>>> =C2=A0 =C2=A0 program_name =3D argv[0];
>>> @@ -185,7 +192,8 @@ int main(int argc, char **argv)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>>> =C2=A0 =C2=A0 }
>>>
>>> - =C2=A0 =C2=A0mclient =3D nfs_get_mount_client(hostname);
>>> +again:
>>> + =C2=A0 =C2=A0mclient =3D nfs_get_mount_client(hostname, mount_ver=
s[vers]);
>>> =C2=A0 =C2=A0 mclient->cl_auth =3D authunix_create_default();
>>> =C2=A0 =C2=A0 total_timeout.tv_sec =3D TOTAL_TIMEOUT;
>>> =C2=A0 =C2=A0 total_timeout.tv_usec =3D 0;
>>> @@ -197,6 +205,10 @@ int main(int argc, char **argv)
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (xdrproc_t) xdr_void, NUL=
L,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (xdrproc_t) xdr_exports, =
(caddr_t) &exportlist,
>>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_timeout);
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0if (clnt_stat =3D=3D RPC_PROGVERSMISMA=
TCH) {
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (++vers < =C2=A0max_v=
ers)
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto again=
;
>>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>>
>> clnt_create(3t) should tell you if the requested version number is
>> working; libtirpc's version does a NULLPROC call, for example. =C2=A0=
It would
>> be simpler to move this check into nfs_get_mount_client(), then you
>> wouldn't need the retry loop here.
> clnt_create() does not fail.. the clnt_call() does..
>
>>
>> But nfs_get_mount_client() already doesn't care why the clnt_create(=
3t)
>> call fails, it just retries the creation with different parameters i=
f it
>> didn't succeed. =C2=A0Do we really care enough to retry _only_ if th=
e
>> specific RPC version isn't available? =C2=A0We use the same procedur=
e number
>> with the same arguments and the same results for all three protocol
>> versions, yes?
> Let not make a mountain out of mole hill... the goal of this patch is=
 stop using the lower mount protocol version so server can only support=
 v3 and v4... nothing
> more...

As a side note, I don't care what gets accepted as long as it works
with modern versions of NFS. Let me know if you need anything more
from me, but I'm glad I got the discussion going.

-Dan
