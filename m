From: Ian Kent <raven@themaw.net>
Subject: Re: Portmap - was Re: Does mountd/statd really need to	listen
	on a privileged port??
Date: Wed, 02 May 2007 12:22:12 +0800
Message-ID: <1178079732.3393.8.camel@raven.themaw.net>
References: <17958.48121.280256.493824@notabene.brown>
	<200704252214.03069.okir@lst.de>
	<17968.18279.424773.589417@notabene.brown>
	<200704261059.50688.okir@lst.de>  <4630A32E.6000006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hj6Nh-0004NH-WC
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 21:23:58 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hj6Nh-0000GW-6l
	for nfs@lists.sourceforge.net; Tue, 01 May 2007 21:24:00 -0700
Received: from compute1.internal (compute1.internal [10.202.2.41])
	by out1.messagingengine.com (Postfix) with ESMTP id 92E2F21A8AF
	for <nfs@lists.sourceforge.net>; Wed,  2 May 2007 00:23:55 -0400 (EDT)
Received: from [10.49.97.36] (unknown [203.59.241.52])
	by mail.messagingengine.com (Postfix) with ESMTP id 7B673BC75
	for <nfs@lists.sourceforge.net>; Wed,  2 May 2007 00:23:55 -0400 (EDT)
In-Reply-To: <4630A32E.6000006@redhat.com>
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

On Thu, 2007-04-26 at 09:03 -0400, Peter Staubach wrote:
> Olaf Kirch wrote:
> > On Thursday 26 April 2007 08:32, Neil Brown wrote:
> >   
> >> Following this logic, should we add rpcbind functionality to portmap
> >> rather than throw it out and start with something less known???
> >>     
> >
> > I'm not sure. The rpcbind code isn't exactly pretty, but neither is
> > portmap.
> >
> > Anyway, I guess in order to prove my point about the sunrpc library
> > I should cough up some code to prove it can be done. I'll be uploading
> > some patches later tonight or tomorrow.
> >   
> 
> Before we go too far down the road of ignoring all of the work that
> the engineers at Sun have been doing on the RPC library, is there a
> way of getting a newer version of the RPC support to start with?  The
> current stuff is quite old.

I managed to find a copy of tirpc99 and the code layout looks very
different. Get it from http://members.plug.org.au/~raven/tirpc99/.

We would need to review the license as I think there's a reason we see
the tirpc 2.3 version everywhere.

Ian


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
