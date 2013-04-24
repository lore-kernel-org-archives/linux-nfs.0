Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:34232 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758090Ab3DXVyw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Apr 2013 17:54:52 -0400
Message-ID: <5178549A.7010402@canonical.com>
Date: Wed, 24 Apr 2013 16:54:34 -0500
From: Dave Chiluk <chiluk@canonical.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Use exponential backoff delay for NFS4_ERRDELAY
References: <1366836949-18465-1-git-send-email-chiluk@canonical.com> <1366838926.22397.25.camel@leira.trondhjem.org>
In-Reply-To: <1366838926.22397.25.camel@leira.trondhjem.org>
Content-Type: multipart/mixed;
 boundary="------------080807040006020205000201"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080807040006020205000201
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 04/24/2013 04:28 PM, Myklebust, Trond wrote:
> On Wed, 2013-04-24 at 15:55 -0500, Dave Chiluk wrote:
>> Changing the retry to start at NFS4_POLL_RETRY_MIN and exponentially grow
>> to NFS4_POLL_RETRY_MAX allow for faster handling of these error conditions.
>>
>> Additionally this alleviates an interoperability problem with the AIX NFSv4
>> Server.  The AIX server frequently (2 out of 3) returns NFS4ERR_DELAY, on a
>> close when it happens in close proximity to a RELEASE_LOCKOWNER.  This would
>> cause a linux client to hang for 15 seconds.
> 
> Hi Dave,
> 
> The AIX server is not being motivated by any requirements in the NFSv4
> spec here, so I fail to see the reason why the behaviour that you
> describe can justify changing the client. It is not at all obvious to me
> that we should be retrying aggressively when NFSv4 servers return
> NFS4ERR_DELAY. What makes 1/10sec more correct in these situations than
> the exising 15 seconds?

I agree with you that AIX is at fault, and that the preferable situation
for the linux client would be for AIX to not return NFS4ERR_DELAY in
this use case.  I have attached a simple program that causes exacerbates
the problem on the AIX server.  I have already had a conference call
with AIX NFS development about this issue, where I vehemently tried to
convince them to fix their server.  Unfortunately as I don't have much
reputation in the NFS community, I was unable to convince them to do the
right thing.  I would be more than happy to set up another call, if
someone higher up in the linux NFS hierarchy would be willing to
participate.

That being said, I think implementing an exponential backoff is an
improvement in the client regardless of what AIX is doing.  If a server
needs only 2 seconds to process a request for which NFS4ERR_DELAY was
returned, this algorithm would get the client back and running after
only 2.1 seconds of elapsed time.  Whereas the current dumb algorithm
would simply wait 15 seconds.  This is the reason that I implemented
this change.


> The motivation for doing it in the case of OPEN, SETATTR, etc is
> clearer: those operations may require the server to recall a delegation,
> in which case aggressive retries are in order since delegation recalls
> are usually fast.
> The motivation in the case of LOCK is less clear, but it is basically
> down to the fact that NFSv4 has a polling model for doing blocking
> locks.

> In all other cases, why should we be treating NFS4ERR_DELAY any
> differently from how we treat NFS3ERR_JUKEBOX in NFSv3?
> 
> Note that if we do decide that changing the client is the right thing,
> then I don't want the patch to add new fields to struct rpc_task. That's
> the wrong layer for storing NFSv4 client specific data.

This is something that I was concerned about as well, but I could not
find another persistent way to do this.  I am open to suggestions of
which structures would be more acceptable.

Thanks,
Dave.


--------------080807040006020205000201
Content-Type: text/x-csrc;
 name="open-close.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="open-close.c"

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/file.h>
#include <unistd.h>

#define FILENAME "testfile"

int main()
{
	int	fd = open( FILENAME, O_RDWR );

	if( fd==0 )
	{
		fputs( "Failed to open `" FILENAME "'.", stderr );
		return 1;
	}

	printf( "flock() returned %d. Now calling close() ...\n",
		flock( fd, LOCK_EX|LOCK_NB ) );
	close( fd );
	return 0;
}

--------------080807040006020205000201--
