From: Wendy Cheng <wcheng@redhat.com>
Subject: [PATCH 0/4 Revised] NLM - lock failover
Date: Thu, 05 Apr 2007 17:50:55 -0400
Message-ID: <46156F3F.3070606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Lon Hohberger <lhh@redhat.com>
To: nfs@lists.sourceforge.net, cluster-devel@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZaB8-0003dm-Di
	for nfs@lists.sourceforge.net; Thu, 05 Apr 2007 15:11:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZaB9-0004bh-Hd
	for nfs@lists.sourceforge.net; Thu, 05 Apr 2007 15:11:40 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l35MBWrd013664
	for <nfs@lists.sourceforge.net>; Thu, 5 Apr 2007 18:11:32 -0400
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

Revised patches based on 2.6.21-rc4 kernel and nfs-utils-1.1.0-rc1 that 
address issues discussed in:
https://www.redhat.com/archives/cluster-devel/2006-September/msg00034.html

Quick How-to:
1) Failover server exports filesystem with "fsid" option as:
    /etc/exports entry> /mnt/shared/exports *(fsid=1234,sync,rw)
2) Failover server dispatch rpc.statd with "-H" option.
3) Failover server drops locks based on fsid by:
    shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
4) Takeover server enters per fsid grace period by:
    shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace
5) Takeover server notifies clients for lock reclaim by:
    shell> /usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory

Patch Summary:
4-1: implement /proc/fs/nfsd/nlm_unlock
4-2: implement /proc/fs/nfsd/nlm_set_igrace
4-3: correctly record and pass incoming server ip interface into rpc.statd.
4-4: nfs-utils statd changes
4-1 includes an existing lockd bug fix as discussed in:
http://sourceforge.net/mailarchive/forum.php?thread_name=4603506D.5040807%40redhat.com&forum_name=nfs
(subject: [NFS] Question about f_count in struct nlm_file)
4-4 includes an existing nfs-utils statd bug fix as discussed in:
http://sourceforge.net/mailarchive/message.php?msg_name=46142B4F.1030507%40redhat.com
(subject: Re: [NFS] lockd and statd)

Misc:
o No IPV6 support due to testing efforts
o NFS V3 only - will compare notes with CITI folks (NFS V4 issues)
o Still need some error-inject tests.

-- Wendy


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
