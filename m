From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
Date: Mon, 28 Jan 2008 16:12:26 -0500
Message-ID: <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com>
References: <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51866 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbYA1VMk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 16:12:40 -0500
In-Reply-To: <20080128182858.GC16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 28, 2008, at 1:28 PM, J. Bruce Fields wrote:
> On Mon, Jan 28, 2008 at 01:07:05PM -0500, Chuck Lever wrote:
>> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>>> The server depends on upcalls under /proc to support nfsv4 and gss.
>>>
>>> Acked-by: NeilBrown <neilb@suse.de>
>>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>>> ---
>>>  fs/Kconfig |    2 ++
>>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/Kconfig b/fs/Kconfig
>>> index 487236c..e81fcd6 100644
>>> --- a/fs/Kconfig
>>> +++ b/fs/Kconfig
>>> @@ -1679,6 +1679,8 @@ config NFSD
>>>  	select CRYPTO_MD5 if NFSD_V4
>>>  	select CRYPTO if NFSD_V4
>>>  	select FS_POSIX_ACL if NFSD_V4
>>> +	select PROC_FS if NFSD_V4
>>> +	select PROC_FS if SUNRPC_GSS
>>>  	help
>>>  	  If you want your Linux box to act as an NFS *server*, so that
>>> other
>>>  	  computers on your local network which support NFS can access
>>> certain
>>
>> I'm no Kconfig guru... but wouldn't this be better expressed as a
>> "depends" clause?
>
> No idea.  "Not a Kconfig guru" would be a vast understatement in my
> case.
>
>> i.e. CONFIG_NFSD_V4 and SUNRPC_GSS should depend on PROC_FS --
>> otherwise, someone might deselect PROC_FS, then select NFSV4 or  
>> GSS, and
>> get a surprise.
>
> The drawback being that no amount of searching through the menus will
> then help you figure out where the NFSv4 and GSS options have gone to,
> right?

Just looking in fs/Kconfig will give you some idea.  But what would  
be more helpful would be a statement in the help for CONFIG_NFS that  
procfs is required to support NFSv4 or GSS.

> I don't care either way, but I'm inclined to leave this as is until
> someone comes along with really clear and convincing criteria for when
> to choose select and when to choose depends.

If NFSv4 or GSS *require* procfs to work, then "depends" is the right  
choice.

As the patch stands, selecting NFSv4 will also select PROC_FS, but  
you can go back and deselect PROC_FS later; and you're back in the  
same boat you were in before this patch.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
