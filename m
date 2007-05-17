From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Thu, 17 May 2007 17:53:42 +1000
Message-ID: <20070517075342.GG27247@sgi.com>
References: <20070516192047.GI9626@sgi.com>
	<C270E33B.3042D%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hoany-0003vn-MK
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:53:46 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+Cwfv02H5Q6+kqlHXUfd/jDlk4+KsUxYs=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hoao0-0005sS-E8
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 00:53:49 -0700
In-Reply-To: <C270E33B.3042D%tom@opengridcomputing.com>
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

On Wed, May 16, 2007 at 04:35:07PM -0500, Tom Tucker wrote:
> 
> Greg:
> 
> I like this patch organization. I'll replicate this in the integrated
> tree... 

Great.

> > + /* Will be turned off only in gss privacy case: */
> > + rqstp->rq_sendfile_ok = 1;
> 
> I think this belongs in the svc_process logic. It doesn't have anything to
> do with the buffer, but rather whether or not GSS is turned on.

Fixed.

I'll push a revised patchset including feedback from yourself
and Bruce, to you only, in a few minutes.

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
