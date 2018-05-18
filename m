Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:47416 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752307AbeERQx3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 12:53:29 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1526659388.10011.10.camel@redhat.com>
Date: Fri, 18 May 2018 12:53:13 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1DA998A5-B4D5-4FD3-B557-9B4DCD43879B@oracle.com>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
 <1526659388.10011.10.camel@redhat.com>
To: Simo Sorce <simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 18, 2018, at 12:03 PM, Simo Sorce <simo@redhat.com> wrote:
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

Thanks!


> The one thing I am unsure of is whether always using the source name
> as the callback target is going to work properly, and what happens
> when it is not.

The series does not change the client principals in play, it
merely ensures that the source principal the server uses to call
the client back will match the principal the client used to
establish the GSS context for the forward channel. It doesn't
seem to me like that would make any case worse (unless there are
bugs, of course).

The forward channel GSS context can be established only if the
client chooses a target principal that has a key in the server's
keytab already. So the server was choosing the wrong key for the
callback channel in some cases before, but now will be choosing
a source principal that the client is already aware of and should
expect.

The server will continue to use a target principal for the
callback channel that the client provided when it authenticated.


> Machines mounting with NFSv4.0 but without machine credentials (ie:
> root kinits to admin@FOO.BAR and uses those creds to mount) will
> always fail to establish a callback because the NFS client's kernel
> does not have access to the user long term key. So even if the KDC
> would decide to allow you to get a ticket for a user principal, the
> client would not be able to complete context establishment.

This might be a little outside the scope of my series.

I think currently the server will test the callback channel when
the client first OPENs a file, and it will not offer a delegation
if the channel cannot be established. So what we need here is a
reliably quick failure in the cases that will not work. That will
enable the first OPEN to proceed without undue delay.

My mount point was hanging here, but I'm not sure why. I was
focused on addressing the authentication mismatch, which fixed
the hang, but perhaps there's another bug.


> Maybe a fallback behavior where it tries to guess at a possible
> machine service name would be valuable for cases where a machine
> credential is actually available on the client host even though
> for whatever reason the mount was done using some user credential.

We could pick a few likely candidates for the server to try if
the client-provided target principal does not work for the callback
channel, but I wonder if that is an heroic effort that is not worth
the additional complexity.

Is it impossible to give the client's kernel access to that user
key for the callback channel? Alternately, using NFSv4.1 might
be helpful.

Also, in the user credential-only case would the client even use
GSS for lease management. If it does not, then the server would
use AUTH_UNIX and not GSS for NFSv4.0 callbacks.


--
Chuck Lever



