From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 0/2] NLM failover unlock
Date: Mon, 07 Jan 2008 00:31:09 -0500
Message-ID: <4781B91D.8090509@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: cluster-devel@redhat.com
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <cluster-devel-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <linux-nfs.vger.kernel.org>

This submission is part of the patch sets added to support NFS server 
failover where the specified export is moved from one physical server to 
another. The technical discussions can be found at cluster-devel mailing 
list archives:
https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html

The implementation has not changed much since first RFC. The external 
interfaces, however, have been revised several times. During latest code 
review, it was suggested using export path name as the interface. The 
idea was subsequently prototyped but found difficult to implement. The 
killing issue is the existing lockd reclaim code structure on backup 
server. The associated export path name is difficult to retrieve (based 
on client svc_rqst structure) when the reclaim call is invoked. The 
details is explained in:
[1] http://people.redhat.com/wcheng/Patches/NFS/NLM/004.txt

Nevertheless, as commented by few IT folks who are current managing NFS 
servers on daily basis, the lock dropping feature itself is useful, 
regardless failover and/or cluster setup. This new patch set allows 
system administrator (or cluster user mode applications) to drop NLM 
lock on server based on any one of the following two criteria:

   o Server in-bound IP address
   o Export path name (with restriction - see above [1] for details)

The reclaiming grace period can only be set based on server in-bound IP 
address and the associated patch set will be submitted after this patch 
set is settled and accepted.

-- Wendy
