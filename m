From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 13:09:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083258570.3686.38.camel@lade.trondhjem.org>
References: <20040429144012.GA15361@suse.de>
	 <1083257096.3686.27.camel@lade.trondhjem.org>
	 <20040429165802.GA18748@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJF2U-0000Bj-Oe
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 10:09:34 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BJF2U-0000wX-Ee
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 10:09:34 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040429165802.GA18748@suse.de>
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

On Thu, 2004-04-29 at 12:58, Olaf Kirch wrote:
> On Thu, Apr 29, 2004 at 12:44:56PM -0400, Trond Myklebust wrote:
> > On Thu, 2004-04-29 at 10:40, Olaf Kirch wrote:
> > > 	fh_verify did the subtree check, and found that
> > > 	~/Mail was mode 700, and hence user nobody didn't
> > > 	have x permissions on the directory. So it would
> > > 	return ESTALE to the client.
> > 
> > This is a bug!
> 
> Yes, probably. Even though I'm not entirely sure NFSERR_ACCES is a valid
> return for all NFS operations.

The problem is that Neil is using NFSERR_STALE as a standin for
NFSERR_ACCES precisely because the latter is not on the list of accepted
return value for GETATTR in RFC1813.
IMO this is *worse* behaviour than just returning the non-rfc compatible
error.

> However, machines with 2.4 will be out there for a while, so the question
> I'm asking myself is how to cope with those in the client.

I am totally uninterested in fixing up a broken server option (even if
it is a default option) inside the client. These "fixes" have a tendency
to persist for way too long in the kernel code, and end up causing way
more problems in the long run.

"subtree_check" has a number of other RFC-violating bugs (most notably
with cross-directory renames) that mean we should *never* have made it a
default option in the first place.
The correct workaround here is to advise people to *always* use
"no_subtree_check" and then to look into fixing these problems in future
revisions of the server, not the client.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
