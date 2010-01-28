From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: splice read byte accounting
Date: Thu, 28 Jan 2010 10:07:02 -0500
Message-ID: <EAD3EA8D-52B9-43D4-8A35-B623270AF688@oracle.com>
References: <39A11474-A44E-49FE-8135-54B384254311@oracle.com> <1264634364.3788.177.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:16998 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014Ab0A1PHj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2010 10:07:39 -0500
In-Reply-To: <1264634364.3788.177.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 27, 2010, at 6:19 PM, Trond Myklebust wrote:
> On Wed, 2010-01-27 at 17:22 -0500, Chuck Lever wrote:
>> Hi-
>>
>> nfs_file_splice_write() accounts for the bytes in the request in the
>> "normal bytes written" counter, but nfs_file_splice_read() does not
>> account for bytes read.
>>
>> Should the read path count these as normal bytes as well, or should
>> the write path not account for these bytes?
>>
>
> nfs_file_splice_read() should probably update NFSIOS_NORMALREADBYTES.
>
> That said, why do nfs_file_read(), nfs_file_write() and
> nfs_file_splice_write() update the stats with the requested number of
> bytes, irrespective of the number of bytes that were actually
> read/write?

We're counting the number of bytes requested by applications.  I'm not  
sure which is more useful here; number of bytes requested, or number  
of bytes actually read/written.  For computing ratios of app bytes v.  
otw bytes, I suppose the latter?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




