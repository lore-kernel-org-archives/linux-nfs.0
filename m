From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 0/5] NLM Failover - introduction
Date: Mon, 14 Aug 2006 01:53:33 -0400
Message-ID: <1155534813.3416.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCVCs-0005jQ-W1
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 22:41:47 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCVCs-0006nm-9l
	for nfs@lists.sourceforge.net; Sun, 13 Aug 2006 22:41:47 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k7E5fdLq019605
	for <nfs@lists.sourceforge.net>; Mon, 14 Aug 2006 01:41:39 -0400
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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

This revised patch set is submitted to address active-active lock
failover issues with NFS v2/v3 as discussed in:

o http://www.redhat.com/archives/linux-cluster/2006-June/msg00050.html
  (interface discussion).
o https://www.redhat.com/archives/cluster-devel/2006-June/msg00231.html
  (code review - RFC).
o http://www.redhat.com/archives/cluster-devel/2006-August/msg00000.html
  (code review - first submission). 

The major change made in this submission is switching the driving
interface from floating ip address to exported filesystem id (fsid -
check out "man exports" for details). With previous patches, if we drop
the old server's locks based on one particular (floating) ip address,
lock requests coming in from other interfaces may still hang around.
Failover server could end up with (filesystem) umount failure and
subsequently abort the overall transaction.

The issue with RESTRICTED_STATD flag with nfs-utils package is addressed
in patch 5-4 as an optional patch. The relevant steps of NLM failover
now look like the following:

1) Failover server exports filesystem with "fsid" option as:
   /etc/exports entry> /mnt/ext3/exports *(fsid=1234,sync,rw)

2) Failover server drops locks based on fsid by:
   shell> echo 1234 > /proc/fs/nfsd/nlm_unlock

3) Takeover server enters per fsid grace period by:
   shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace

4) Takeover server notifies clients for lock reclaim by:
   shell> rpc.statd -n floating_ip -N -P alternative_sm_dir

Patch Summary:
5-1: implement /proc/fs/nfsd/nlm_unlock
5-2: implement /proc/fs/nfsd/nlm_set_igrace
5-3: record and pass incoming server ip interface to rpc.statd
5-4: user mode rpc.statd patch
5-5: (for reference purpose) kernel nlm deadlock workaround

Note and Restriction:
o It is expected the RESTRICTED_STATD is tuned on in nfs-utils package.
o IPV6 changes will follow if requested.
o There is an existing NLM deadlock bug that can be triggered with
  and without this patch set. We include the temporary workaround here
  as PATCH 5-5 for reference purpose. The real fix has been worked on:
  http://sourceforge.net/mailarchive/forum.php?
thread_id=30052343&forum_id=4930

-- Wendy


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
