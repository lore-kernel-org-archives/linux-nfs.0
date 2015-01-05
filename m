Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:63801 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403AbbAEVvr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2015 16:51:47 -0500
Received: by mail-ig0-f171.google.com with SMTP id z20so3193714igj.10
        for <linux-nfs@vger.kernel.org>; Mon, 05 Jan 2015 13:51:46 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH 0/3] Remove function macros from nfs4_fs.h
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <54AAFCF3.1040902@Netapp.com>
Date: Mon, 5 Jan 2015 16:51:44 -0500
Cc: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <4F150784-EDD7-4065-8790-1B64D3DE20F4@primarydata.com>
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com> <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com> <54AAFCF3.1040902@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jan 5, 2015, at 4:06 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
> 
> On 01/05/2015 03:31 PM, Weston Andros Adamson wrote:
>> These patches look good to me, but have you tested them? ;)
>> 
>> I mean, does anyone have a server that implements SP4_MACH_CRED to test against?
> 
> I've done basic (non SP4) testing, but I don't have an SP4_MACH_CRED server to test against.
> 
>> When I originally developed this feature, I tested against a hacked nfsd…
>> that code was really ugly (not ready for upstreaming), but allowed me to test the client
>> feature.
>> 
>> IRRC the server side is difficult because the server has to keep stateid to credential
>> mappings, so when the machine cred was used it could check access against the acting cred. 
>> 
>> If there aren’t any servers to test this against, maybe we remove this feature? It can always
>> be revived once there is a server to test against.
>> 
> I'm open to whatever!  Do you remember how complicated it was to set up the basic SP4 server when you did your testing?

Pretty complicated.

I hacked up knfsd to allow requests that use the machine credential instead of the expected
user credential and when the machine credential was used, it would skip all credential permission
checks in nfsd — again, only good for testing the client feature….

There were also some changes to nfsd to advertise the availability of SP4_MACH_CRED in
the exchange_id.

I might be able to find these patches, but they’d need merging.

To test:
 - set up server with working krb5i share, obviously with configured machine credential
 - kinit as a user (not machine cred) for a short amount of time (see kinit’s -l / —lifetime flag).
 - do buffered writes past the lifetime of the kerberos ticket.
 - verify that the writes after expiration are using the machine credential (inspect rpc cred in
    wireshark)

So, I think your cleanups look good - let’s go with them for now.

As far as removing SP4_MACH_CRED from the client, we should ask the list if there
are any servers that implement it and if the client works against their implementation and go
from there.

-dros

>> 
>>> On Jan 5, 2015, at 2:17 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>> 
>>> While reviewing Tom's flexfile patches I found a few places where
>>> nfs4_state_protect() was being called inside the generic client, rather
>>> than in the nfsv4 module.  These patches move the function calls into
>>> the correct layer and then tidy up nfs4_fs.h once everything has been
>>> moved.
>>> 
>>> Thoughts?
>>> 
>>> Anna
>>> 
>>> 
>>> Anna Schumaker (3):
>>> nfs: Call nfs4_state_protect() from nfs4_proc_commit_setup()
>>> nfs: Call nfs4_state_protect_write() from nfs4_proc_write_setup()
>>> nfs: Remove unused v4 macros
>>> 
>>> fs/nfs/nfs3proc.c       |  7 +++++--
>>> fs/nfs/nfs4_fs.h        |  7 -------
>>> fs/nfs/nfs4proc.c       |  9 +++++++--
>>> fs/nfs/proc.c           |  6 ++++--
>>> fs/nfs/write.c          | 10 ++--------
>>> include/linux/nfs_xdr.h |  6 ++++--
>>> 6 files changed, 22 insertions(+), 23 deletions(-)
>>> 
>>> -- 
>>> 2.2.1
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
> 

