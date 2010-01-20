Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30186 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751931Ab0ATObi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 09:31:38 -0500
Message-ID: <4B5713C3.1010504@panasas.com>
Date: Wed, 20 Jan 2010 16:31:31 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Bian Naimeng <biannm@cn.fujitsu.com>
CC: Shyam_Iyer@Dell.com, pNFS Mailing List <pnfs@linux-nfs.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [pnfs] http git tree
References: <46A00B48CC54E4468EF6911F877AC4CA02815459@blrx3m10.blr.amer.dell.com> <4B45C4EB.7060100@panasas.com> <4B565BC9.8080501@cn.fujitsu.com>
In-Reply-To: <4B565BC9.8080501@cn.fujitsu.com>
Content-Type: text/plain; charset=Shift_JIS
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan. 20, 2010, 3:26 +0200, Bian Naimeng <biannm@cn.fujitsu.com> wrote:
> 
> Benny Halevy ŽÊ“¹:
>> On Jan. 07, 2010, 12:56 +0200, <Shyam_Iyer@Dell.com> wrote:
>>> Is there a tree to pull latest git using http?
>>>
>>> -Shyam Iyer
>> There's only the gitweb interface as far as I know but it doesn't
>> give you an http url for git purposes.
>>
> 
>   Hi Benny
> 
>    I think it's necessary to give a git tree for git purposes using http,
>   because some companies use http proxy server to access internet.

That's up to linux-nfs.org's admin.

Exporting the git tree over http will load the server as it supports
only whole files so if you repack the repository you'll end up downloading
the entire repacked file.

Ideally, your network administrator and ask to poke a hole in your firewall
for git (port 9418).  Or is it blocked outside of your organization?

Benny

> 
>  Best Regards
>    Bian
> 
>> Benny
>> _______________________________________________
>> pNFS mailing list
>> pNFS@linux-nfs.org
>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
> 
