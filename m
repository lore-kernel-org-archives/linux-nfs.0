From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Thu, 17 May 2007 17:12:02 +1000
Message-ID: <20070517071202.GE27247@sgi.com>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Greg Banks <gnb@sgi.com>, Peter Leckie <pleckie@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hoa9f-0008TR-Qc
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:12:07 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Hoa9i-0004wo-Gu
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:12:10 -0700
In-Reply-To: <20070516211053.GE18927@fieldses.org>
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

On Wed, May 16, 2007 at 05:10:53PM -0400, J. Bruce Fields wrote:
> On Thu, May 17, 2007 at 05:22:11AM +1000, Greg Banks wrote:
> > +	set_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	if (required*2 > wspace) {
> > +		/* Don't enqueue while not enough space for reply */
> > +		dprintk("svc: socket %p  no space, %d*2 > %d, not enqueued\n",
> > +			svsk->sk_sk, required, wspace);
> > +		return 0;
> > +	}
> > +	clear_bit(SOCK_NOSPACE, &svsk->sk_sock->flags);
> > +	return 1;
> > +}
> 
> So, this is just my ignorance--why do the set and clear of SOCK_NOSPACE
> need to be ordered in the way they are?  (Why not just set once inside
> the if clause?)

I can't see a good reason for it, but I'm trying to minimise
perturbations to the logic.

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
