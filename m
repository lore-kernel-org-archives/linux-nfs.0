From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: Re: NFS as a Cluster File System.
Date: 13 Jan 2003 15:25:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1042489523.2807.291.camel@localhost>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
	 <3E1DE9D6.7040406@unix.sh>
	 <15907.5456.68906.820989@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alan Robertson <alanr@unix.sh>, Lorn Kay <lorn_kay@hotmail.com>,
   NFS mailing list <nfs@lists.sourceforge.net>, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sl-highp1-1-0.sprintlink.net ([144.228.5.138] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YB9N-00037M-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 12:25:37 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15907.5456.68906.820989@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I agree that cache coherency is not a sensible goal for a cluster
filesystem.  However, cache coherency of metadata is rather important. 
For example, when one node creates a file of intermediate data, it is
important for the other nodes to be able to see that.  Using actime=0 is
the conventional mechanism for allowing file creation and deletion to be
propagated quickly.  Usually, one can tweak that a bit to reduce the
burden on the server.  However, it might be be nice if there were a
mechanism to propagate this sort of metadata change without dumping all
metadata over a second or two old.

dbr

On Mon, 2003-01-13 at 14:36, Neil Brown wrote:
> On Thursday January 9, alanr@unix.sh wrote:
> > 
> > NFS V3 and before have problems with "cache coherency".  That is, the 
> > different nodes in the cluster are not guaranteed to see the same contents.
> > 
> > I think this is supposed to be fixed in v4.
> > 
> 
> NFSv4 does not try to "fix" this.  It makes no attempts at "cache
> coherency" beyond what NFSv2/3 provide which is "close to open"
> cohenrence, meaning that if only one process has a file open at a
> time, then everythnig will appear coherent, and if multiple processes
> have the file open at the same time, they need to use record locking.
> 
> I really don't think total cache coherency is a sensible goal for a
> network filesystem, even a cluster filesystem.  It imposes lots of
> extra network traffic that most of the time will be of no value.
> If an application needs some degree of coherence, it should be
> explicit about it's needs (using open/close or locking) so that the
> protocol can provide it then, and only then.
> 
> NeilBrown
> 
> 
> -------------------------------------------------------
> This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
> are you planning your Web Server Security? Click here to get a FREE
> Thawte SSL guide and find the answers to all your  SSL security issues.
> http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
-- 
David B. Ritch
High Performance Technologies, Inc.


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
