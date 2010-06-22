Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17891 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448Ab0FVTRT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jun 2010 15:17:19 -0400
Subject: Re: Connectathon locking test fails over NFSv3 with EBUSY
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: NFSv3 list <linux-nfs@vger.kernel.org>
In-Reply-To: <4C2108E7.6040909@oracle.com>
References: <4C2108E7.6040909@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 22 Jun 2010 15:17:12 -0400
Message-ID: <1277234232.3204.40.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-06-22 at 15:03 -0400, Chuck Lever wrote:
> It looks like the connectathon tests race with the removal of deleted 
> files.  The actual lock test is successful, but when the scripts attempt 
> to reset the test directory for another pass, the RMDIR fails because 
> the directory is full of ".nfsxxx" files.
> 
> Seems like RMDIR should wait for those silly deletes before trying to 
> remove the parent directory.
> 
> I've seen this with both 2.6.34 and 2.6.35-rc3 clients, and it happens 
> nearly every time.
> 
> 
> Test #15 - Test 2nd open and I/O after lock and close.
> 	Parent: Second open succeeded.
> 	Parent: 15.0  - F_LOCK  [               0,          ENDING] PASSED.
> 	Parent: 15.1  - F_ULOCK [               0,          ENDING] PASSED.
> 	Parent: Closed testfile.
> 	Parent: Wrote 'abcdefghij' to testfile [ 0, 11 ].
> 	Parent: Read 'abcdefghij' from testfile [ 0, 11 ].
> 	Parent: 15.2  - COMPARE [               0,               b] PASSED.
> 
> ** PARENT pass 1 results: 49/49 pass, 1/1 warn, 0/0 fail (pass/total).
> 
> **  CHILD pass 1 results: 64/64 pass, 0/0 warn, 0/0 fail (pass/total).
> Congratulations, you passed the locking tests!
> ... Pass 2 ...

Err... Any idea what kind of operations are causing the sillyrename to
happen? The locking tests in particular should _never_ have any
outstanding operations post-ULOCK.


