From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Move (mv) hangs with NFSv4
Date: Tue, 7 Dec 2004 10:52:27 -0500
Message-ID: <20041207155227.GG31250@fieldses.org>
References: <41B0A79A.2010203@drzeus.cx> <1102097931.10878.21.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pierre Ossman <drzeus-list@drzeus.cx>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbhdZ-00016Q-1l
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 07:52:25 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CbhdY-0002Lh-84
	for nfs@lists.sourceforge.net; Tue, 07 Dec 2004 07:52:24 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1102097931.10878.21.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

On Fri, Dec 03, 2004 at 01:18:51PM -0500, Trond Myklebust wrote:
> fr den 03.12.2004 Klokka 18:51 (+0100) skreiv Pierre Ossman:
> 
> > There is no error message on the server. On the client I get "RPC: 
> > rpciod waiting on sync task!" now and then. Most of the time it doesn't 
> > say a thing though so I'm not sure it's related.
> 
> The "rpciod waiting on sync task" is a known problem that should
> normally only occur if you ^C out. I'm still working on a complete fix
> for that.
> 
> As for the other hang: I'm not reproducing it against non-linux servers.
> Bruce, any ideas?

Hm.  With our latest kernel and user utilities I actually get a segfault
on cp -a from the getxattr to get the acl on the source file.  Probably
a bug our modified libacl, ugh.  In any case, probably also a different
bug from what he's seeing.  Maybe I could see a pcap file or an strace
of the cp -a showing where it hangs?

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
