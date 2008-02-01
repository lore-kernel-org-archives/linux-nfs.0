From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
Date: Fri, 1 Feb 2008 11:40:20 -0500
Message-ID: <E83AB0F9-B6CB-49CE-B82C-DA450F4ACE9D@oracle.com>
References: <1201303040-7779-14-git-send-email-bfields@citi.umich.edu> <1201303040-7779-15-git-send-email-bfields@citi.umich.edu> <1201303040-7779-16-git-send-email-bfields@citi.umich.edu> <120!1303040-7779-17-git-send-email-bfields@citi.umich.edu> <1201303040-7779-18-git-send-email-bfields@citi.umich.edu> <1201303040-7779-19-git-send-email-bfields@citi.umich.edu> <1201303040-7779-20-git-send-email-bfields@citi.umich.edu> <DA5779D5-8037-4640-9571-87E041262988@oracle.com> <20080128182858.GC16785@fieldses.org> <C33E449C-C1DB-46D4-9F00-98788B385017@oracle.com> <20080128214851.GO16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62432 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758247AbYBAQog (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Feb 2008 11:44:36 -0500
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
>
> Could you submit a patch that fixes all of those?

According to Documentation/kbuild/kconfig-language.txt, "select" is  
OK to use on non-visible options like NFS_ACL_SUPPORT, LOCKD, and  
SUNRPC, but generally "depends on" is preferred for setting visible  
options.  Apparently "select" doesn't do proper dependency checking,  
it just forces the value of the named option.

NFS_FS looks correct in this regard.

However, NFSD is probably not correct... for example, instead of  
"select NFSD_TCP if NFSD_V4" we should probably instead add a  
"depends on NFSD_TCP" under NFSD_V4.

(Alternately, NFSD_TCP could just go away... hint hint).

I'll propose some patches to rectify some of this and fix up the out- 
of-date help texts.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
