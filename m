Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46107 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757894Ab2BISFc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 13:05:32 -0500
Date: Thu, 9 Feb 2012 13:05:32 -0500
To: Todd Freeman <freeman@andrews.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfsd4_stateowners eating memory like candy... sometimes....
Message-ID: <20120209180531.GA22168@fieldses.org>
References: <4F32F726.4060704@andrews.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F32F726.4060704@andrews.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2012 at 05:28:54PM -0500, Todd Freeman wrote:
> Good day all!
> 
> I have a nfs server handling the load for a shared file system for 5
> web servers...  some relevant info:
>   libnfsidmap2
> 0.23-2
>   nfs-common
> 1:1.2.2-1ubuntu1.1
>   nfs-kernel-server
> 1:1.2.2-1ubuntu1.1
> 
>   Linux webnfs 2.6.35-31-server #63-Ubuntu SMP Mon Nov 28 21:03:37
> UTC 2011 x86_64 GNU/Linux
> 
> On this server everything runs great for a couple weeks to a month
> and then we start getting sluggish performance... and within a
> couple days it seizes up (at least all nfs services stop... console
> is still accessible)
> 
> In trying to debug this we have been taking a snap shot every 5
> minutes of the slabinfo...   we got a totally clean capture this
> time and I see nfsd4_stateowners running away with memory. When we
> start the server and for the first several days the most memory it
> uses is 200MB or so...  over time though there come points were it
> suddenly starts munching more...  sometimes slowly... other times
> instantly. It finally kills the machine when it reaches the 1.7-1.8
> GB level (just under the memory size of the machine). oom-killer is
> killing everything left and right at the end and we end up with a
> machine that is comatose NFS wise till we do a full reboot.
> 
> You can see a graph of this usage pattern at: http://imgur.com/ecLPh
> 
> I see mentions of a problem along this line back in the 2.6.16-18
> types days... but supposedly it was fixed.

There have been a number of stateowner leaks fixed since 2.6.35.  I
think all the ones I know of were fixes as of 3.1 or so.

--b.
