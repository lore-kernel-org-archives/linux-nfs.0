From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2] reduce NFS stack usage
Date: Thu, 25 Sep 2003 20:07:22 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <3F73833A.2000909@pobox.com>
References: <mailman.1064420466.30286.linux-kernel2news@redhat.com> <3F7335B4.1070002@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	trond.myklebust@fys.uio.no
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F7335B4.1070002@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

Steve Dickson wrote:
> Hey Jeff,
> 
> Question:
> Why are only nfs_lookup_revalidate() and nfs_readdir()
> a problem and not the other 4 ops (like nfs_lookup())?
> Is the case only those two showed up in the stack overflow
> oops trace?

You guessed it...  I'm sure other routines are problematic, but those 
were two that showed up in traces.


> Also, not like there much choice in matter, but I wonder what
> type of performance hit (if any) there will be by making
> these routines call kmalloc()... lookups and readdirs are
> pretty popular ops...

Sure.  I wasn't suggesting by any means my patch is the ultimate 
solution :)  Creating a slab cache would be easy enough...

	Jeff
