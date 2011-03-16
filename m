From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: Use of READDIRPLUS on large directories
Date: Wed, 16 Mar 2011 10:20:03 -0400
Message-ID: <1300285203.16266.46.camel@lade.trondhjem.org>
References: <20110316155528.31913c58@notabene.brown>
	 <24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>
	 <4D80C5C6.2060003@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2753 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751137Ab1CPOUF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2011 10:20:05 -0400
In-Reply-To: <4D80C5C6.2060003@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2011-03-16 at 10:14 -0400, Bryan Schumaker wrote:
> I guess I misunderstood what to publish test results for?  I know I included numbers on one of the patches (commit 82f2e5472e2304e531c2fa85e457f4a71070044e, copied below)...  I'll find the numbers you're asking about and post them.
> 
> -Bryan
> 
> commit 82f2e5472e2304e531c2fa85e457f4a71070044e
> Author: Bryan Schumaker <bjschuma@netapp.com>
> Date:   Thu Oct 21 16:33:18 2010 -0400
> 
>     NFS: Readdir plus in v4
>     
>     By requsting more attributes during a readdir, we can mimic the readdir plus
>     operation that was in NFSv3.
>     
>     To test, I ran the command `ls -lU --color=none` on directories with various
>     numbers of files.  Without readdir plus, I see this:
>     
>     n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
>     --------+-----------+-----------+-----------+-----------+----------
>     real    | 0m00.153s | 0m00.589s | 0m05.601s | 0m56.691s | 9m59.128s
>     user    | 0m00.007s | 0m00.007s | 0m00.077s | 0m00.703s | 0m06.800s
>     sys     | 0m00.010s | 0m00.070s | 0m00.633s | 0m06.423s | 1m10.005s
>     access  | 3         | 1         | 1         | 4         | 31
>     getattr | 2         | 1         | 1         | 1         | 1
>     lookup  | 104       | 1,003     | 10,003    | 100,003   | 1,000,003
>     readdir | 2         | 16        | 158       | 1,575     | 15,749
>     total   | 111       | 1,021     | 10,163    | 101,583   | 1,015,784
>     
>     With readdir plus enabled, I see this:
>     
>     n files |    100    |   1,000   |  10,000   |  100,000  | 1,000,000
>     --------+-----------+-----------+-----------+-----------+----------
>     real    | 0m00.115s | 0m00.206s | 0m01.079s | 0m12.521s | 2m07.528s
>     user    | 0m00.003s | 0m00.003s | 0m00.040s | 0m00.290s | 0m03.296s
>     sys     | 0m00.007s | 0m00.020s | 0m00.120s | 0m01.357s | 0m17.556s
>     access  | 3         | 1         | 1         | 1         | 7
>     getattr | 2         | 1         | 1         | 1         | 1
>     lookup  | 4         | 3         | 3         | 3         | 3
>     readdir | 6         | 62        | 630       | 6,300     | 62,993
>     total   | 15        | 67        | 635       | 6,305     | 63,004
>     
>     Readdir plus disabled has about a 16x increase in the number of rpc calls an
>     is 4 - 5 times slower on large directories.

Right. Those are the numbers that convinced me...



-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

