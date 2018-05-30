Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56656 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750967AbeE3KdP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 May 2018 06:33:15 -0400
Subject: Re: nfs4_acl restricts copy_up in overlayfs
To: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de>
 <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
 <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Message-ID: <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
Date: Wed, 30 May 2018 05:33:11 -0500
MIME-Version: 1.0
In-Reply-To: <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/29/2018 10:01 PM, Trond Myklebust wrote:
> On Tue, 2018-05-29 at 20:08 -0500, Goldwyn Rodrigues wrote:
>>
>> On 05/29/2018 04:37 PM, Trond Myklebust wrote:
>>> On Tue, 2018-05-29 at 15:32 -0500, Goldwyn Rodrigues wrote:
>>>> While mounting overlayfs with NFS as a lower directory and a
>>>> local
>>>> filesystem as an upper layer leads to copy_up failures because
>>>> NFS4
>>>> has
>>>> an extra system.nfs4_acl which cannot be copied up. This has been
>>>> discussed before [1] and [2] with the suggestion that nfs4_acl is
>>>> derived from posix_acls or just inode->i_mode *most* of the times
>>>> and
>>>> hence it can be mapped back.
>>>>
>>>> The problem is NFS client knows nothing about nfs4_acl and it is
>>>> decoded
>>>> in nfs4-acl-tools. Even if we make nfs client capable of
>>>> understand
>>>> nfs4_acl xattr, can it be used to perform ACL's for the system.
>>>> AFAIU,
>>>> it is uses user/group names as opposed uid/gid to perform id
>>>> mapping.
>>>> Can the client map it back to user names and derive if it is just
>>>> an
>>>> replica of inode's i_mode?
>>>>
>>>> The idea is to suppress nfs4_acl if it is the same as inode's
>>>> i_mode.
>>>> This means nfs4-acl-tools/nfs4_getacl would give no results when
>>>> requesting for ACLs. This would break existing applications if
>>>> they
>>>> expect some output from nfs4_getfacl.
>>>>
>>>> Is there a better way to identify if nfs4_acl is just a
>>>> representation
>>>> of i_mode at the client end and can be safely ignored during an
>>>> overlayfs copy_up? Can we include a flag for this?
>>>>
>>>>
>>>> [1] https://www.spinics.net/lists/linux-nfs/msg61045.html
>>>> [2] https://www.spinics.net/lists/linux-unionfs/msg04736.html
>>>>
>>>
>>> If the permissions are unchanged so that overlayfs is not trying to
>>> override the way the server interprets the ACL, and credential held
>>> by
>>> the user, then you are better off calling the Linux client for
>>> open/close and permissions calls.
>>>
>>> Once you've allowed the user to chmod or chown the file, you are on
>>> your own, because your security model for the file will have forked
>>> with the security model provided by NFS. At that point, the file
>>> had
>>> better have been copied up, and you'd better be ready to manage it
>>> entirely from overlayfs.
>>>
>>> The above applies not only when the file is subject to NFSv4 acls,
>>> but
>>> it is also true when you are using strong authentication (i.e.
>>> Kerberos
>>> V).
>>>
>>
>> The files permissions are checked during copy ups because a data copy
>> also happens in case of a change. The problem however is not the
>> checks
>> have to happen for this operation but if we should bypass NFS
>> security
>> for consequent ones.
>>
>> For example, If we copy_up the file just because the current user is
>> able to, it would not copy the nfs4_acl. If there is a NFS4 acl rule
>> to
>> DENY another user, the earlier denied user will be able to access the
>> file after the copy_up because we did not copy the nfs4_acl.
>>
> 
> As I said, you are forking the security model. You are trying to make
> the NFS client act as a proxy for the NFS server without giving it
> enough information to do so.
> 
> The NFS client is careful to _always_ leave interpreting the ACL, mode,
> and other security information to the server. If it must try to act as
> a proxy for the server when serving up cached information, then it uses
> the ACCESS rpc call to ensure that it doesn't give up information that
> the server would normally deny to a particular user.

I am in agreement with the security model and that is what I want to
preserve. My question is if it is possible to detect that the security
can be represented by existing in-inode security features alone.

If it was up to me, I would not create the nfs4_acl xattr at the server
if it is not required and the security can be represented by existing
parameters, but it seems to be the protocol. To give a comparison, in
local filsystems, if "system.posix_acl" is not required it will not be
created.

> 
>> Overlayfs tries to make sure that all xattr from an underlying
>> filesystem is compatible with the one being copied to. nfs4_acl is
>> not
>> compatible with a local filesystem it rejects the copy_up as
>> EOPNOTSUPP.
>>
>> From the nfsd code (nfsd_get_nfs4_acl), in *most* cases nfs4_acl is
>> just
>> a representation of i_mode and does not require a special ACL. 
> 
> If your server is a knfsd based Linux server, then maybe. If it's
> anything else, then the above statement is dead wrong. Either way,
> you'd be opening a large can of security worms by making those
> assumptions.

I agree. The man page says there are features (such as alarm and audit)
which are server dependent.

> 
>> However,
>> just because there is a nfs4_acl, a copy_up does not happen in the
>> client.
> 
> Which would appear to be the more secure behaviour if you are unable to
> enforce the exact same security semantics as the server.

I am not trying to override the security. I am trying to detect
duplication of security information. The common case of NFS
communication does not require the additional security parameters
(doesn't mean it is not required). So my question is: is it possible to
detect at the client that nfs4_acl is a duplicate of information which
can be and is represented by inode alone. If yes, can it be suppressed
by the client.

-- 
Goldwyn
