From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
Date: Mon, 4 Feb 2008 16:29:40 -0500
Message-ID: <E9EA25D0-1865-4EC2-BE61-8DA062C43C60@oracle.com>
References: <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org> <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com> <20080128214851.GO16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62544 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753959AbYBDVbP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2008 16:31:15 -0500
In-Reply-To: <20080128214851.GO16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 28, 2008, at 4:48 PM, J. Bruce Fields wrote:
> On Mon, Jan 28, 2008 at 04:12:26PM -0500, Chuck Lever wrote:
>> On Jan 28, 2008, at 1:28 PM, J. Bruce Fields wrote:
>>> I don't care either way, but I'm inclined to leave this as is until
>>> someone comes along with really clear and convincing criteria for  
>>> when
>>> to choose select and when to choose depends.
>>
>> If NFSv4 or GSS *require* procfs to work, then "depends" is the right
>> choice.
>
> Neither CONFIG_NFS_FS nor CONFIG_NFSD_FS seem to be following this  
> rule?

After looking into this, I've found that there are a couple of  
reasons for this.

First, as I posted last week, "select" is usually OK for non-visible  
CONFIG options, like LOCKD or SUNRPC.

But, second, we have a mix of boolean and tristate variables here --  
and a boolean that selects another tristate variable can only choose  
Y or N (not M).  So the "select ... if ..." clauses are placed up in  
CONFIG_NFSD on purpose in order to allow the selected variables to be  
set to M if CONFIG_NFSD is set to M.  See commit f05e15b5.

I'm not inclined to adjust any of this for the moment.

And, a quick grep around other Kconfig files reveals that no-one else  
uses "select PROC_FS" -- every case uses "depends on".  Thus  
CONFIG_NFSD_V4 should use "depends on PROC_FS" as well.  Also, this  
patch doesn't touch the client side -- should CONFIG_NFSV4 depend on  
PROC_FS too?

Since SUNRPC_GSS is already a non-visible config option and is set  
via "select", it's more difficult to say with certainty how a  
"depends on PROC_FS" clause should be constructed for that.  However,  
MAINTAINERS suggests that linux-kbuild@vger might be an appropriate  
place to ask about these things.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
