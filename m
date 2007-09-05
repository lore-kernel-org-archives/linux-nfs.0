From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH] PNFS: filelayout_commit corrupts RPC all_tasks
Date: Wed, 05 Sep 2007 13:43:49 -0500
Message-ID: <1189017829.22424.60.camel@trinity.ogc.int>
References: <1189015398.22424.54.camel@trinity.ogc.int>
	<20070905181758.GD13314@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISzsf-00065y-AE
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 11:45:37 -0700
Received: from ms-smtp-01.texas.rr.com ([24.93.47.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ISzsj-00033s-IJ
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 11:45:42 -0700
In-Reply-To: <20070905181758.GD13314@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-09-05 at 14:17 -0400, J. Bruce Fields wrote:
> On Wed, Sep 05, 2007 at 01:03:18PM -0500, Tom Tucker wrote:
> > The filelayout_commit function incorrectly releases the nfs_write_data 
> > pointed to by 'data'.
> 
> Probably we should continue to keep discussion of the pnfs
> implementation on pnfs@linux-nfs.org for now.
> 

Oops, finger fumble. I'll repost.

> --b.
> 
> Basically, the task contained in the nfs_write_data 
> > structure has already been initialized (rpc_init_task) up in the generic NFS
> > commit logic. Calling nfs4_commit_free frees the memory, but doesn't remove 
> > the task from the RPC all_tasks list. With debug turned on, the task list 
> > is corrupted immediately by poison_obj; without debug, a freed task is 
> > sitting on the all_tasks list and will eventually be corrupted when the 
> > memory is reused.
> > 
> > Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> > ---
> > 
> >  fs/nfs/nfs4filelayout.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> > index 86ced63..1a32925 100644
> > --- a/fs/nfs/nfs4filelayout.c
> > +++ b/fs/nfs/nfs4filelayout.c
> > @@ -583,7 +583,7 @@ filelayout_commit(struct pnfs_layout_typ
> >  	}
> >  
> >  	/* Release original commit data since it is not used */
> > -	nfs4_commit_free(data);
> > +	rpc_release_task(&data->task);
> >  	return 0;
> >  
> >  out_bad:
> > 
> > 
> > -------------------------------------------------------------------------
> > This SF.net email is sponsored by: Splunk Inc.
> > Still grepping through log files to find problems?  Stop.
> > Now Search log events and configuration files using AJAX and a browser.
> > Download your FREE copy of Splunk now >>  http://get.splunk.com/
> > _______________________________________________
> > NFS maillist  -  NFS@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
