Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33128 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750738AbeEaV4q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 17:56:46 -0400
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        Miklos Szeredi <miklos@szeredi.hu>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
References: <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
 <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
 <20180531004554.GA29116@fieldses.org>
 <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
 <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
 <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
 <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
 <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
 <20180531140619.GA1298@fieldses.org>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <f48bc5a3-2787-6835-8c45-79ed2fa0edd7@suse.de>
Date: Thu, 31 May 2018 16:56:42 -0500
MIME-Version: 1.0
In-Reply-To: <20180531140619.GA1298@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/31/2018 09:06 AM, bfields@fieldses.org wrote:
> On Thu, May 31, 2018 at 03:30:04PM +0200, Miklos Szeredi wrote:
>> On Thu, May 31, 2018 at 3:10 PM, Trond Myklebust
>> <trondmy@hammerspace.com> wrote:
>>> On Thu, 2018-05-31 at 14:55 +0200, Miklos Szeredi wrote:
>>>> On Thu, May 31, 2018 at 2:47 PM, Trond Myklebust <trondmy@hammerspace.com> wrote:
>>>
>>> IOW: if the user does a chmod, and that is authorised by the underlying
>>> filesystem, then overlayfs is in charge of any further authorisation to
>>> that file.
>>> Adding richacls to that model means that you can attempt to copy the
>>> ACL and allow the user to modify that instead of doing the chmod, but
>>> the understanding should be that it's not the same ACL as was been
>>> enforced by the server, so the copy up of the ACL should be treated as
>>> a modification of the ACL (and should therefore first be subject to
>>> authorisation by the server).
>>
>> If someone adds the interface for access checking in the NFS client
>> based on server sercurity model, but without actually having to do the
>> request, and it works for read-only exports (which make a LOT of sense
>> for the use cases where overlayfs may be used with NFS) then we can
>> use that from overlayfs.  Last time Bruce looked this issue, he ran
>> away screeming, IIRC.
> 
> In theory I suppose it's all possible, but I think the only practical
> thing to do for now is just ignore NFSv4 ACLs.
> 

Ignoring nfs4_acl will override the NFS security model where a user
which is specifically denied read access in the nfs4_acl will get read
access if another user who is allowed to read/write edits the file.

I would agree ignoring NFS4 ACLs is the best option.


-- 
Goldwyn
