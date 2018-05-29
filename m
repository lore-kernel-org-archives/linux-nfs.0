Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:56562 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965614AbeE2TPP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 May 2018 15:15:15 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20180529191315.GA31484@parsley.fieldses.org>
Date: Tue, 29 May 2018 15:14:59 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <65F50CE6-31CA-4D17-9EE8-09227CA96156@oracle.com>
References: <1526659388.10011.10.camel@redhat.com>
 <35C7F5A1-5192-4F00-B2C9-1BDFD5C00C94@oracle.com>
 <20180529191315.GA31484@parsley.fieldses.org>
To: Bruce Fields <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On May 29, 2018, at 3:13 PM, J. Bruce Fields <bfields@redhat.com> =
wrote:
>=20
> On Tue, May 29, 2018 at 02:21:58PM -0400, Chuck Lever wrote:
>>=20
>>=20
>>> Begin forwarded message:
>>>=20
>>> From: Simo Sorce <simo@redhat.com>
>>> Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
>>> Date: May 18, 2018 at 12:03:08 PM EDT
>>> To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
>>>=20
>>> On Fri, 2018-05-18 at 11:39 -0400, Chuck Lever wrote:
>>>> I've been experimenting with this series that modifies NFSD to
>>>> discover and use the correct GSS service principal when =
constructing
>>>> its NFSv4.0 callback channels. I'm interested in review of this
>>>> approach. There are a couple of code comments marked with XXX that
>>>> also need some attention.
>>>>=20
>>>> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
>>>> made available once there is consensus about the kernel changes
>>>> in this series. No gssproxy changes are necessary.
>>>>=20
>>>> ---
>>>>=20
>>>> Chuck Lever (4):
>>>>     sunrpc: Enable the kernel to specify the hostname part of =
service principals
>>>>     sunrpc: Extract target name into svc_cred
>>>>     nfsd: Use correct credential for NFSv4.0 callback with GSS
>>>>     nfsd: Remove callback_cred
>>>>=20
>>>>=20
>>>> fs/nfsd/nfs4callback.c               |   29 ++++----------
>>>> fs/nfsd/nfs4state.c                  |   17 +++-----
>>>> fs/nfsd/state.h                      |    2 -
>>>> include/linux/sunrpc/svcauth.h       |    3 +
>>>> net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>>>> net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 =
++++++++++++++++++++++------------
>>>> 6 files changed, 80 insertions(+), 61 deletions(-)
>>>>=20
>>>> --
>>>> Chuck Lever
>>>=20
>>> Ack for the sunrpc gssp changes.
>>=20
>> Hi Bruce, are you willing to take this series for v4.18?
>=20
> Sure.  Are you going to repost?

Except for Simo's Ack, there haven't been any requests for
changes, so I hadn't planned to repost. But it wouldn't be
a problem if you'd like me to post again.


>> If so, I can post the gssd patch that goes with it.
>=20
> Sounds good.


--
Chuck Lever



