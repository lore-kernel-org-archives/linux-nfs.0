From: Manish Katiyar <mkatiyar@gmail.com>
Subject: Re: [PATCH] : Fix compilation warnings in fs/nfsd/nfs4state.c
Date: Thu, 29 Jan 2009 09:23:27 +0530
Message-ID: <ea11fea30901281953r39c2959p82a4c428452c9425@mail.gmail.com>
References: <ea11fea30901272238t4d11ba15t8bac4cd702ea7440@mail.gmail.com>
	 <20090128191104.GA6276@fieldses.org>
	 <8AEAE6B0-5631-4617-AFE7-403460A1A225@oracle.com>
	 <20090128230144.GJ27039@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, kandros@umich.edu,
	linux-nfs@vger.kernel.org, akpm@linux-foundation.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:42923 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbZA2Dx3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2009 22:53:29 -0500
Received: by ti-out-0910.google.com with SMTP id b6so3483472tic.23
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jan 2009 19:53:27 -0800 (PST)
In-Reply-To: <20090128230144.GJ27039@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 29, 2009 at 4:31 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Jan 28, 2009 at 05:05:44PM -0500, Chuck Lever wrote:
>> On Jan 28, 2009, at Jan 28, 2009, 2:11 PM, J. Bruce Fields wrote:
>>> On Wed, Jan 28, 2009 at 12:08:19PM +0530, Manish Katiyar wrote:
>>>> Below patch removes the following warning ;-
>>>> fs/nfsd/nfs4state.c:1657: warning: unused variable 'flp'
>>>
>>> I don't believe we want to support a .config with NFS or NFSD turned
>>> on
>>> but CONFIG_FILE_LOCKING off.
>>
>> In that case, would we want to add a "depends on FILE_LOCKING" to both
>> CONFIG_NFS and CONFIG_NFSD?
>
> Could be.

Enable NFS_FS and NFSD only when FILE_LOCKING is enabled.

Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
---
 fs/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index c680dcd..daaca7a 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1205,6 +1205,7 @@ if NETWORK_FILESYSTEMS
 config NFS_FS
 	tristate "NFS client support"
 	depends on INET
+	depends on FILE_LOCKING
 	select LOCKD
 	select SUNRPC
 	select NFS_ACL_SUPPORT if NFS_V3_ACL
@@ -1301,6 +1302,7 @@ config NFS_FSCACHE
 config NFSD
 	tristate "NFS server support"
 	depends on INET
+	depends on FILE_LOCKING
 	select LOCKD
 	select SUNRPC
 	select EXPORTFS
-- 
1.5.4.3


Thanks -
Manish


>
> --b.
>
>>
>>> --b.
>>>
>>>> Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
>>>> ---
>>>> fs/nfsd/nfs4state.c |    5 ++++-
>>>> 1 files changed, 4 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>>> index 69e98ca..2903589 100644
>>>> --- a/fs/nfsd/nfs4state.c
>>>> +++ b/fs/nfsd/nfs4state.c
>>>> @@ -1654,7 +1654,10 @@ nfs4_open_delegation(struct svc_fh *fh, struct
>>>> nfsd4_open *open, struct nfs4_sta
>>>>     struct nfs4_delegation *dp;
>>>>     struct nfs4_stateowner *sop = stp->st_stateowner;
>>>>     struct nfs4_callback *cb = &sop->so_client->cl_callback;
>>>> -   struct file_lock fl, *flp = &fl;
>>>> +   struct file_lock fl;
>>>> +#ifdef CONFIG_FILE_LOCKING
>>>> +   struct file_lock *flp = &fl;
>>>> +#endif
>>>>     int status, flag = 0;
>>>>
>>>>     flag = NFS4_OPEN_DELEGATE_NONE;
>>
>> --
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>
