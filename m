From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 0/4 Revised] NLM lock failover
Date: Thu, 14 Sep 2006 00:40:18 -0400
Message-ID: <4508DD32.401@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GNipL-0005cl-Ka
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:27:51 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GNipL-0007c2-4o
	for nfs@lists.sourceforge.net; Wed, 13 Sep 2006 21:27:52 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k8E4Ri2n018469
	for <nfs@lists.sourceforge.net>; Thu, 14 Sep 2006 00:27:44 -0400
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
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

The revised patches address the issues discussed in previous review:

https://www.redhat.com/archives/cluster-devel/2006-August/msg00194.html.

The changes made are mostly for grace period fsid list that was 
previously implemented as a single linked list. It is now a double 
linked list with max entries count set to 128.

Quick How-to:
1) Failover server exports filesystem with "fsid" option as:
    /etc/exports entry> /mnt/ext3/exports *(fsid=1234,sync,rw)
2) Failover server dispatch rpc.statd with "-H" option.
3) Failover server drops locks based on fsid by:
    shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
4) Takeover server enters per fsid grace period by:
    shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace
5) Takeover server notifies clients for lock reclaim by:
    shell> rpc.statd -n floating_ip_address -N -P recovery_sm_directory

Patch Summary:
4-1: implement /proc/fs/nfsd/nlm_unlock
4-2: implement /proc/fs/nfsd/nlm_set_igrace
4-3: correctly record and pass incoming server ip interface into rpc.statd.
4-4: (for reference purpose) user mode rpc.statd patch

-- Wendy

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
