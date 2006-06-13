From: Neil Brown <neilb@suse.de>
Subject: Re: The host->h_inuse NLM's nlm_gc_hosts()
Date: Tue, 13 Jun 2006 13:46:18 +1000
Message-ID: <17550.13578.412413.13818@cse.unsw.edu.au>
References: <1149494058.5424.164.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpzrJ-0005Hu-Sr
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:46:29 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FpzrI-0001PC-LC
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:46:30 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Monday June 5
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

On Monday June 5, wcheng@redhat.com wrote:
> 
> So in theory, from #193, the lockhost->h_inuse is supposed to get set
> back to 1. However, I'm wondering whether the fl->fl_owner would get
> overwritten anywhere by (task_struct *)current->files in various other
> code paths so we could end up updating different structures ? This could
> allow the host gets freed such that nlmsvc_invalidate_all() will no
> longer find this host ?
> 
> Will keep doing this bug hunt tomorrow but wondering someone knows this
> code well can assure me that this won't happen ? Many thanks in advance.
> 

It certainly shouldn't happen, but I cannot promise it won't - if
there is a bug somewhere.


> Also the assumption here is that by sending lockd a (any) signal would
> kickoff nlmsvc_invalidate_all() to remove the locks. Is this a correct
> assumption ?

Not 'any' signal - only SIGKILL.  All other signals are blocked for
lockd.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
