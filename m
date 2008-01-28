From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss
	server cases
Date: Mon, 28 Jan 2008 16:48:51 -0500
Message-ID: <20080128214851.GO16785@fieldses.org>
References: <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org> <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:58715 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762462AbYA1Vsw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Jan 2008 16:48:52 -0500
In-Reply-To: <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 28, 2008 at 04:12:26PM -0500, Chuck Lever wrote:
> On Jan 28, 2008, at 1:28 PM, J. Bruce Fields wrote:
>> I don't care either way, but I'm inclined to leave this as is until
>> someone comes along with really clear and convincing criteria for when
>> to choose select and when to choose depends.
>
> If NFSv4 or GSS *require* procfs to work, then "depends" is the right  
> choice.

Neither CONFIG_NFS_FS nor CONFIG_NFSD_FS seem to be following this rule?

Could you submit a patch that fixes all of those?

>
> As the patch stands, selecting NFSv4 will also select PROC_FS, but you 
> can go back and deselect PROC_FS later; and you're back in the same boat 
> you were in before this patch.

I just checked, and "make menuconfig", at least, isn't letting me go
back and deselect PROC_FS.

--b.
