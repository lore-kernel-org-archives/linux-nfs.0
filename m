From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 02/10] NFS: Use C99 struct initializers in
	nfs4proc.c
Date: Thu, 31 May 2007 13:11:34 -0400
Message-ID: <465F01C6.2080102@oracle.com>
References: <20070525214105.28668.75496.stgit@schiele.1015granger.net>	
	<1180202462.5517.8.camel@heimdal.trondhjem.org>	
	<465C3459.7010302@oracle.com>	
	<1180555947.6770.53.camel@heimdal.trondhjem.org>	
	<465EE66F.8080909@oracle.com>
	<1180628335.6431.27.camel@heimdal.trondhjem.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090303010406050704050809"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtoCw-0007DB-Rq
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 10:13:06 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtoCy-0001WB-Ix
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 10:13:09 -0700
In-Reply-To: <1180628335.6431.27.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------090303010406050704050809
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable

Trond Myklebust wrote:
> On Thu, 2007-05-31 at 11:14 -0400, Chuck Lever wrote:
>> Sorry for the delay in responding.  See below.
>>
>> Trond Myklebust wrote:
>>> On Tue, 2007-05-29 at 10:10 -0400, Chuck Lever wrote:
>>>> Trond Myklebust wrote:
>>>>> On Fri, 2007-05-25 at 17:41 -0400, Chuck Lever wrote:
>>>>>> Follow kernel coding conventions.
>>>>>>
>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>> ---
>>>>>>
>>>>>>  fs/nfs/nfs4_fs.h  |    5 ++++
>>>>>>  fs/nfs/nfs4proc.c |   70 ++++++++++++++++++++++++++++------------=
-------------
>>>>>>  2 files changed, 42 insertions(+), 33 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
>>>>>> index cf3a17e..1a526c4 100644
>>>>>> --- a/fs/nfs/nfs4_fs.h
>>>>>> +++ b/fs/nfs/nfs4_fs.h
>>>>>> @@ -145,6 +145,11 @@ struct nfs4_exception {
>>>>>>  	int retry;
>>>>>>  };
>>>>>> =20
>>>>>> +#define DECLARE_NFS4_EXCEPTION(name)				\
>>>>>> +	struct nfs4_exception name =3D {				\
>>>>>> +		.timeout	=3D 0,				\
>>>>>> +	}
>>>>> Why would we want this? The existing code uses bog standard C99
>>>>> initialisers. There is no need to explicitly set .timeout to zero.
>>>> Using
>>>>
>>>>    struct nfs4_exception name =3D { };
>>>>
>>>> causes compiler complaints.  One correct way to fix this is to set a=
t=20
>>>> least one field in the structure, and setting that field to zero cle=
ars=20
>>>> the other one by default.
>>> I can't find anything in Harbison & Steele stating that name =3D {} i=
s
>>> illegal. All they say is that "if there are fewer initializers than
>>> there are structure components, the remaining components are initiali=
zed
>>> to their default initial values.".
>> The exact compiler warning is this:
>>
>> /home/cel/src/linux/main/fs/nfs/nfs4proc.c: In function=20
>> =E2=80=98nfs4_do_open_reclaim=E2=80=99:
>> /home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: missing initi=
alizer
>> /home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: (near=20
>> initialization for =E2=80=98exception.timeout=E2=80=99)
>>
>>> Anyhow, if you really do have to set one component, then a much less
>>> verbose form would be to write "name =3D {0}" There is no need for th=
e
>>> macro.
>> Yes, that is less verbose.  But it doesn't eliminate the warning, whic=
h=20
>> becomes this:
>>
>> /home/cel/src/linux/main/fs/nfs/nfs4proc.c: In function=20
>> =E2=80=98nfs4_do_open_reclaim=E2=80=99:
>> /home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: missing initi=
alizer
>> /home/cel/src/linux/main/fs/nfs/nfs4proc.c:496: warning: (near=20
>> initialization for =E2=80=98exception.retry=E2=80=99)
>>
>> So a complete structure initializer is necessary to eliminate both war=
nings.
>=20
> Sorry, but to me this sounds like a compiler bug. See the above quote,
> read the structure initialisation examples in Harbison & Steele (I know
> you have a copy), and then tell me how this would be any different.

Whether or not the extraneous warning is a compiler bug, I had thought=20
it was bad form not to use ".field =3D foo," when initializing a=20
structure.  Are there exceptions to that guideline?  Sadly=20
Documentation/CodingStyle is silent on this issue.

It seems to me that specifying "{ 0 };" today will encourage later=20
changes that would replace it with "{ 0, foo };" instead of the=20
preferred use of ".field =3D foo,".

--------------090303010406050704050809
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

YmVnaW46dmNhcmQNCmZuOkNodWNrIExldmVyDQpuOkxldmVyO0NodWNrDQpvcmc6T3JhY2xl
IENvcnBvcmF0aW9uO0NvcnBvcmF0ZSBBcmNoaXRlY3R1cmU6IExpbnV4IFByb2plY3RzIEdy
b3VwDQphZHI6OzsxMDE1IEdyYW5nZXIgQXZlbnVlO0FubiBBcmJvcjtNSTs0ODEwNDtVU0EN
CmVtYWlsO2ludGVybmV0OmNodWNrIGRvdCBsZXZlciBhdCBub3NwYW0gb3JhY2xlIGRvdCBj
b20NCnRpdGxlOlByaW5jaXBhbCBNZW1iZXIgb2YgU3RhZmYNCnRlbDt3b3JrOisxIDI0OCA2
MTQgNTA5MQ0KeC1tb3ppbGxhLWh0bWw6RkFMU0UNCnZlcnNpb246Mi4xDQplbmQ6dmNhcmQN
Cg0K
--------------090303010406050704050809
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090303010406050704050809
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090303010406050704050809--
