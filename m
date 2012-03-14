Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:44709 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526Ab2CNS5U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 14:57:20 -0400
Message-ID: <4F60EA07.5040008@panasas.com>
Date: Wed, 14 Mar 2012 11:57:11 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-obj: Uglify objio_segment allocation for the sake
 of the principle :-(
References: <4F60141A.709@panasas.com> <20120314051509.GH23916@ZenIV.linux.org.uk>
In-Reply-To: <20120314051509.GH23916@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/13/2012 10:15 PM, Al Viro wrote:
> On Tue, Mar 13, 2012 at 08:44:26PM -0700, Boaz Harrosh wrote:
>> +/*	This is the in memory structure of the objio_segment
>> + *
>> + *	struct __alloc_objio_segment {
>> + *		struct objio_segment olseg;
>> + *		struct ore_dev *ods[numdevs];
>> + *		struct ore_comp	comps[numdevs];
>> + *	} *aolseg;
>> + *	NOTE: The code as above compiles and runs perfectly. It is elegant,
>> + *	type safe and compact.
> 
> In which type system?  Not C99 - there variably-modified types are not
> allowed as structure or union members...

Yes. It's not C99. It's a GCC extension that's also supported by
some other compilers.

But the Kernel is full of GCC extensions. Not like this is the
first one.

Thanks
Boaz
