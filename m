From: Wendy Cheng <wcheng@redhat.com>
Subject: [RFC PATCH 0/3] NLM lock failover
Date: Thu, 29 Jun 2006 13:47:50 -0400
Message-ID: <44A41246.2070106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw0cZ-0002Gg-9o
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 10:48:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fw0cY-0002bl-Uk
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 10:48:07 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k5THlxVi005600
	for <nfs@lists.sourceforge.net>; Thu, 29 Jun 2006 13:47:59 -0400
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

The uploaded patches implement NLM lock failover as discussed in:

http://www.redhat.com/archives/linux-cluster/2006-June/msg00050.html

[PATCH 1/3]
Add a new admin interface into current nfsd procfs filesystem to trigger 
NLM lock releasing logic. The command is invoked by echoing the server 
virtual IP address into /proc/fs/nfsd/nlm_unlock file as:

shell> cd /prod/fs/nfsd
shell> echo 10.10.1.1 > nlm_unlock
                                                                               

It is currently restricted to IPV4 addressing and the command should be 
invoked from the taken-over NFS server. To do list (not yet implemented) 
include:

1. IPv6 addessing enablement
2. Add "client:server" ip pair to allow NFS V4 lock failover as proposed 
by Andy Adamson (CITI).

[PATCH 2/3]
Add take-over server counter-part command into nfsd procfs interface to 
allow selectively setting of per (virtual) ip (lockd) grace period. It 
is also invoked by echoing the virtual IP into 
/proc/fs/nfsd/nlm_set_ip_grace file as:

shell> cd /proc/fs/nfsd
shell> echo 10.10.1.1 > nlm_set_ip_grace
                                                                                

It is also restricted to IPV4 addressing and the command is expected to 
be invoked from the take-over NFS server.

[PATCH 3/3]
This kernel patch has *not* been unit tested out yet and it needs to be 
paired with user mode nfs-utils changes (not ready in time for this 
RFC). It puts the taken-over IPv4 address in standard dot notation into 
the 3rd parameter of ha_callout program (see man rpc.statd for details) 
for "add-client" event. For "del-client", we would assume the monitored 
host should be removed from machine-wide lists, regardless server's 
interface.

Upon agree-ed on, we will integrate the changes into our cluster suite 
to start a full function verification test. Please comment.

-- Wendy




Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
