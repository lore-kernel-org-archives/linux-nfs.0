Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:37494 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752981Ab0HRVJN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Aug 2010 17:09:13 -0400
Received: by ewy23 with SMTP id 23so765000ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 18 Aug 2010 14:09:11 -0700 (PDT)
Message-ID: <4C6C4BF2.30308@panasas.com>
Date: Thu, 19 Aug 2010 00:09:06 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Christoph Hellwig <hch@infradead.org>
CC: andros@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/50] pnfs_submit: pnfs and nfslayoutdriver kconfig
References: <1281735122-1496-1-git-send-email-andros@netapp.com> <1281735122-1496-2-git-send-email-andros@netapp.com> <1281735122-1496-3-git-send-email-andros@netapp.com> <1281735122-1496-4-git-send-email-andros@netapp.com> <1281735122-1496-5-git-send-email-andros@netapp.com> <1281735122-1496-6-git-send-email-andros@netapp.com> <20100818202559.GA16851@infradead.org>
In-Reply-To: <20100818202559.GA16851@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Aug. 18, 2010, 23:25 +0300, Christoph Hellwig <hch@infradead.org> wrote:
> On Fri, Aug 13, 2010 at 05:31:17PM -0400, andros@netapp.com wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> 
> If you split out the Kconfig from the code it guards it should come last
> in the series so that the code can't be enabled until it's complete.
> 

But then it's harder to bisect it, or even make sure each patch
compiles :-(

>>  	depends on NFS_V4 && EXPERIMENTAL
>>  	help
>>  	  This option enables support for minor version 1 of the NFSv4 protocol
>> -	  (draft-ietf-nfsv4-minorversion1) in the kernel's NFS client.
>> +	  (RFC5661) including support for the parallel NFS (pNFS) features
>> +	  in the kernel's NFS client.
>> +
>> +	  Unless you're an NFS developer, say N.
> 
> How much code does the pnfs support add to the nfs.ko module?  Just
> including this unconditionally might not be an all that good idea.
> 
> Also Trond seemed to be pretty determined to split up nfs.ko into
> version specific modules, and pnfs and the various layout drivers are
> pretty good candidates for that.  Maybe the pnfs patches should be ontop
> of that?
> 

Maybe.  I guess it's up to Trond.  But previously as the team discussed,
we consider pNFS an integral part of NFSv4.1 and to reduce the number of
possible configurations we would like to keep the core pnfs functionality
on the same config option as NFS_V4_1.  To disable pNFS at compile time,
the user may still unconfig the layout modules.

>> +config PNFS_FILE_LAYOUT
>> +	tristate "NFS client support for the pNFS nfs-files layout (DEVELOPER ONLY)"
>> +	depends on NFS_FS && NFS_V4_1
> 
> is it really developers-only at this point?

I think it should be this way, at least until we push the whole pnfs
branch (not just the files-layout only part) upstream.

> And if it is so why doesn't
> it depend on EXPERIMENTAL
> 

Good catch.  It should depend on experimental.

>> +	default y
> 
> defaulting to y for random fringe features is frowned upon.

The problem is that it will rot otherwise.
I'd rather disable it by default using a variable and provide a way to
enable it at run time.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

