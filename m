From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: nfs performance problem
Date: Fri, 26 Oct 2007 13:01:37 -0400
Message-ID: <EXNANE018awYFDIfWb400000807@exnane01.hq.netapp.com>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
	<20071025193457.GE4499@jakobus.spotify.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Andreas Schuldei <andreas@schuldei.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlSbU-0004X4-IU
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:04:12 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlSbZ-0002nh-Tu
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:04:18 -0700
In-Reply-To: <20071025193457.GE4499@jakobus.spotify.net>
References: <20071025131029.GH8334@barnabas.schuldei.org>
	<7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
	<20071025193457.GE4499@jakobus.spotify.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 03:34 PM 10/25/2007, Andreas Schuldei wrote:
>> But don't expect to get better data throughput over NFS than you see 
>on your local NFS server. 
>
>That is exactly the point. on my server i get 4*50Mbytes =
>200Mbyte/s out of the disks (with the above FOR loop around the
>find and dd) and when i export on the same server the disks to an
>nfs client i all of a sudden loose ~75% of the performance.

Andreas - you mentioned earlier in the thread that you're using 2.6.22
as the server kernel. You might consider moving it forward to 2.6.23,
as there is a significant readahead improvement/fix there. When you
run a local read, all readahead is perfect. However on older kernels
serving NFS, the reordering of reads due to Linux's multithreaded nfsd's
triggers several issues which spook the readahead into truly awful
behavior.

Fengguang Wu's changes are merged in 2.6.23, in testing with NFS/RDMA
we now see the same performance over the wire as locally, for any
number of readers.

My one caveat to this is that your files are relatively small, so I would
not expect a truly dramatic speedup from it. It's certainly worth trying,
there are other improvements in 2.6.23.

Do you have Infiniband or iWARP adapters in your environment? If you're
worried about bandwidth and application startup latency, using it could
certainly help. You'd need to run a 2.6.24-rc1 client though, and some
assembly is still required to use the server (it's not yet upstream).

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
