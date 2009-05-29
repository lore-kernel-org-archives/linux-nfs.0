From: Brian R Cowan <brcowan@us.ibm.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Date: Fri, 29 May 2009 11:55:45 -0400
Message-ID: <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:42014 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760521AbZE2Pzy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 11:55:54 -0400
In-Reply-To: <1241126587.15476.62.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Been working this issue with Red hat, and didn't need to go to the list... 
Well, now I do... You mention that "The main type of workload we're 
targetting with this patch is the app that opens a file, writes < 4k and 
then closes the file." Well, it appears that this issue also impacts 
flushing pages from filesystem caches.

The reason this came up in my environment is that our product's build 
auditing gives the the filesystem cache an interesting workout. When 
ClearCase audits a build, the build places data in a few places, 
including:
1) a build audit file that usually resides in /tmp. This build audit is 
essentially a log of EVERY file open/read/write/delete/rename/etc. that 
the programs called in the build script make in the clearcase "view" 
you're building in. As a result, this file can get pretty large.
2) The build outputs themselves, which in this case are being written to a 
remote storage location on a Linux or Solaris server, and
3) a file called .cmake.state, which is a local cache that is written to 
after the build script completes containing what is essentially a "Bill of 
materials" for the files created during builds in this "view."

We believe that the build audit file access is causing build output to get 
flushed out of the filesystem cache. These flushes happen *in 4k chunks.* 
This trips over this change since the cache pages appear to get flushed on 
an individual basis.

One note is that if the build outputs were going to a clearcase view 
stored on an enterprise-level NAS device, there isn't as much of an issue 
because many of these return from the stable write request as soon as the 
data goes into the battery-backed memory disk cache on the NAS. However, 
it really impacts writes to general-purpose OS's that follow Sun's lead in 
how they handle "stable" writes. The truly annoying part about this rather 
subtle change is that the NFS client is specifically ignoring the client 
mount options since we cannot force the "async" mount option to turn off 
this behavior.

=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.



From:
Trond Myklebust <trond.myklebust@fys.uio.no>
To:
Peter Staubach <staubach@redhat.com>
Cc:
Chuck Lever <chuck.lever@oracle.com>, Brian R Cowan/Cupertino/IBM@IBMUS, 
linux-nfs@vger.kernel.org
Date:
04/30/2009 05:23 PM
Subject:
Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
Sent by:
linux-nfs-owner@vger.kernel.org



On Thu, 2009-04-30 at 16:41 -0400, Peter Staubach wrote:
> Chuck Lever wrote:
> >
> > On Apr 30, 2009, at 4:12 PM, Brian R Cowan wrote:
> >>
> >> 
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ab0a3dbedc51037f3d2e22ef67717a987b3d15e2

> >>
> Actually, the "stable" part can be a killer.  It depends upon
> why and when nfs_flush_inode() is invoked.
> 
> I did quite a bit of work on this aspect of RHEL-5 and discovered
> that this particular code was leading to some serious slowdowns.
> The server would end up doing a very slow FILE_SYNC write when
> all that was really required was an UNSTABLE write at the time.
> 
> Did anyone actually measure this optimization and if so, what
> were the numbers?

As usual, the optimisation is workload dependent. The main type of
workload we're targetting with this patch is the app that opens a file,
writes < 4k and then closes the file. For that case, it's a no-brainer
that you don't need to split a single stable write into an unstable + a
commit.

So if the application isn't doing the above type of short write followed
by close, then exactly what is causing a flush to disk in the first
place? Ordinarily, the client will try to cache writes until the cows
come home (or until the VM tells it to reclaim memory - whichever comes
first)...

Cheers
  Trond

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html


