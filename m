From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: Re: > 16 groups patch from Frank van Maarseveen
Date: Sun, 1 Aug 2004 10:50:12 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040801085012.GB28625@janus>
References: <1091207680.4797.47.camel@dyn319648.beaverton.ibm.com> <1091212800.3804.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BrC2p-0004Ik-3n
	for nfs@lists.sourceforge.net; Sun, 01 Aug 2004 01:50:15 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BrC2o-0003bM-LM
	for nfs@lists.sourceforge.net; Sun, 01 Aug 2004 01:50:15 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1091212800.3804.17.camel@lade.trondhjem.org>
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

On Fri, Jul 30, 2004 at 01:40:00PM -0500, Trond Myklebust wrote:
> 
> I'm certainly not prepared to merge any new features into the 2.4
> kernel, so the patches as they stand are not going in no matter what.

What about 2.6?

Right now I'm considering porting the patch to 2.6.7 so any advice which
might help getting it merged is welcome.

> However now that we have RPCSEC_GSS
> with support for strong authentication (such as w/ krb5), it is possible
> for the server to know exactly which groups the user is a member of.

That may not be an option.

> 
> Why go for a heuristic algorithm, when there are deterministic ones that
> can do better?

The patch is pretty deterministic.

What made me reluctant writing a new version of the patch is that it would
most likely turn out to be more intrusive, further reducing chances of
getting it merged.

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
