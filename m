Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:60268 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726355AbeHQQqv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Aug 2018 12:46:51 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 1/4] sunrpc: Enable the kernel to specify the hostname
 part of service principals
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <ffcd984c8709ab03552de22c80aa91732ce5f0d1.camel@hammerspace.com>
Date: Fri, 17 Aug 2018 09:43:07 -0400
Cc: Bruce Fields <bfields@fieldses.org>,
        "simo@redhat.com" <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B16A995D-03EE-4D80-90D1-4D2A2573E73E@oracle.com>
References: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
 <20180816160554.2230.58754.stgit@klimt.1015granger.net>
 <3e9c0dd18719fdc37a00aa5f5e9cddc8010d24e5.camel@hammerspace.com>
 <F7F06D13-320C-438E-AAC9-6B43AC213D79@oracle.com>
 <ffcd984c8709ab03552de22c80aa91732ce5f0d1.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 17, 2018, at 12:54 AM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Thu, 2018-08-16 at 15:03 -0400, Chuck Lever wrote:
>>> On Aug 16, 2018, at 12:27 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Thu, 2018-08-16 at 12:05 -0400, Chuck Lever wrote:
>>>> A multi-homed NFS server may have more than one "nfs" key in its
>>>> keytab. Enable the kernel to pick the key it wants as a machine
>>>> credential when establishing a GSS context.
>>>>=20
>>>> This is useful for GSS-protected NFSv4.0 callbacks, which are
>>>> required by RFC 7530 S3.3.3 to use the same principal as the
>>>> service
>>>> principal the client used when establishing its lease.
>>>>=20
>>>> A complementary modification to rpc.gssd is required to fully
>>>> enable
>>>> this feature.
>>>>=20
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> net/sunrpc/auth_gss/auth_gss.c |   20 +++++++++++++++++---
>>>> 1 file changed, 17 insertions(+), 3 deletions(-)
>>>>=20
>>>> diff --git a/net/sunrpc/auth_gss/auth_gss.c
>>>> b/net/sunrpc/auth_gss/auth_gss.c
>>>> index be8f103..1943e11 100644
>>>> --- a/net/sunrpc/auth_gss/auth_gss.c
>>>> +++ b/net/sunrpc/auth_gss/auth_gss.c
>>>> @@ -284,7 +284,12 @@ struct gss_auth {
>>>> 	return p;
>>>> }
>>>>=20
>>>> -#define UPCALL_BUF_LEN 128
>>>> +/* XXX: Need some documentation about why UPCALL_BUF_LEN is so
>>>> small.
>>>> + *	Is user space expecting no more than UPCALL_BUF_LEN
>>>> bytes?
>>>> + *	Note that there are now _two_ NI_MAXHOST sized data
>>>> items
>>>> + *	being passed in this string.
>>>> + */
>>>> +#define UPCALL_BUF_LEN	256
>>>>=20
>>>=20
>>> Why? The services are currently "nfs" or "nfsd". Hostnames are
>>> normally
>>> < 64 characters.
>>=20
>> True, but that's an average. We actually should be accommodating the
>> largest possible hostname here: /usr/include/netdb.h defines
>> NI_MAXHOST
>> as 1024. Thus even 256 is too small, but as you point out it will
>> work
>> fine in most real world cases.
>>=20
>>=20
>>>> struct gss_upcall_msg {
>>>> 	refcount_t count;
>>>> @@ -462,8 +467,17 @@ static int gss_encode_v1_msg(struct
>>>> gss_upcall_msg *gss_msg,
>>>> 		p +=3D len;
>>>> 		gss_msg->msg.len +=3D len;
>>>> 	}
>>>> -	if (service_name !=3D NULL) {
>>>> -		len =3D scnprintf(p, buflen, "service=3D%s ",
>>>> service_name);
>>>> +	if (service_name) {
>>>> +		char *c =3D strchr(service_name, '@');
>>>> +
>>>> +		if (!c)
>>>> +			len =3D scnprintf(p, buflen, "service=3D%s ",
>>>> +					service_name);
>>>> +		else
>>>> +			len =3D scnprintf(p, buflen,
>>>> +					"service=3D%.*s srchost=3D%s ",
>>>> +					(int)(c - service_name),
>>>> +					service_name, c + 1);
>>>> 		buflen -=3D len;
>>>> 		p +=3D len;
>>>> 		gss_msg->msg.len +=3D len;
>>>=20
>>> Isn't this just duplicating the functionality of the 'target'
>>> argument?
>>=20
>> I might not understand your question, but I believe the answer is no.
>>=20
>> I have a multi-homed client and server. The primary hostname of the
>> client is "manet.example.net" and the server is "klimt.example.net"
>> Both have IB interfaces, respectively "manet.ib.example.net" and
>> "klimt.ib.example.net".
>>=20
>> Now I do this:
>>=20
>> manet# mount -o vers=3D4.0,sec=3Dsys klimt.ib.example.net:/export =
/mnt
>>=20
>> The mount is AUTH_SYS, but lease management is done using krb5i
>> because
>> both systems have a keytab. For the callback channel, RFC 7530
>> requires
>> that the server use the client's lease management auth flavor.
>> Moreover,
>> the server is required to use the same acceptor that the client
>> authenticated to (in this case, "klimt.ib.example.net").
>>=20
>> So now the server establishes a GSS context for it's callback
>> channel:
>>=20
>> Aug 16 11:00:17 klimt rpc.gssd[1186]: handle_gssd_upcall: 'mech=3Dkrb5
>> uid=3D0 target=3Dhost@manet.example.net service=3Dnfs
>> srchost=3Dklimt.ib.example.net enctypes=3D18,17,16,23,3,1,2 '
>> (nfsd4_cb/clnt4)
>>=20
>> The "target" is the principal of the remote service the server is
>> authenticating to. In full, the target is:
>>=20
>>   host/manet.example.net@EXAMPLE.NET
>>=20
>> The "srchost" is the hostname part of the server's service principal.
>> This
>> has to match the acceptor string provided by the client, thus the
>> full
>> source principal has to be:
>>=20
>>   nfs/klimt.ib.example.net@EXAMPLE.NET
>>=20
>> gssd uses the service=3D and srchost=3D to select the correct key in =
its
>> keytab when it establishes a GSS context for the callback channel.
>> Without
>> srchost it would select the key for klimt.example.net, which is the
>> wrong key in this case. Since this commit:
>>=20
>> commit f11b2a1cfbf5dd783eb55cb470509d06e20d1c78
>> Author:     Jeff Layton <jlayton@poochiereds.net>
>> AuthorDate: Sat Jun 21 20:52:17 2014 -0400
>> Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
>> CommitDate: Sat Jul 12 18:41:25 2014 -0400
>>=20
>>    nfs4: copy acceptor name from context to nfs_client
>>=20
>> the client rejects NFSv4.0 callbacks using krb5 with the wrong
>> acceptor
>> string with "NFSv4 callback contains invalid cred". This occurs
>> _after_
>> the server has established a GSS context and a connection to the
>> client,
>> so it has already granted delegations which it now cannot recall.
>>=20
>=20
> The above story really does deserve an explanation in the code for the
> upcall.
> Right now, you have to hunt through nested layers of struct copies to
> figure out that 'target' refers to the service on the server side
> callback channel for NFSv4.0 only. A second hostname field for the =
same
> use case just adds to that confusion.

I can send an additional patch that adds one or more comments =
documenting
the function of target=3D, service=3D, and srchost=3D.


--
Chuck Lever
