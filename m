From: Greg Banks <gnb@sgi.com>
Subject: Re: Marking inodes as stale can be wrong
Date: Fri, 30 Apr 2004 09:50:18 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040429235018.GC4843@sgi.com>
References: <20040429144012.GA15361@suse.de> <1083257096.3686.27.camel@lade.trondhjem.org> <20040429165802.GA18748@suse.de> <1083258570.3686.38.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJLJb-00029u-P7
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 16:51:39 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJLJb-0000Uk-G8
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 16:51:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083258570.3686.38.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Apr 29, 2004 at 01:09:30PM -0400, Trond Myklebust wrote:
> On Thu, 2004-04-29 at 12:58, Olaf Kirch wrote:
> > On Thu, Apr 29, 2004 at 12:44:56PM -0400, Trond Myklebust wrote:
> > > On Thu, 2004-04-29 at 10:40, Olaf Kirch wrote:
> > > > 	fh_verify did the subtree check, and found that
> > > > 	~/Mail was mode 700, and hence user nobody didn't
> > > > 	have x permissions on the directory. So it would
> > > > 	return ESTALE to the client.
> > > 
> > > This is a bug!
> > 
> > Yes, probably. Even though I'm not entirely sure NFSERR_ACCES is a valid
> > return for all NFS operations.
> 
> The problem is that Neil is using NFSERR_STALE as a standin for
> NFSERR_ACCES precisely because the latter is not on the list of accepted
> return value for GETATTR in RFC1813.
> IMO this is *worse* behaviour than just returning the non-rfc compatible
> error.

FWIW there's a little known sentence in RFC1813 Section 3 which says

> The ERRORS section lists the errors returned for specific types of
> failures. These lists are not intended to be the definitive statement
> of all of the errors which can be returned by any specific procedure,
> but as a guide for the more common errors which may be returned.

This has been interpreted in discussions here as a loophole that allows
the server to return any of the defined NFS errors for any of the calls
at its discretion.

I don't know why the server returns NFSERR_STALE instead of NFSERR_ACCES,
but RFC compliance is not a good reason.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
