Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ed1-f68.google.com ([209.85.208.68]:36439 "EHLO
        mail-ed1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727756AbeGTG7Z (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2018 02:59:25 -0400
Received: by mail-ed1-f68.google.com with SMTP id t3-v6so8859671eds.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jul 2018 23:12:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <eaa128b662f96340426d9635c3e883235a3d4616.camel@hammerspace.com>
References: <20180719174246.GA19824@ircssh-2.c.rugged-nimbus-611.internal>
 <e3988e150b5737e13f8b05ab25fd3ed3e5d42c14.camel@hammerspace.com>
 <CAMp4zn9fXdRgw6gh8q4m77OtGVuXf-S8TwMwhvzQGhkO7USvUw@mail.gmail.com> <eaa128b662f96340426d9635c3e883235a3d4616.camel@hammerspace.com>
From: Sargun Dhillon <sargun@sargun.me>
Date: Thu, 19 Jul 2018 23:12:07 -0700
Message-ID: <CAMp4zn-mw1U3PoS9k_JePieU2+owg6hdXdrQ2Lt3p173J_sRbg@mail.gmail.com>
Subject: Re: [PATCH] net/sunrpc: Add user namespace support
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "kinglongmee@gmail.com" <kinglongmee@gmail.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "ebiederm@xmission.com" <ebiederm@xmission.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 19, 2018 at 5:37 PM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
> On Thu, 2018-07-19 at 17:00 -0700, Sargun Dhillon wrote:
>> On Thu, Jul 19, 2018 at 12:45 PM, Trond Myklebust
>> <trondmy@hammerspace.com> wrote:
>> >
>> > On Thu, 2018-07-19 at 17:42 +0000, Sargun Dhillon wrote:
>> > > This adds the ability to pass a non-init user namespace to
>> > > rpcauth_create,
>> > > via rpc_auth_create_args. If the specific authentication
>> > > mechanism
>> > > does not support non-init user namespaces, then it will return an
>> > > error.
>> > >
>> > > Currently, the only two authentication mechanisms that support
>> > > non-init user namespaces are auth_null, and auth_unix. auth_unix
>> > > will send the UID / GID from the user namespace for
>> > > authentication.
>> > >
>> >
>> > Firstly, please at least Cc the linux-nfs mailing list (as per the
>> > MAINTAINERS file) when changing NFS and sunrpc code.
>>
>> Sorry about that.
>>
>> >
>> > Secondly, can you please explain why we would want to use any user
>> > namespace other than the one specified in the net namespace
>> > structure
>> > (struct net) when communicating with network resources such as
>> > rpc.gssd, the idmapper or, for that matter, the NFS server?
>>
>> We mount NFS volumes for containers (user namespaces) today. On
>> multiple machines, they may have different mappings of uids in the
>> user namespace to kuids. If this is the case, it breaks auth_unix
>> because it uses the kuid in the init user ns mapping for the uid it
>> sends to the server.
>>
>
> The point is that the user namespace conversions that happen in the
> sunrpc layer are all for dealing with services. The AUTH_GSS upcalls
> should _only_ be speaking to an rpc.gssd daemon that runs in whatever
> container that owns the net namespace (and that created the rpc_pipefs
> objects).
>
> Ditto for the idmapper although if you use the keyring based (i.e. the
> non legacy) idmapper, that runs in the init namespace.
>
>> I think that if we moved to using the net->user_ns for auth_unix,
>> that'd be great, but it'd break userspace, as far as I know. We have
>> a
>> slightly hacked version of this patch that uses the s_user_ns from
>> the
>> nfs superblock, and I think that uids from the backing store (whether
>> it be a block device, or a server), should be written as the kuid,
>> and
>> translated when it goes in and out of the userns.
>
> The actual applications running in the containers are interacting
> through the standard system calls. They do not need any extra
> conversion, because the syscalls convert them to kuids and back.
>
> IOW: We can completely ignore the user namespace of the container,
> since that is taken care of at the syscall level.
>
> The only namespaces we care about are:
>
> 1) The container that set up the mount in the first place, since
> presumably is is authorised to use its own uid/gids when talking to the
> mountpoint. That user namespace had better be the same one as the one
> saved in 'struct net' that was saved when we set up the mountpoint.
>
> 2) The containers that are running rpc.gssd and rpc.idmapd. Again,
> those are tied to struct net.
>

When the server presents with NFS_CAP_UIDGID_NOMAP, and you use
auth_unix there are no upcalls to rpc.gssd, nor rpc.idmapd. The
mapping to uid in the init user ns are sent to the NFS server, even if
net->user_ns is not init_user_ns. The syscall happens with a user in a
user namespace with, say, ID 0, and their cred has the
from_kuid(&init_user_ns...) of 100, the uid the server receives is
still 100.

If we choose to convert them based on the network namespace, it would
solve the problem just fine, but that'd be a userspace breaking
change. I think we have to use the s_user_ns.

>> Do you have any other suggestions, if we eventually want to enable
>> NFS4 for user namespaces?
>
> See above.
>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
