From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 0/3] NLM per-ip base grace period
Date: Fri, 25 Jan 2008 00:12:25 -0500
Message-ID: <47996FB9.6000200@redhat.com>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
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

The patch series enable setting of per ip base NLM grace period as a 
counter part of NLM unlock command described in:
http://www.redhat.com/archives/cluster-devel/2008-January/msg00151.html

Example Usage:
root-shell> echo 10.1.1.64 > /proc/fs/nfsd/resume_ip

The command temporarily suspends NFS server lockd to take new lock 
requests unless it is a reclaiming call on the specified interface. It 
is to allow High Availability NFS server failover function where the 
virtual IP interfaces are moved around different servers.

We only support IPV4 for this patch submission.

resume_001.patch: add "resume_ip" into nfs procfs.
resume_002.patch: the core routines that implement resume_ip logic
resume_003.patch: hooks into lockd that actually enable per-ip grace period

-- Wendy
