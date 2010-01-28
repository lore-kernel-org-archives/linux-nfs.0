From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: splice read byte accounting
Date: Thu, 28 Jan 2010 20:46:55 +0530
Message-ID: <4B61AA67.2050701@suse.de>
References: <39A11474-A44E-49FE-8135-54B384254311@oracle.com> <1264634364.3788.177.camel@localhost> <EAD3EA8D-52B9-43D4-8A35-B623270AF688@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:41710 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754974Ab0A1PRA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jan 2010 10:17:00 -0500
In-Reply-To: <EAD3EA8D-52B9-43D4-8A35-B623270AF688@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/28/2010 08:37 PM, Chuck Lever wrote:
> On Jan 27, 2010, at 6:19 PM, Trond Myklebust wrote:
>> On Wed, 2010-01-27 at 17:22 -0500, Chuck Lever wrote:
>>> Hi-
>>>
>>> nfs_file_splice_write() accounts for the bytes in the request in the
>>> "normal bytes written" counter, but nfs_file_splice_read() does not
>>> account for bytes read.
>>>
>>> Should the read path count these as normal bytes as well, or should
>>> the write path not account for these bytes?
>>>
>>
>> nfs_file_splice_read() should probably update NFSIOS_NORMALREADBYTES.

Yes, I think. Looks like a oversight while we added splice write
support. The argument then was the number of bytes written via splice
are effectively cached writes and hence makes sense to add it to
NFSIO_NORMALWRITTENBYTES.

>> That said, why do nfs_file_read(), nfs_file_write() and
>> nfs_file_splice_write() update the stats with the requested number of
>> bytes, irrespective of the number of bytes that were actually
>> read/write?
> 
> We're counting the number of bytes requested by applications.  I'm not
> sure which is more useful here; number of bytes requested, or number of
> bytes actually read/written.  For computing ratios of app bytes v. otw
> bytes, I suppose the latter?
>

I think the number of bytes actually read/written would be more useful.

Thanks,

-- 
Suresh Jayaraman
