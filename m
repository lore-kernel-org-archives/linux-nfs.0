From: James Pearson <james-p@moving-picture.com>
Subject: Re: df: Value too large for defined data type
Date: Tue, 06 Jul 2004 10:19:08 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40EA6E8C.50409@moving-picture.com>
References: <40EA5DC4.5060509@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bhm6a-0008SS-LA
	for nfs@lists.sourceforge.net; Tue, 06 Jul 2004 02:19:12 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1Bhm6a-0002CC-2w
	for nfs@lists.sourceforge.net; Tue, 06 Jul 2004 02:19:12 -0700
To: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
In-Reply-To: <40EA5DC4.5060509@framestore-cfc.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I had exactly the same problem (as it happens, on similar hardware) - 
which I thought was an NFS problem - see:

http://marc.theaimsgroup.com/?t=107762984200002&r=1&w=2

But it appears to be a 32/64bit statfs, 2.4/2.6 kernel, glibc version 
and XFS issue - I 'fixed' it by patching the XFS code in the 2.4 kernel 
- see:

http://marc.theaimsgroup.com/?t=107789989600008&r=1&w=2

However, since then, I believe, there have been postings about an NFS 
patch to fix statfs - see:

http://marc.theaimsgroup.com/?t=108004719500003&r=1&w=2

The problem goes away if you fill up the file system ...

James Pearson

Johan van den Dorpe wrote:
> Hi,
> 
> Not quite sure is this is an NFS issue or a kernel one, so I thought I'd 
> start here.
> 
> I'm seeing this error when trying to do a df when I have a large volume 
> mounted via NFS (>1573005MB)
> 
> df: `/nfs/ps15/mnt/raid1': Value too large for defined data type
> 
> The error is occurring on clients running a vanilla 2.6.6 kernel, when 
> the server is running a 2.4 kernel.
> 
> I've tried 2.4.20 + xfs patches + Trond's NFS_ALL patches, as well as 
> vanilla 2.4.25 on the server, with the same results.
> 
> When running 2.6.6 on the server there is no problem.
> 
> I'm using a SATA RAID with an Infortrend controller, partitioning the 
> array on the controller. It's connected to the host via Fibre Channel to 
> a qla2300 card.
> 



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
