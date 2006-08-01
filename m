From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 0/3] NLM lock failover
Date: Mon, 31 Jul 2006 21:55:41 -0400
Message-ID: <1154397341.3378.10.camel@localhost.localdomain>
References: <44A41246.2070106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, lhh@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7jJ0-0006Af-A2
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 18:44:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7jIy-0002pZ-Ga
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 18:44:22 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k711iC7l023575
	for <nfs@lists.sourceforge.net>; Mon, 31 Jul 2006 21:44:12 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <44A41246.2070106@redhat.com>
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

For background info, please check out:
o http://www.redhat.com/archives/linux-cluster/2006-June/msg00050.html
  for interface discussion.
o https://www.redhat.com/archives/cluster-devel/2006-June/msg00231.html
  for first drafted code review.

Note and Restrictions:
o With nfs-utils-1.0.8-rc4 and nfs-utils-lib-1.0.8, the tests went
  surprisingly well, particularly the ha-callout feature. *No* change
  is made into these two user mode utility packages.
o The nfs-utils config flag RESTRICTED_STATD must be off for NLM
  failover to be functional correctly.
o The third parameter passed to rpc.statd ha-callout program is no
  longer be the system_utsname.nodename (set by sethostname()). It 
  is, instead, the specific IP interface where the server receives 
  the client's request.
o The patches are for NFS v2/v3 only. However, we do leave room for
  future NFS V4 expansion. For example, echoing client_ip@server_ip
  into /proc/fs/nfsd/nlm_unlock could be used to drop the V4 locks.
o IP V6 modification is not included in this patch set. If required,
  it will be submitted as another patch set.

PATCH 1/3
---------
Add a new admin interface into current nfsd procfs filesystem to trigger
NLM lock releasing logic. The command is invoked by echoing the server
IP V4 address (in standard dot notation) into /proc/fs/nfsd/nlm_unlock
file as:

shell> cd /prod/fs/nfsd
shell> echo 10.10.1.1 > nlm_unlock

PATCH 2/3
---------
Add take-over server counter-part command into nfsd procfs interface to
allow selectively setting of per (virtual) ip (lockd) grace period. The
grace period setting follows current system-wide grace period rule and
default. It is also invoked by echoing the server IP V4 address (in dot
notation) into /proc/fs/nfsd/nlm_set_ip_grace file:

shell> cd /proc/fs/nfsd
shell> echo 10.10.1.1 > nlm_set_ip_grace

PATCH 3/3
---------
This kernel patch adds a new field into struct nlm_host that holds the
server IP address. Upon SM_MON and SM_UNMON procedure calls, the IP (in
standard V4 dot notation) is placed as the "my_name" string and passed
to local statd daemon. This enables ha-callout program ("man rpc.statd"
for details) to receive the IP address of the server that has received
the client's request. Before this change, my_name string is universally
set to system_utsname.nodename.

The user mode HA implementation is expected to:
1. Specify a user mode ha-calloupt program (rpc.statd -H) for receiving
   client monitored states.
2. Based on info passed by ha-callout, individual state-directory should
   be created and can be read from take-over server.
3. Upon failover, on take-over server, send out notification to nfs
   client via (rpc.statd -n server_ip -P individual_state_directory -N)
   command.

-- Wendy


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
