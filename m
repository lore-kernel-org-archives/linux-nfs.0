From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: RE: Performance Difference Between Linux NFS Server and Netapp
Date: Tue, 12 Jul 2005 12:34:16 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0507121229150.4766@chaos.egr.duke.edu>
References: <EXCHG2003ZbLAX3cf3e00000023@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'Hugh Caley'" <hcaley@plasmabat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DsNiI-0001c4-Dk
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:34:30 -0700
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1DsNiG-0001ve-Sp
	for nfs@lists.sourceforge.net; Tue, 12 Jul 2005 09:34:30 -0700
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003ZbLAX3cf3e00000023@EXCHG2003.microtech-ks.com>
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

On Tue, 12 Jul 2005 at 11:24am, Roger Heflin wrote

> 2000mbit/second is a rate that no ide disk subsystem
> will obtain, so double check your local performance, 

I have a 3ware based server that begs to differ with you -- over 150MB/s 
writing, over 300MB/s reading.  That's on a software RAID0 stripe across 2 
12 port controllers, with each controller doing hardware RAID5.

> You will need to use a test larger than the ram size of 
> the machine to get a realistic rate, at least 2x, and
> probably 4x, and maybe both just to see how things fall
> over.

Absolutely.

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
