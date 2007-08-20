From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Fwd: Re: [2/3] 2.6.23-rc2: known regressions v2]
Date: Mon, 20 Aug 2007 11:26:06 -0400
Message-ID: <20070820152606.GB31368@fieldses.org>
References: <1186594872.6699.39.camel@heimdal.trondhjem.org>
	<18106.22383.551248.118418@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IN98r-0008Cl-7H
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 08:26:09 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IN98v-00022p-3L
	for nfs@lists.sourceforge.net; Mon, 20 Aug 2007 08:26:13 -0700
In-Reply-To: <18106.22383.551248.118418@notabene.brown>
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

On Thu, Aug 09, 2007 at 09:53:19AM +1000, Neil Brown wrote:
> On Wednesday August 8, Trond.Myklebust@netapp.com wrote:
> > Re: the nfsd problem. Shouldn't svc_force_close_socket() be taking the
> > serv->sv_lock in order to prevent races with svc_sock_enqueue()?
> 
> The theory is that at this time there should be no active server
> threads. So the worst svc_sock_enqueue could do would be to queue the
> socket to a pool->sp_sockets.  And as the socket and the queue are
> both about to be destroyed, that hardly matters.
> 
> However the 'theory' doesn't quite match practice.  A new thread can
> be started before svc_force_close_socket finishes up.  I think the
> race we need to deal with is between the last thread exiting and a new
> thread being started.  Whether we provide an interlock to exclude the
> possibility, or a fine grained lock so it looks like we never actually
> got to zero threads, I'm not sure yet.
> 
> > 
> > Also, how is the server attempting to prevent races between
> > svc_sock_put() and the socket callbacks (->sk_data_ready,
> > ->sk_write_space,...)?
> 
> Presumably the network code ensure that after sock_release has been
> called, no further callbacks will be made (or in process)??
> If not, we probably should leverage sk_destruct to delay freeing of
> svsk until the network layer is completely done with the socket.
> 
> This patch might do that, but I haven't tested it at all.
> 
> Would it answer your concerns?

Help!  I've lost track.  What do we need to here?  (And is the original
problem actually a regression, or is it a preexisting bug that's just
very hard to hit?)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
