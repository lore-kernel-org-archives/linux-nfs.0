Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:46634 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725947AbeHPWD2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Aug 2018 18:03:28 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 1/4] sunrpc: Enable the kernel to specify the hostname
 part of service principals
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <3e9c0dd18719fdc37a00aa5f5e9cddc8010d24e5.camel@hammerspace.com>
Date: Thu, 16 Aug 2018 15:03:05 -0400
Cc: Bruce Fields <bfields@fieldses.org>,
        "simo@redhat.com" <simo@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <F7F06D13-320C-438E-AAC9-6B43AC213D79@oracle.com>
References: <20180816160404.2230.55488.stgit@klimt.1015granger.net>
 <20180816160554.2230.58754.stgit@klimt.1015granger.net>
 <3e9c0dd18719fdc37a00aa5f5e9cddc8010d24e5.camel@hammerspace.com>
To: Trond Myklebust <trondmy@hammerspace.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 16, 2018, at 12:27 PM, Trond Myklebust =
<trondmy@hammerspace.com> wrote:
>=20
> On Thu, 2018-08-16 at 12:05 -0400, Chuck Lever wrote:
>> A multi-homed NFS server may have more than one "nfs" key in its
>> keytab. Enable the kernel to pick the key it wants as a machine
>> credential when establishing a GSS context.
>>=20
>> This is useful for GSS-protected NFSv4.0 callbacks, which are
>> required by RFC 7530 S3.3.3 to use the same principal as the service
>> principal the client used when establishing its lease.
>>=20
>> A complementary modification to rpc.gssd is required to fully enable
>> this feature.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> net/sunrpc/auth_gss/auth_gss.c |   20 +++++++++++++++++---
>> 1 file changed, 17 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/net/sunrpc/auth_gss/auth_gss.c
>> b/net/sunrpc/auth_gss/auth_gss.c
>> index be8f103..1943e11 100644
>> --- a/net/sunrpc/auth_gss/auth_gss.c
>> +++ b/net/sunrpc/auth_gss/auth_gss.c
>> @@ -284,7 +284,12 @@ struct gss_auth {
>> 	return p;
>> }
>>=20
>> -#define UPCALL_BUF_LEN 128
>> +/* XXX: Need some documentation about why UPCALL_BUF_LEN is so
>> small.
>> + *	Is user space expecting no more than UPCALL_BUF_LEN bytes?
>> + *	Note that there are now _two_ NI_MAXHOST sized data items
>> + *	being passed in this string.
>> + */
>> +#define UPCALL_BUF_LEN	256
>>=20
>=20
> Why? The services are currently "nfs" or "nfsd". Hostnames are =
normally
> < 64 characters.

True, but that's an average. We actually should be accommodating the
largest possible hostname here: /usr/include/netdb.h defines NI_MAXHOST
as 1024. Thus even 256 is too small, but as you point out it will work
fine in most real world cases.


>> struct gss_upcall_msg {
>> 	refcount_t count;
>> @@ -462,8 +467,17 @@ static int gss_encode_v1_msg(struct
>> gss_upcall_msg *gss_msg,
>> 		p +=3D len;
>> 		gss_msg->msg.len +=3D len;
>> 	}
>> -	if (service_name !=3D NULL) {
>> -		len =3D scnprintf(p, buflen, "service=3D%s ",
>> service_name);
>> +	if (service_name) {
>> +		char *c =3D strchr(service_name, '@');
>> +
>> +		if (!c)
>> +			len =3D scnprintf(p, buflen, "service=3D%s ",
>> +					service_name);
>> +		else
>> +			len =3D scnprintf(p, buflen,
>> +					"service=3D%.*s srchost=3D%s ",
>> +					(int)(c - service_name),
>> +					service_name, c + 1);
>> 		buflen -=3D len;
>> 		p +=3D len;
>> 		gss_msg->msg.len +=3D len;
>=20
> Isn't this just duplicating the functionality of the 'target' =
argument?

I might not understand your question, but I believe the answer is no.

I have a multi-homed client and server. The primary hostname of the
client is "manet.example.net" and the server is "klimt.example.net"
Both have IB interfaces, respectively "manet.ib.example.net" and
"klimt.ib.example.net".

Now I do this:

manet# mount -o vers=3D4.0,sec=3Dsys klimt.ib.example.net:/export /mnt

The mount is AUTH_SYS, but lease management is done using krb5i because
both systems have a keytab. For the callback channel, RFC 7530 requires
that the server use the client's lease management auth flavor. Moreover,
the server is required to use the same acceptor that the client
authenticated to (in this case, "klimt.ib.example.net").

So now the server establishes a GSS context for it's callback channel:

Aug 16 11:00:17 klimt rpc.gssd[1186]: handle_gssd_upcall: 'mech=3Dkrb5 =
uid=3D0 target=3Dhost@manet.example.net service=3Dnfs =
srchost=3Dklimt.ib.example.net enctypes=3D18,17,16,23,3,1,2 ' =
(nfsd4_cb/clnt4)

The "target" is the principal of the remote service the server is
authenticating to. In full, the target is:

   host/manet.example.net@EXAMPLE.NET

The "srchost" is the hostname part of the server's service principal. =
This
has to match the acceptor string provided by the client, thus the full
source principal has to be:

   nfs/klimt.ib.example.net@EXAMPLE.NET

gssd uses the service=3D and srchost=3D to select the correct key in its
keytab when it establishes a GSS context for the callback channel. =
Without
srchost it would select the key for klimt.example.net, which is the
wrong key in this case. Since this commit:

commit f11b2a1cfbf5dd783eb55cb470509d06e20d1c78
Author:     Jeff Layton <jlayton@poochiereds.net>
AuthorDate: Sat Jun 21 20:52:17 2014 -0400
Commit:     Trond Myklebust <trond.myklebust@primarydata.com>
CommitDate: Sat Jul 12 18:41:25 2014 -0400

    nfs4: copy acceptor name from context to nfs_client

the client rejects NFSv4.0 callbacks using krb5 with the wrong acceptor
string with "NFSv4 callback contains invalid cred". This occurs _after_
the server has established a GSS context and a connection to the client,
so it has already granted delegations which it now cannot recall.


--
Chuck Lever
