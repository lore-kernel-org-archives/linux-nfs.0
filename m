From: Jeff Layton <jlayton@redhat.com>
Subject: svc_process and nfsd_proc_read not taking checksum into
 account when calling svc_reserve
Date: Fri, 20 Apr 2007 10:43:43 -0400
Message-ID: <4628D19F.5080805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeuL0-0007dD-5r
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 07:43:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeuL1-0000c1-Gp
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 07:43:52 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l3KEhiOW024579
	for <nfs@lists.sourceforge.net>; Fri, 20 Apr 2007 10:43:44 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3KEhinY008526
	for <nfs@lists.sourceforge.net>; Fri, 20 Apr 2007 10:43:44 -0400
Received: from [192.168.1.3] (vpn-14-47.rdu.redhat.com [10.11.14.47])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l3KEhiJR029850
	for <nfs@lists.sourceforge.net>; Fri, 20 Apr 2007 10:43:44 -0400
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I think I've finally chased down a bug that I noticed at connectathon 
this year. When a client mounts a Linux NFS server using NFSv2 or 3 with 
sec=krb5i, the server gets a ton of messages like this in the logs:

RPC request reserved 80 but used 124

The sizes vary here, but usually the "used" is 44 bytes off from what 
was reserved (sometimes a little less). The issue seems to be that after 
writing out the response header, svc_process() calls this:

         /* un-reserve some of the out-queue now that we have a
          * better idea of reply size
          */
         if (procp->pc_xdrressize)
                 svc_reserve(rqstp, procp->pc_xdrressize<<2);

...but, this does not take into account the size of the checksum at the 
end of the response. This is also a problem in the svc_reserve calls 
made from nfsd3_proc_read and nfsd_proc_read.

While I haven't checked it, my guess is that this is also a problem for 
krb5p and for spkm3i too. We don't seem to see this issue with NFSv4, 
but I think that's because the reserved size for a compound packet is 
likely large enough to paper over this problem.

My thinking is that we need a wrapper of some sort around these calls to 
svc_reserve that increases the "space" parameter by the amount of the 
expected checksum. My question is -- is there a simple way to compute 
the expected length of the checksum, given a svc_rqst?

Thanks,
Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
