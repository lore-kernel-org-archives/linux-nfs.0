From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: The host->h_inuse NLM's nlm_gc_hosts()
Date: Thu, 08 Jun 2006 01:52:04 -0400
Message-ID: <1149745924.3379.22.camel@localhost.localdomain>
References: <1149494058.5424.164.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoHyy-0005pq-8y
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 03:43:20 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FoDMR-00034q-MB
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 22:50:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FoDH8-0005Q6-W4
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 22:41:48 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k585fZ9E032677
	for <nfs@lists.sourceforge.net>; Thu, 8 Jun 2006 01:41:35 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [172.16.52.156])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k585fZZd021916
	for <nfs@lists.sourceforge.net>; Thu, 8 Jun 2006 01:41:35 -0400
Received: from vpn50-51.rdu.redhat.com (vpn50-51.rdu.redhat.com [172.16.50.51])
	by pobox.corp.redhat.com (8.12.8/8.12.8) with ESMTP id k585fZ2Y011745
	for <nfs@lists.sourceforge.net>; Thu, 8 Jun 2006 01:41:35 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <1149494058.5424.164.camel@localhost.localdomain>
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

On Mon, 2006-06-05 at 03:54 -0400, Wendy Cheng wrote:
> I'm chasing a bug in our distribution - when signalling lockd, the lock
> references do not seem to get released. 

It turns out to be a false alarm. What happened was that we had reports
saying RHCS (Red Hat cluster suite) in some cases would not be able to
umount the filesystem during active-active failover whenever nfs client
was holding posix locks.

Extensive tracing shows the umount failure is actually caused by export
entry's vfsmount reference due to the way unexport was handled. Sending
a signal to lockd *did* release the posix locks as expected.

On the other hand, we do have some other NLM issues (with patches) that
we would like to discuss with the list. More on that later.


-- Wendy





_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
