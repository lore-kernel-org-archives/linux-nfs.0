From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Fri, 18 May 2007 16:00:57 +1000
Message-ID: <20070518060057.GF5104@sgi.com>
References: <20070516192047.GI9626@sgi.com>
	<17996.13075.692664.968549@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HovWQ-0002iO-3v
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 23:01:02 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1HovWS-0004B2-PM
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 23:01:05 -0700
In-Reply-To: <17996.13075.692664.968549@notabene.brown>
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

On Thu, May 17, 2007 at 08:48:51PM +1000, Neil Brown wrote:
> On Thursday May 17, gnb@sgi.com wrote:
> > 
> > Move the code at the beginning of svc_process() that sets up
> > page buffers for the reply, into a new sko_prepape_reply
> > method in svc_sock_ops.
> > 
> 
> > +static int
> > +svc_tcp_prepare_reply(struct svc_rqst *rqstp)
> > +{
> > +	struct kvec *resv = &rqstp->rq_res.head[0];
> > +
> > +	svc_tcpip_prepare_reply(rqstp);
> > +
> > +	/* tcp needs a space for the record length... */
>                      ^^
> 
> I appreciate that you are copying a comment verbatim, but can we drop
> the 'a'? 
> 

Fixed.  It now reads

+       /* tcp needs room for the record length... */


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
