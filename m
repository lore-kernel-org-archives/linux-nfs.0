From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 9/14] knfsd: centralise SK_CONN handling
Date: Fri, 18 May 2007 17:50:11 +1000
Message-ID: <20070518075011.GI5104@sgi.com>
References: <20070516192554.GO9626@sgi.com>
	<17996.13933.338662.129612@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Thomas Talpey <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoxEE-0005hv-1x
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 00:50:22 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+zE2O6bAGgLJz/57eMJ8HWe0D2XMmvnWM=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoxEF-0002p0-Ra
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 00:50:25 -0700
In-Reply-To: <17996.13933.338662.129612@notabene.brown>
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

On Thu, May 17, 2007 at 09:03:09PM +1000, Neil Brown wrote:
> On Thursday May 17, gnb@sgi.com wrote:
> > 
> > Centralise the handling of the SK_CONN bit to that future
>                                              ^^ so
> :-)
> 

Fixed.

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
