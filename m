From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 021/100] nfsd: fail init on /proc/fs/nfs/exports
	creation failure
Date: Mon, 28 Jan 2008 16:20:16 -0500
Message-ID: <20080128212016.GL16785@fieldses.org>
References: <1201303040-7779-13-git-send-email-bfields@citi.umich.edu> <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <1201303040-7779-21-git-send-email-bfields@citi.umich.edu> <B595219E-9D7E-4544-8E1C-422D2DC7D996@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60789 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751538AbYA1VUS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 16:20:18 -0500
In-Reply-To: <B595219E-9D7E-4544-8E1C-422D2DC7D996@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 02:40:20PM -0500, Chuck Lever wrote:
> On Jan 25, 2008, at 6:16 PM, J. Bruce Fields wrote:
>> I assume the reason failure of creation was ignored here was just to
>> continue support embedded systems that want nfsd but not proc.
>>
>> However, in cases where proc is supported it would be clearer to fail
>> entirely than to come up with some features disabled.
>>
>> Acked-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
>> ---
>>  fs/nfsd/nfsctl.c |   37 ++++++++++++++++++++++++++++---------
>>  1 files changed, 28 insertions(+), 9 deletions(-)
>>
>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 2bfda9b..63d8075 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c
>> @@ -674,6 +674,27 @@ static struct file_system_type nfsd_fs_type = {
>>  	.kill_sb	= kill_litter_super,
>>  };
>>
>> +#ifdef CONFIG_PROC_FS
>> +static inline int create_proc_exports_entry(void)
>
> Nit: "inline" is probably not needed here.

OK, fixed.--b.
