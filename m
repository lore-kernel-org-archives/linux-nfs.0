From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: huge number of intr/s on large nfs server
Date: Thu, 17 Oct 2002 22:05:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021017220543.C3702@redhat.com>
References: <20021016222854.C27038@redhat.com> <CFEAJJEGMGECBCJFLGDBGEMACFAA.enorwood@effrem.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from to-velocet.redhat.com ([216.138.202.10] helo=touchme.toronto.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182MWH-0002qD-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Oct 2002 19:05:45 -0700
To: Eff Norwood <enorwood@effrem.com>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBGEMACFAA.enorwood@effrem.com>; from enorwood@effrem.com on Wed, Oct 16, 2002 at 07:49:38PM -0700
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, Oct 16, 2002 at 07:49:38PM -0700, Eff Norwood wrote:
> This system in question is a SuperMicro P4DL6 MB with dual Xeon 2.4's and
> 2.0GB of memory. One of the PCI-X slots/busses has a 3ware 7850 IDE RAID

Can you try running a non-SMP kernel?  At least one nfs server I'm running 
does pretty well with a UP kernel, even though it is getting in the 
neighbourhood of 10-20k interrupts per second.  Note that it is using 
async writes, and gets about 40MB/s with ext3 and is 100% busy when being 
written to, with the bulk of the time spent computing raid checksum blocks 
and copying data around and in prune_icache.  With an SMP system, there is 
likely to be contention introduced by interrupts floating back and forth 
between CPUs when the single client writing case is really not helped by 
SMP in the current knfsd.  Binding various interrupts to specific CPUs may 
help things here, but part of the problem lies with knfsd allowing multiple 
processes to back up in generic_file_write, which serializes on the inode 
semaphore.  This is pure overhead that a UP system won't suffer from quite 
as dramatically.  Also, make sure your journal is on a separate disk.  
Cheers,

		-ben


-------------------------------------------------------
This sf.net email is sponsored by: viaVerio will pay you up to
$1,000 for every account that you consolidate with us.
http://ad.doubleclick.net/clk;4749864;7604308;v?
http://www.viaverio.com/consolidator/osdn.cfm
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
