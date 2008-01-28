From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss
	server cases
Date: Mon, 28 Jan 2008 13:28:58 -0500
Message-ID: <20080128182858.GC16785@fieldses.org>
References: <1201303040-7779-12-git-send-email-bfields@citi.umich.edu> <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45818 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751841AbYA1S3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 13:29:00 -0500
In-Reply-To: <DA5779D5-8037-4640-9571-87E041262988@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 01:07:05PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> The server depends on upcalls under /proc to support nfsv4 and gss.
>>
>> Acked-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/Kconfig |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/Kconfig b/fs/Kconfig
>> index 487236c..e81fcd6 100644
>> --- a/fs/Kconfig
>> +++ b/fs/Kconfig
>> @@ -1679,6 +1679,8 @@ config NFSD
>>  	select CRYPTO_MD5 if NFSD_V4
>>  	select CRYPTO if NFSD_V4
>>  	select FS_POSIX_ACL if NFSD_V4
>> +	select PROC_FS if NFSD_V4
>> +	select PROC_FS if SUNRPC_GSS
>>  	help
>>  	  If you want your Linux box to act as an NFS *server*, so that  
>> other
>>  	  computers on your local network which support NFS can access  
>> certain
>
> I'm no Kconfig guru... but wouldn't this be better expressed as a  
> "depends" clause?

No idea.  "Not a Kconfig guru" would be a vast understatement in my
case.

> i.e. CONFIG_NFSD_V4 and SUNRPC_GSS should depend on PROC_FS --  
> otherwise, someone might deselect PROC_FS, then select NFSV4 or GSS, and 
> get a surprise.

The drawback being that no amount of searching through the menus will
then help you figure out where the NFSv4 and GSS options have gone to,
right?

I don't care either way, but I'm inclined to leave this as is until
someone comes along with really clear and convincing criteria for when
to choose select and when to choose depends.

--b.
