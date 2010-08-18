From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 10/50] pnfs_submit: register unregister pnfs module
Date: Wed, 18 Aug 2010 23:49:03 +0300
Message-ID: <4C6C473F.5000201@panasas.com>
References: <1281735122-1496-2-git-send-email-andros@netapp.com> <1281735122-1496-3-git-send-email-andros@netapp.com> <1281735122-1496-4-git-send-email-andros@netapp.com> <1281735122-1496-5-git-send-email-andros@netapp.com> <1281735122-1496-6-git-send-email-andros@netapp.com> <1281735122-1496-7-git-send-email-andros@netapp.com> <1281735122-1496-8-git-send-email-andros@netapp.com> <1281735122-1496-9-git-send-email-andros@netapp.com> <1281735122-1496-10-git-send-email-andros@netapp.com> <1281735122-1496-11-git-send-email-andros@netapp.com> <20100818202909.GD16851@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: andros@netapp.com, linux-nfs@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:15274 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753894Ab0HRUtH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 16:49:07 -0400
In-Reply-To: <20100818202909.GD16851@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 18, 2010, 23:29 +0300, Christoph Hellwig <hch@infradead.org> wrote:
>> +#ifdef CONFIG_NFS_V4_1
>> +	err = pnfs_initialize();
>> +	if (err)
>> +		goto out00;
>> +#endif /* CONFIG_NFS_V4_1 */
> 
> Unless the pnfs code goes into it's own module anyway this really
> screams for stubs for the !CONFIG_NFS_V4_1 case to avoid all the
> ifdef mess.
> 

In this case we followed the existing "style" in this function.
That said, I agree that a stub for CONFIG_NFS_V4_1 will work better. 

Benny
