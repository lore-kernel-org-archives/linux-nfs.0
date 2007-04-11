From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4 Revised] NLM - lock failover
Date: Wed, 11 Apr 2007 13:01:54 -0400
Message-ID: <20070411170154.GA28214@fieldses.org>
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
	id 1HbgCk-0005pv-Hf
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 10:02:01 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HbgCl-0007x0-OJ
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 10:02:01 -0700
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
> Revised patches based on 2.6.21-rc4 kernel and nfs-utils-1.1.0-rc1 that 
> address issues discussed in:
> https://www.redhat.com/archives/cluster-devel/2006-September/msg00034.html
> 
> Quick How-to:
> 1) Failover server exports filesystem with "fsid" option as:
>     /etc/exports entry> /mnt/shared/exports *(fsid=1234,sync,rw)
> 2) Failover server dispatch rpc.statd with "-H" option.
> 3) Failover server drops locks based on fsid by:
>     shell> echo 1234 > /proc/fs/nfsd/nlm_unlock
> 4) Takeover server enters per fsid grace period by:
>     shell> echo 1234 > /proc/fs/nfsd/nlm_set_igrace
> 5) Takeover server notifies clients for lock reclaim by:
>     shell> /usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory
> 
> Patch Summary:
> 4-1: implement /proc/fs/nfsd/nlm_unlock
> 4-2: implement /proc/fs/nfsd/nlm_set_igrace
> 4-3: correctly record and pass incoming server ip interface into rpc.statd.
> 4-4: nfs-utils statd changes
> 4-1 includes an existing lockd bug fix as discussed in:
> http://sourceforge.net/mailarchive/forum.php?thread_name=4603506D.5040807%40redhat.com&forum_name=nfs
> (subject: [NFS] Question about f_count in struct nlm_file)

That's the one separate chunk in nlm_traverse_files()?  Could you keep
that split out as a separate patch?  I see that it got some discussion
before but I'm not clear what the resolution was....

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
