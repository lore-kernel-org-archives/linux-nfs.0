Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:55870 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965990AbeE2SWN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 14:22:13 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Fwd: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
Date: Tue, 29 May 2018 14:21:58 -0400
References: <1526659388.10011.10.camel@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bruce Fields <bfields@redhat.com>
Message-Id: <35C7F5A1-5192-4F00-B2C9-1BDFD5C00C94@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> Begin forwarded message:
>=20
> From: Simo Sorce <simo@redhat.com>
> Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
> Date: May 18, 2018 at 12:03:08 PM EDT
> To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
>=20
> On Fri, 2018-05-18 at 11:39 -0400, Chuck Lever wrote:
>> I've been experimenting with this series that modifies NFSD to
>> discover and use the correct GSS service principal when constructing
>> its NFSv4.0 callback channels. I'm interested in review of this
>> approach. There are a couple of code comments marked with XXX that
>> also need some attention.
>>=20
>> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
>> made available once there is consensus about the kernel changes
>> in this series. No gssproxy changes are necessary.
>>=20
>> ---
>>=20
>> Chuck Lever (4):
>>      sunrpc: Enable the kernel to specify the hostname part of =
service principals
>>      sunrpc: Extract target name into svc_cred
>>      nfsd: Use correct credential for NFSv4.0 callback with GSS
>>      nfsd: Remove callback_cred
>>=20
>>=20
>> fs/nfsd/nfs4callback.c               |   29 ++++----------
>> fs/nfsd/nfs4state.c                  |   17 +++-----
>> fs/nfsd/state.h                      |    2 -
>> include/linux/sunrpc/svcauth.h       |    3 +
>> net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>> net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 =
++++++++++++++++++++++------------
>> 6 files changed, 80 insertions(+), 61 deletions(-)
>>=20
>> --
>> Chuck Lever
>=20
> Ack for the sunrpc gssp changes.

Hi Bruce, are you willing to take this series for v4.18? If so,
I can post the gssd patch that goes with it.

If not, shall I post these again after v4.18-rc1 ?


> The one thing I am unsure of is whether always using the source name
> as the callback target is going to work properly, and what happens
> when it is not.
>=20
> Machines mounting with NFSv4.0 but without machine credentials (ie:
> root kinits to admin@FOO.BAR and uses those creds to mount) will
> always fail to establish a callback because the NFS client's kernel
> does not have access to the user long term key. So even if the KDC
> would decide to allow you to get a ticket for a user principal, the
> client would not be able to complete context establishment.
>=20
> Maybe a fallback behavior where it tries to guess at a possible
> machine service name would be valuable for cases where a machine
> credential is actually available on the client host even though
> for whatever reason the mount was done using some user credential.
>=20
> Simo.
>=20
> --=20
> Simo Sorce
> Sr. Principal Software Engineer
> Red Hat, Inc
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



