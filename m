From: Neil Horman <nhorman@redhat.com>
Subject: Re: NFS using too much memory on diskless system
Date: Thu, 24 Feb 2005 08:38:12 -0500
Message-ID: <421DD8C4.6080702@redhat.com>
References: <BAY101-F38CA29432DA94D86024AD3BD640@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4JCZ-0006Sn-Hp
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 05:38:47 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4JCF-0003bm-NR
	for nfs@lists.sourceforge.net; Thu, 24 Feb 2005 05:38:47 -0800
To: Gareth Glaccum <verycoldpenguin@hotmail.com>
In-Reply-To: <BAY101-F38CA29432DA94D86024AD3BD640@phx.gbl>
Sender: nfs-admin@lists.sourceforge.net
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

Gareth Glaccum wrote:
> Hi,
> I have a diskless system built and am having weird issues with the way 
> NFS client is working. I am using SLES 9.0 with the stock kernel 
> (2.6.5-7.111-30 I think from memory).
> I have mounted an NFS partition from another machine without any issues. 
> However, when I use anything to write to the partition (for example, see 
> later) the system uses memory to cache the files as I am mounted over GbE.
> However, the machine is not limiting the memory used at all. In fact, it 
> is using so much it is crashing the machine or causing other programs to 
> be OOM'd.
> 
> To recreate the problem, the following command took the machine out in 
> less than 3 seconds dd if=/dev/zero of=/mnt/NFSMOUNT bs=1024k count=4000 
> The machine has 4GB of memory and is using around 300Mb for its OS all 
> told.
> Is there some way of limiting the NFS cache size like there used to be 
> in the 2.4 kernel? (see section B7 of the nfs FAQ I believe)
> 
> Any ideas gratefully received,
> Gareth
> 
It sounds to me your kernel has some sort of vm bug, but if you want to 
shrink page cache usage, you may want to play with the dirty_vm_* 
settings in /proc/sys/vm.  I'm still getting used to the 2.6 sysctls, 
but I believe that those settings allow you to specify when your kernel 
decides its under sufficient memory pressure to start moving data back 
to disk.

HTH
Neil
> _________________________________________________________________
> It's fast, it's easy and it's free. Get MSN Messenger today! 
> http://www.msn.co.uk/messenger
> 
> 
> 
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-- 
/***************************************************
  *Neil Horman
  *Software Engineer
  *Red Hat, Inc.
  *nhorman@redhat.com
  *gpg keyid: 1024D / 0x92A74FA1
  *http://pgp.mit.edu
  ***************************************************/


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
