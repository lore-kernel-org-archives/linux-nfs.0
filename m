Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:48245 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753077AbbAEVHB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Jan 2015 16:07:01 -0500
Message-ID: <54AAFCF3.1040902@Netapp.com>
Date: Mon, 5 Jan 2015 16:06:59 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Weston Andros Adamson <dros@primarydata.com>
CC: Trond Myklebust <Trond.Myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Remove function macros from nfs4_fs.h
References: <1420485444-20101-1-git-send-email-Anna.Schumaker@Netapp.com> <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com>
In-Reply-To: <1C602278-4A23-4975-8339-7AFF0606B154@primarydata.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/05/2015 03:31 PM, Weston Andros Adamson wrote:
> These patches look good to me, but have you tested them? ;)
> 
> I mean, does anyone have a server that implements SP4_MACH_CRED to test against?

I've done basic (non SP4) testing, but I don't have an SP4_MACH_CRED server to test against.

> When I originally developed this feature, I tested against a hacked nfsd…
> that code was really ugly (not ready for upstreaming), but allowed me to test the client
> feature.
> 
> IRRC the server side is difficult because the server has to keep stateid to credential
> mappings, so when the machine cred was used it could check access against the acting cred. 
> 
> If there aren’t any servers to test this against, maybe we remove this feature? It can always
> be revived once there is a server to test against.
> 
I'm open to whatever!  Do you remember how complicated it was to set up the basic SP4 server when you did your testing?

Anna

> -dros
> 
> 
>> On Jan 5, 2015, at 2:17 PM, Anna Schumaker <Anna.Schumaker@netapp.com> wrote:
>>
>> While reviewing Tom's flexfile patches I found a few places where
>> nfs4_state_protect() was being called inside the generic client, rather
>> than in the nfsv4 module.  These patches move the function calls into
>> the correct layer and then tidy up nfs4_fs.h once everything has been
>> moved.
>>
>> Thoughts?
>>
>> Anna
>>
>>
>> Anna Schumaker (3):
>>  nfs: Call nfs4_state_protect() from nfs4_proc_commit_setup()
>>  nfs: Call nfs4_state_protect_write() from nfs4_proc_write_setup()
>>  nfs: Remove unused v4 macros
>>
>> fs/nfs/nfs3proc.c       |  7 +++++--
>> fs/nfs/nfs4_fs.h        |  7 -------
>> fs/nfs/nfs4proc.c       |  9 +++++++--
>> fs/nfs/proc.c           |  6 ++++--
>> fs/nfs/write.c          | 10 ++--------
>> include/linux/nfs_xdr.h |  6 ++++--
>> 6 files changed, 22 insertions(+), 23 deletions(-)
>>
>> -- 
>> 2.2.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

