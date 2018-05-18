Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48802 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752153AbeERQDK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 May 2018 12:03:10 -0400
Message-ID: <1526659388.10011.10.camel@redhat.com>
Subject: Re: [PATCH RFC 0/4] Use correct NFSv4.0 callback credential
From: Simo Sorce <simo@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date: Fri, 18 May 2018 12:03:08 -0400
In-Reply-To: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2018-05-18 at 11:39 -0400, Chuck Lever wrote:
> I've been experimenting with this series that modifies NFSD to
> discover and use the correct GSS service principal when constructing
> its NFSv4.0 callback channels. I'm interested in review of this
> approach. There are a couple of code comments marked with XXX that
> also need some attention.
> 
> The rpc.gssd change mentioned in 1/4 is unremarkable and will be
> made available once there is consensus about the kernel changes
> in this series. No gssproxy changes are necessary.
> 
> ---
> 
> Chuck Lever (4):
>       sunrpc: Enable the kernel to specify the hostname part of service principals
>       sunrpc: Extract target name into svc_cred
>       nfsd: Use correct credential for NFSv4.0 callback with GSS
>       nfsd: Remove callback_cred
> 
> 
>  fs/nfsd/nfs4callback.c               |   29 ++++----------
>  fs/nfsd/nfs4state.c                  |   17 +++-----
>  fs/nfsd/state.h                      |    2 -
>  include/linux/sunrpc/svcauth.h       |    3 +
>  net/sunrpc/auth_gss/auth_gss.c       |   20 ++++++++--
>  net/sunrpc/auth_gss/gss_rpc_upcall.c |   70 ++++++++++++++++++++++------------
>  6 files changed, 80 insertions(+), 61 deletions(-)
> 
> --
> Chuck Lever

Ack for the sunrpc gssp changes.

The one thing I am unsure of is whether always using the source name
as the callback target is going to work properly, and what happens
when it is not.

Machines mounting with NFSv4.0 but without machine credentials (ie:
root kinits to admin@FOO.BAR and uses those creds to mount) will
always fail to establish a callback because the NFS client's kernel
does not have access to the user long term key. So even if the KDC
would decide to allow you to get a ticket for a user principal, the
client would not be able to complete context establishment.

Maybe a fallback behavior where it tries to guess at a possible
machine service name would be valuable for cases where a machine
credential is actually available on the client host even though
for whatever reason the mount was done using some user credential.

Simo.

-- 
Simo Sorce
Sr. Principal Software Engineer
Red Hat, Inc

