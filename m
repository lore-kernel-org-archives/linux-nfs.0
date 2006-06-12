From: James Yarbrough <jmy@sgi.com>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Mon, 12 Jun 2006 10:27:12 -0700
Message-ID: <448DA3F0.AF1C8540@sgi.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-cluster@redhat.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpqC6-0003cn-E5
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 10:27:18 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FpqC6-0006BJ-An
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 10:27:18 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FpqC4-0003Cz-2e
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 10:27:18 -0700
To: Wendy Cheng <wcheng@redhat.com>
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

> 2. Adding a new flag into "exportfs" command, say "h", such that
> 
>    "exportfs -uh *:/export_path"
> 
> would un-export the entry and drop the NLM locks associated with the
> entry.

This is fine for releasing the locks, but how do you plan to re-enter
the grace period for reclaiming the locks when you relocate the export?
And how do you intend to segregate the export for which reclaims are
valid from the ones which are not?  How do you plan to support the
sending of SM_NOTIFY?  This might be where a lockd per export has an
advantage.

-- 
jmy@sgi.com
650 933 3124

Why is there a snake in my Coke?


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
