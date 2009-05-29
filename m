From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
 flushing
Date: Fri, 29 May 2009 13:35:00 -0400
Message-ID: <1243618500.7155.56.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com>
	 <1241126587.15476.62.camel@heimdal.trondhjem.org>
	 <OF820C8732.74757E21-ON852575C5.0055C089-852575C5.00578071@us.ibm.com>
	 <1243615595.7155.48.camel@heimdal.trondhjem.org>
	 <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
	linux-nfs-owner@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Brian R Cowan <brcowan@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50483 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752205AbZE2RfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 May 2009 13:35:08 -0400
In-Reply-To: <OF0EEDB635.561D17D4-ON852575C5.005CBABA-852575C5.005FAD0D@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-05-29 at 13:25 -0400, Brian R Cowan wrote:
> Ah, but I submit that the application isn't making the decision... The OS 
> is. My testcase is building Samba on Linux using gcc. The gcc linker sure 
> isn't deciding to flush the file. It's happily seeking/reading and 
> seeking/writing with no idea what is happening under the covers. When the 
> build gets audited, the cache gets flushed... No audit, no flush. The only 
> apparent difference is that we have an audit file getting written to on 
> the local disk. The linker has no idea it's getting audited.
> 
> I'm interested in knowing what kind of performance benefit this 
> optimization is providing in small-file writes. Unless it's incredibly 
> dramatic, then I really don't see why we can't do one of the following:
> 1) get rid of it,
> 2) find some way to not do it when the OS flushes filesystem cache, or
> 3) make the "async" mount option turn it off, or
> 4) create a new mount option to force the optimization on/off.
> 
> I just don't see how a single RPC saved is saving all that much time. 
> Since:
>  - open
>  - write (unstable) <write size
>  - commit
>  - close
> Depends on the commit call to finish writing to disk, and
>  - open
>  - write (stable) <write size
>  - close
> Also depends on the time taken to writ ethe data to disk, I can't see the 
> one less RPC buying that much time, other than perhaps on NAS devices.
> 
> This may reduce the server load, but this is ignoring the mount options. 
> We can't turn this behavior OFF, and that's the biggest issue. I don't 
> mind the small-file-write optimization itself, as long as I and my 
> customers are able to CHOOSE whether the optimization is active. It boils 
> down to this: when I *categorically* say that the mount is async, the OS 
> should pay attention. There are cases when the OS doesn't know best. If 
> the OS always knew what would work best, there wouldn't be nearly as many 
> mount options as there are now.

What are you smoking? There is _NO_DIFFERENCE_ between what the server
is supposed to do when sent a single stable write, and what it is
supposed to do when sent an unstable write plus a commit. BOTH cases are
supposed to result in the server writing the data to stable storage
before the stable write / commit is allowed to return a reply.

The extra RPC round trip (+ parsing overhead ++++) due to the commit
call is the _only_ difference.

No, you can't turn this behaviour off (unless you use the 'async' export
option on a Linux server), but there is no difference there between the
stable write and the unstable write + commit.

THEY BOTH RESULT IN THE SAME BEHAVIOUR.

Trond


> =================================================================
> Brian Cowan
> Advisory Software Engineer
> ClearCase Customer Advocacy Group (CAG)
> Rational Software
> IBM Software Group
> 81 Hartwell Ave
> Lexington, MA
>  
> Phone: 1.781.372.3580
> Web: http://www.ibm.com/software/rational/support/
>  
> 
> Please be sure to update your PMR using ESR at 
> http://www-306.ibm.com/software/support/probsub.html or cc all 
> correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
> case I am not available.
> 
> 
> 
> From:
> Trond Myklebust <trond.myklebust@fys.uio.no>
> To:
> Brian R Cowan/Cupertino/IBM@IBMUS
> Cc:
> Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org, 
> linux-nfs-owner@vger.kernel.org, Peter Staubach <staubach@redhat.com>
> Date:
> 05/29/2009 12:47 PM
> Subject:
> Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
> Sent by:
> linux-nfs-owner@vger.kernel.org
> 
> 
> 
> Look... This happens when you _flush_ the file to stable storage if
> there is only a single write < wsize. It isn't the business of the NFS
> layer to decide when you flush the file; that's an application
> decision...
> 
> Trond
> 
> 
> 
> On Fri, 2009-05-29 at 11:55 -0400, Brian R Cowan wrote:
> > Been working this issue with Red hat, and didn't need to go to the 
> list... 
> > Well, now I do... You mention that "The main type of workload we're 
> > targetting with this patch is the app that opens a file, writes < 4k and 
> 
> > then closes the file." Well, it appears that this issue also impacts 
> > flushing pages from filesystem caches.
> > 
> > The reason this came up in my environment is that our product's build 
> > auditing gives the the filesystem cache an interesting workout. When 
> > ClearCase audits a build, the build places data in a few places, 
> > including:
> > 1) a build audit file that usually resides in /tmp. This build audit is 
> > essentially a log of EVERY file open/read/write/delete/rename/etc. that 
> > the programs called in the build script make in the clearcase "view" 
> > you're building in. As a result, this file can get pretty large.
> > 2) The build outputs themselves, which in this case are being written to 
> a 
> > remote storage location on a Linux or Solaris server, and
> > 3) a file called .cmake.state, which is a local cache that is written to 
> 
> > after the build script completes containing what is essentially a "Bill 
> of 
> > materials" for the files created during builds in this "view."
> > 
> > We believe that the build audit file access is causing build output to 
> get 
> > flushed out of the filesystem cache. These flushes happen *in 4k 
> chunks.* 
> > This trips over this change since the cache pages appear to get flushed 
> on 
> > an individual basis.
> > 
> > One note is that if the build outputs were going to a clearcase view 
> > stored on an enterprise-level NAS device, there isn't as much of an 
> issue 
> > because many of these return from the stable write request as soon as 
> the 
> > data goes into the battery-backed memory disk cache on the NAS. However, 
> 
> > it really impacts writes to general-purpose OS's that follow Sun's lead 
> in 
> > how they handle "stable" writes. The truly annoying part about this 
> rather 
> > subtle change is that the NFS client is specifically ignoring the client 
> 
> > mount options since we cannot force the "async" mount option to turn off 
> 
> > this behavior.
> > 
> > =================================================================
> > Brian Cowan
> > Advisory Software Engineer
> > ClearCase Customer Advocacy Group (CAG)
> > Rational Software
> > IBM Software Group
> > 81 Hartwell Ave
> > Lexington, MA
> > 
> > Phone: 1.781.372.3580
> > Web: http://www.ibm.com/software/rational/support/
> > 
> > 
> > Please be sure to update your PMR using ESR at 
> > http://www-306.ibm.com/software/support/probsub.html or cc all 
> > correspondence to sw_support@us.ibm.com to be sure your PMR is updated 
> in 
> > case I am not available.
> > 
> > 
> > 
> > From:
> > Trond Myklebust <trond.myklebust@fys.uio.no>
> > To:
> > Peter Staubach <staubach@redhat.com>
> > Cc:
> > Chuck Lever <chuck.lever@oracle.com>, Brian R Cowan/Cupertino/IBM@IBMUS, 
> 
> > linux-nfs@vger.kernel.org
> > Date:
> > 04/30/2009 05:23 PM
> > Subject:
> > Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page 
> flushing
> > Sent by:
> > linux-nfs-owner@vger.kernel.org
> > 
> > 
> > 
> > On Thu, 2009-04-30 at 16:41 -0400, Peter Staubach wrote:
> > > Chuck Lever wrote:
> > > >
> > > > On Apr 30, 2009, at 4:12 PM, Brian R Cowan wrote:
> > > >>
> > > >> 
> > 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=ab0a3dbedc51037f3d2e22ef67717a987b3d15e2
> 
> > 
> > > >>
> > > Actually, the "stable" part can be a killer.  It depends upon
> > > why and when nfs_flush_inode() is invoked.
> > > 
> > > I did quite a bit of work on this aspect of RHEL-5 and discovered
> > > that this particular code was leading to some serious slowdowns.
> > > The server would end up doing a very slow FILE_SYNC write when
> > > all that was really required was an UNSTABLE write at the time.
> > > 
> > > Did anyone actually measure this optimization and if so, what
> > > were the numbers?
> > 
> > As usual, the optimisation is workload dependent. The main type of
> > workload we're targetting with this patch is the app that opens a file,
> > writes < 4k and then closes the file. For that case, it's a no-brainer
> > that you don't need to split a single stable write into an unstable + a
> > commit.
> > 
> > So if the application isn't doing the above type of short write followed
> > by close, then exactly what is causing a flush to disk in the first
> > place? Ordinarily, the client will try to cache writes until the cows
> > come home (or until the VM tells it to reclaim memory - whichever comes
> > first)...
> > 
> > Cheers
> >   Trond
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


