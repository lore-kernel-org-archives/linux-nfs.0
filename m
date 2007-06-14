From: Brian Behlendorf <behlendorf1@llnl.gov>
Subject: Re: [PATCH] Usermodehelper vs NFS Client Deadlock
Date: Thu, 14 Jun 2007 16:08:26 -0700
Message-ID: <200706141608.26279.behlendorf1@llnl.gov>
References: <200706141348.42119.behlendorf1@llnl.gov>
	<1181858742.15174.6.camel@heimdal.trondhjem.org>
Reply-To: behlendorf1@llnl.gov
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyyQX-0004cK-EI
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 16:08:29 -0700
Received: from nspiron-3.llnl.gov ([128.115.41.83])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HyyQa-0007bN-Gh
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 16:08:32 -0700
In-Reply-To: <1181858742.15174.6.camel@heimdal.trondhjem.org>
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


> On Thu, 2007-06-14 at 13:48 -0700, Brian Behlendorf wrote:
> > Recently I've observed some interesting NFS client hangs here at LLNL.  I
> > dug in to the issue and resolved it but I thought it was also a good idea
> > to post the patch back upstream for further refinement and review.
> >
> > The root cause of the NFS hang we were observing appears to be a rare
> > deadlock between the kernel provided usermodehelper API and the linux NFS
> > client.  The deadlock can arise because both of these services use the
> > generic linux work queues.  The usermodehelper API run the specified user
> > application in the context of the work queue.  And NFS submits both
> > cleanup and reconnect work to the generic work queue for handling. 
> > Normally this is fine but a deadlock can result in the following
> > situation.
> >
> >   - NFS client is in a disconnected state
> >   - [events/0] runs a usermodehelper app with an NFS dependent operation,
> >     this triggers an NFS reconnect.
> >   - NFS reconnect happens to be submitted to [events/0] work queue.
> >   - Deadlock, the [events/0] work queue will never process the reconnect
> >     because it is blocked on the previous NFS dependent operation which
> >     will not complete.
> >
> > The correct solution it seems to me is for NFS not to use the generic
> > work queues.  A dedicated NFS work queue should be created because the
> > NFS client will never have a guarantee that there are no NFS dependent
> > operations in the generic work queues.
> >
> > The attached patch implements this by adding a per-protocol work queue
> > for the NFS related work items.  One work queue for all NFS client work
> > items would be better but that would have required a little more churn to
> > the existing code base.  That said this patch is working well for us.
>
> Why not just use rpciod? None of the tasks you are proposing to run are
> blocking...
>
> Cheers
>   Trond

I created a new work queue for a couple of reasons.  But the big reason was
simply that I'm not that familiar with the NFS client code.  I was relunct to 
introduce that sort of change when I did not understand all the implications.  
I've been assuming they used the predefined work queue instead of the rpciod 
for a good reason.  Creating a new work queue avoided all of those issues.  
Plus the code was already setup to function with work queues so it made the 
patch rather trivial.

I have nothing against the rpciod approach if the more NFS savy developers on 
this list think its the right way to go.

-- 
Thanks,
Brian

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
