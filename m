Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy3-pub.bluehost.com ([69.89.21.8]:45553 "HELO
	oproxy3-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755651Ab2CMU64 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Mar 2012 16:58:56 -0400
Message-ID: <4F5FB50D.60607@xenotime.net>
Date: Tue, 13 Mar 2012 13:58:53 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
To: Randy Dunlap <rdunlap@xenotime.net>
CC: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: linux-next: Tree for Mar 6 (nfs)
References: <20120306180746.25c595babf8b5072366cdbec@canb.auug.org.au> <4F566E37.5040009@xenotime.net>
In-Reply-To: <4F566E37.5040009@xenotime.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/06/2012 12:06 PM, Randy Dunlap wrote:

> On 03/05/2012 11:07 PM, Stephen Rothwell wrote:
> 
>> Hi all,
>>
>> Changes since 20120305:
>>
>> The nfs tree lost its build failure.
> 
> 
> 
> fs/nfs/nfs4xdr.c:3438:7: error: 'nfs_debug' undeclared (first use in this function)
> 
> Full randconfig file is attached.
> 


This build error still occurs in linux-next 20120313.

-- 
~Randy
