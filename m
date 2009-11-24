From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: [PATCHSET 0-6] nfsd: #includes cleanup
Date: Tue, 24 Nov 2009 14:42:24 +0200
Message-ID: <4B0BD4B0.3020605@panasas.com>
References: <4B0AB039.6020608@panasas.com> <20091123221415.GE8534@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	NFS list <linux-nfs@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:11361 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757920AbZKXMmW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2009 07:42:22 -0500
In-Reply-To: <20091123221415.GE8534@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/24/2009 12:14 AM, J. Bruce Fields wrote:
> On Mon, Nov 23, 2009 at 05:54:33PM +0200, Boaz Harrosh wrote:
>>
>> Hi Bruce
>>
>> This time I've based the patchset on the:
>> 	git://linux-nfs.org/~bfields/linux.git for-2.6.33 branch
>>
>> I was hoping to find that nfsd.h cleanup you sent to the mailing list
>> the other day. But I don't see it. Should I rebase this work on some
>> other branch?
> 
> Apologies, I applied it but hadn't pushed it out; done now.  Could you
> rebase onto that?
> 
> --b.
> 

OK that wasn't so bad. I'm just re-posting that one patch which changed:
	[PATCH 5/6 version3] nfsd: Source files #include cleanups

Note the version3.

Thanks
Boaz
