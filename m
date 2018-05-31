Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f180.google.com ([74.125.82.180]:45885 "EHLO
        mail-ot0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755146AbeEaMzR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 31 May 2018 08:55:17 -0400
Received: by mail-ot0-f180.google.com with SMTP id 15-v6so25123388otn.12
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 05:55:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de> <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de> <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de> <20180531004554.GA29116@fieldses.org>
 <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com> <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 31 May 2018 14:55:16 +0200
Message-ID: <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 31, 2018 at 2:47 PM, Trond Myklebust
<trondmy@hammerspace.com> wrote:
> On Thu, 2018-05-31 at 12:00 +0200, Miklos Szeredi wrote:
>> On Thu, May 31, 2018 at 2:45 AM, J. Bruce Fields <bfields@fieldses.or
>> g> wrote:
>> > On Wed, May 30, 2018 at 05:33:11AM -0500, Goldwyn Rodrigues wrote:
>> > > I am not trying to override the security. I am trying to detect
>> > > duplication of security information. The common case of NFS
>> > > communication does not require the additional security parameters
>> > > (doesn't mean it is not required). So my question is: is it
>> > > possible to
>> > > detect at the client that nfs4_acl is a duplicate of information
>> > > which
>> > > can be and is represented by inode alone. If yes, can it be
>> > > suppressed
>> > > by the client.
>> >
>> > No, that's not possible.
>> >
>> > The user's identity could be mapped in various ways.  You've got no
>> > way
>> > to know whether root squashing is in effect, for example.  Or to
>> > know
>> > what the user@EXAMPLE.COM krb5 identity that you're running as
>> > might map
>> > to on the server.
>> >
>> > So it's hard to even tell whether a given user matches the file's
>> > owner
>> > or group.  So even the mode bits are kind of meaningless to the
>> > client.
>>
>> The basic security model for overlayfs is that underlying filesystems
>> are just storage.  Access to these filesystems is done with the
>> capabilities of the task that created the overlay instance with
>> mount(2).  That capability set is saved and used for any access to
>> underlying storage.
>>
>> Access to overlayfs itself is controlled by metadata in the file
>> (mode, uid, gid, posix_acl, security xattr, etc...).
>>
>> So if one of the layers is NFS, the permissions in the server are
>> only
>> checked against the mounter's creds (usually superuser).  Access
>> checks are not performed by the server on behalf of the task
>> accessing
>> the overlay.    This means, that overlayfs could give access to an
>> NFS
>> file, where access on the NFS mount would be denied.  This needs to
>> be
>> understood by the admin mounting the overlay.
>>
>> So how to handle nfs4_acls with this model?
>>
>> We could just ignore them and this can be achieved with mounting the
>> NFS filesystem with "noacl".  I'm not against specifically ignoring
>> nfs4_acl in overlayfs by default, as that seems to be the simplest
>> solution to this problem and fits the overlayfs security model.
>> Later, if we want to make use of this attribute to check access (on
>> the overlay, not in the NFS server), we can add an option to enable
>> this.  But AFAICS that one requires richacl's to make it upstream at
>> least.
>
> 'noacl' does not mean what you think it means. It doesn't mean that the
> NFS security model is changed in any way. Security is still enforced by
> the server.

I understand.  Ignoring nfs4_acl in overlayfs will have the same
result as adding noacl to the underlying NFS mount.

> And no, richacl won't help you get further either.
>
> I'm still in strong disagreement with the model you are presenting
> here. It is a client enforced model, which is not ever going to be
> compatible with the NFS model.

It's the only sane model that overlayfs can do.

Think of it this way:  creating an image file on NFS, formating it to
ext4 and mounting it locally through the loop device is not going to
be compatible with the NFS security model either.  Should we care?

Thanks,
Miklos
