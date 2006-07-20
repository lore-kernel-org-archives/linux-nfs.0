From: "Rajat Upadhyaya" <urajat@novell.com>
Subject: NFSv4 Active-Active Cluster Queries
Date: Thu, 20 Jul 2006 00:11:26 -0600
Message-ID: <44BF6BE5.6FDC.007F.0@novell.com>
References: <44BCC5620200007F0000E2C6@lucius.provo.novell.com>
	<44BCD1F80200007F0000E2CA@lucius.provo.novell.com>
	<44BCE7BB0200007F0000E2E7@lucius.provo.novell.com>
	<44BF54250200007F0000E3E0@lucius.provo.novell.com>
	<44BF5EF80200007F0000E3E4@lucius.provo.novell.com>
	<44BF5F580200007F0000E3E7@lucius.provo.novell.com>
	<44BF5F8B0200007F0000E3EA@lucius.provo.novell.com>
	<44BF607D0200007F0000E3ED@lucius.provo.novell.com>
	<44BF6B4F0200007F0000E3F6@lucius.provo.novell.com>
	<44BF6B870200007F0000E3F9@lucius.provo.novell.com>
	<44BF6BA30200007F0000E3FC@lucius.provo.novell.com>
	<44BF6BE60200007F0000E3FF@lucius.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G3RjI-000530-Pq
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 23:09:49 -0700
Received: from lucius.provo.novell.com ([137.65.81.172])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G3RjE-0004wZ-Ue
	for nfs@lists.sourceforge.net; Wed, 19 Jul 2006 23:09:49 -0700
To: <nfsv4@linux-nfs.org>
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

Hi,

I have been working on setting up NFSv4 in cluster scenario. But when
it comes to an Active-Active setup, it seems there are a few problems. 

In Active-Passive case, the /var/lib/nfs directory itself is moved to
shared storage & on the nodes in the cluster, symlinks are created
pointing to the location on shared storage. This isn't possible in case
of Active-Active setup. In this case, we will need to use scripts to
merge the information in /var/lib/nfs from the failed node with that on
the running one and then do a re-export. 

1) From the High Availability wiki (http://wiki.linux-ha.org), I got to
this page -
http://chilli.linuxmds.com/~mschilli/NFS/active-active-nfs.html where
a method of setting up Active-Active NFS failover was described.
Basically a set of scripts is used to duplicate the rmtab entries on the
node that takes over the process during failover. Will this method hold
in case of NFSv4 too? What other data would need to be duplicated?

2) Assuming there are 2 nodes in a cluster, a client mounts different
exports from both the nodes. Then if one node goes down, the other node
takes over the failed node's IP & re-exports its exports. In this case,
if (1) holds, what happens to the rmtab entry? Is it possible to merge
the 2 entries?

3) Locking issues - revocation & reacquiring of locks.

4) I can see that there is some HA callout code in nfs-utils (under
support). Is this applicable for NFSv4 also?

Is my understanding here correct? If so, are there any
work-arounds/solutions for the issues? Also, are there any other
problems which I have missed out?

Regards,
Rajat

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
