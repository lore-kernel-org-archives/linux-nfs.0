From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: Re: NFS as a Cluster File System.
Date: 13 Jan 2003 15:50:56 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1042491056.2806.312.camel@localhost>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
	 <3E1DE9D6.7040406@unix.sh>
	 <15907.5456.68906.820989@notabene.cse.unsw.edu.au>
	 <1042489523.2807.291.camel@localhost>
	 <15907.9286.737016.365337@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alan Robertson <alanr@unix.sh>, Lorn Kay <lorn_kay@hotmail.com>,
   NFS mailing list <nfs@lists.sourceforge.net>, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sl-highp1-1-0.sprintlink.net ([144.228.5.138] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YBY7-0000LR-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 12:51:12 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15907.9286.737016.365337@notabene.cse.unsw.edu.au>
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

That makes sense.  However, it is common practice in many shops to write
intermediate data files with some sort of serial number or timestamp in
the name, and for the next step in the process to look for data using
"ls" with a wildcard.  When doing that, you don't know what the name of
the next file might be, so you can't simply open it.

While I agree that this is not the most ideal method for coordinating
processing, it is widely used and I have found a need to support it.

We've also had processes fail with a "file not found" error when trying
to read a file recently written by a process on another node.  It has
always been my belief that this was a failure when a process tried to
open the file, and the local metadata cache had not yet been updated. 
Just to clarify - are you saying that the open system call should have
contacted the server, even if the local cached information said that the
file (and perhaps its parent directory) did not exist?

Thanks,

dbr

On Mon, 2003-01-13 at 15:40, Neil Brown wrote:
> On  January 13, dritch@hpti.com wrote:
> > I agree that cache coherency is not a sensible goal for a cluster
> > filesystem.  However, cache coherency of metadata is rather important. 
> > For example, when one node creates a file of intermediate data, it is
> > important for the other nodes to be able to see that.  Using actime=0 is
> > the conventional mechanism for allowing file creation and deletion to be
> > propagated quickly.  Usually, one can tweak that a bit to reduce the
> > burden on the server.  However, it might be be nice if there were a
> > mechanism to propagate this sort of metadata change without dumping all
> > metadata over a second or two old.
> 
> If the 'other nodes' open the file and look in it, then they should
> see current data (if they don't it's a bug).  If they just 'stat' it
> to see if it has changed then they may see and old timestamp.
> 
> I recommend openning the file.  It is an explicit way for the
> application to say "I really want to know the current state of this
> file". 
> 
> NeilBrown
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
