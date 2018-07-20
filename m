Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ed1-f68.google.com ([209.85.208.68]:46633 "EHLO
        mail-ed1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730054AbeGTAqz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jul 2018 20:46:55 -0400
Received: by mail-ed1-f68.google.com with SMTP id o8-v6so8328651edt.13
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jul 2018 17:01:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e3988e150b5737e13f8b05ab25fd3ed3e5d42c14.camel@hammerspace.com>
References: <20180719174246.GA19824@ircssh-2.c.rugged-nimbus-611.internal> <e3988e150b5737e13f8b05ab25fd3ed3e5d42c14.camel@hammerspace.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Thu, 19 Jul 2018 17:00:43 -0700
Message-ID: <CAMp4zn9fXdRgw6gh8q4m77OtGVuXf-S8TwMwhvzQGhkO7USvUw@mail.gmail.com>
Subject: Re: [PATCH] net/sunrpc: Add user namespace support
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@netapp.com>,
        "ebiederm@xmission.com" <ebiederm@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 19, 2018 at 12:45 PM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
>
> On Thu, 2018-07-19 at 17:42 +0000, Sargun Dhillon wrote:
> > This adds the ability to pass a non-init user namespace to
> > rpcauth_create,
> > via rpc_auth_create_args. If the specific authentication mechanism
> > does not support non-init user namespaces, then it will return an
> > error.
> >
> > Currently, the only two authentication mechanisms that support
> > non-init user namespaces are auth_null, and auth_unix. auth_unix
> > will send the UID / GID from the user namespace for authentication.
> >
>
> Firstly, please at least Cc the linux-nfs mailing list (as per the
> MAINTAINERS file) when changing NFS and sunrpc code.
Sorry about that.

>
> Secondly, can you please explain why we would want to use any user
> namespace other than the one specified in the net namespace structure
> (struct net) when communicating with network resources such as
> rpc.gssd, the idmapper or, for that matter, the NFS server?
We mount NFS volumes for containers (user namespaces) today. On
multiple machines, they may have different mappings of uids in the
user namespace to kuids. If this is the case, it breaks auth_unix
because it uses the kuid in the init user ns mapping for the uid it
sends to the server.

I think that if we moved to using the net->user_ns for auth_unix,
that'd be great, but it'd break userspace, as far as I know. We have a
slightly hacked version of this patch that uses the s_user_ns from the
nfs superblock, and I think that uids from the backing store (whether
it be a block device, or a server), should be written as the kuid, and
translated when it goes in and out of the userns.

Do you have any other suggestions, if we eventually want to enable
NFS4 for user namespaces?
>
> Thanks
>   Trond
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
