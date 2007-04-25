From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 25 Apr 2007 10:18:18 -0400
Message-ID: <20070425141818.GA14729@fieldses.org>
References: <46156F3F.3070606@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgiK3-0002V7-KL
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:18:19 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HgiK5-0000SC-1D
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 07:18:22 -0700
In-Reply-To: <46156F3F.3070606@redhat.com>
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

On Thu, Apr 05, 2007 at 05:50:55PM -0400, Wendy Cheng wrote:
> 1) Failover server exports filesystem with "fsid" option as:
>     /etc/exports entry> /mnt/shared/exports *(fsid=1234,sync,rw)
> 2) Failover server dispatch rpc.statd with "-H" option.
> 3) Failover server drops locks based on fsid by:
>     shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
> 4) Takeover server enters per fsid grace period by:
>     shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace
> 5) Takeover server notifies clients for lock reclaim by:
>     shell> /usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory

I don't understand statd and lockd as well as I should.  Where exactly
does the takeover server stop serving requests, and the failover server
start?  If this isn't done carefully, you can leave a window between
steps 3 and 4 where a client could acquire a lock before its rightful
owner reclaims it, right?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
