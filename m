From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
  instead of getaddrinfo
Date: Tue, 07 Apr 2009 12:27:49 -0400
Message-ID: <49db7f0d.85c2f10a.5025.ffffb257@mx.google.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
 <1239117946-7535-4-git-send-email-jlayton@redhat.com>
 <41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:26491 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756695AbZDGQ17 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2009 12:27:59 -0400
Received: by qw-out-2122.google.com with SMTP id 8so3039088qwh.37
        for <linux-nfs@vger.kernel.org>; Tue, 07 Apr 2009 09:27:58 -0700 (PDT)
In-Reply-To: <41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 12:02 PM 4/7/2009, Chuck Lever wrote:
>
>On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
>> +	/* Use standard NFS port for NFSv4 */
>> +	if (program == 100003 && version == 4) {
>> +		port = 2049;
>> +		goto set_port;
>> +	}
>
>I think this patch set looks pretty reasonable.  Here's my one  
>remaining quibble.
>
>You can specify "port=" for nfs4 mounts, in which case we want to use  
>that value here, too, I think.  It would be simpler overall if the  

*Must* use a port= specification. The 2049 definition is only true for
NFSv4/TCP, as a counterexample the NFSv4/RDMA IANA binding is
port 20049. So slamming the port to 2049 would break NFSv4/RDMA.

>kernel always passed up the value it is using for port= on this mount  
>point.
>
>The rules for how the kernel uses the port= setting are:
>
>  + if port= is not specified on NFSv2/v3, port= setting is zero
>  + if port= is not specified on NFSv4, port= setting is 2049

This is a tiny bit questionable, since 2049 is only defined for TCP.
But, if port= can override, then that's a workaround, so OK.

>
>Then, when setting up a tranport:
>
>  + if the port= setting is zero, do an rpcbind
>  + if the port= setting is not zero, use that value
>
>If the kernel always passes the port= setting to gssd, then it can  
>follow the "if port value is zero, rpcbind; otherwise use port value  
>as is" rule, and be sure to get correct NFSv4 behavior, even without  
>the special case you added for NFSv4.

Agree.

Tom.

