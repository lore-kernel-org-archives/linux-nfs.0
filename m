From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: NFS as a Cluster File System.
Date: Tue, 14 Jan 2003 09:11:31 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15907.14739.901913.204484@notabene.cse.unsw.edu.au>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
	<3E1DE9D6.7040406@unix.sh>
	<15907.5456.68906.820989@notabene.cse.unsw.edu.au>
	<1042489523.2807.291.camel@localhost>
	<15907.9286.737016.365337@notabene.cse.unsw.edu.au>
	<1042491056.2806.312.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Robertson <alanr@unix.sh>,
    Lorn Kay <lorn_kay@hotmail.com>,
    NFS mailing list <nfs@lists.sourceforge.net>,
    linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YCo9-00006Z-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 14:11:49 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <dritch@hpti.com>) (for <alanr@unix.sh>)
	(for <lorn_kay@hotmail.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-ha@muc.de>) By tone With Smtp ;
	Tue, 14 Jan 2003 09:11:39 +1100
To: "David B. Ritch" <dritch@hpti.com>
In-Reply-To: message from David B. Ritch on  January 13
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

On  January 13, dritch@hpti.com wrote:
> That makes sense.  However, it is common practice in many shops to write
> intermediate data files with some sort of serial number or timestamp in
> the name, and for the next step in the process to look for data using
> "ls" with a wildcard.  When doing that, you don't know what the name of
> the next file might be, so you can't simply open it.

I don't think that this should be a problem for NFS.  To do the 'ls'
or to expand the wildcard you need to open the directory (and do a
readdir) and this should cause the client to check with the server.
Once you have the name the open should work.

> 
> While I agree that this is not the most ideal method for coordinating
> processing, it is widely used and I have found a need to support it.

It seems reasonable to me.

> 
> We've also had processes fail with a "file not found" error when trying
> to read a file recently written by a process on another node.  It has
> always been my belief that this was a failure when a process tried to
> open the file, and the local metadata cache had not yet been updated. 
> Just to clarify - are you saying that the open system call should have
> contacted the server, even if the local cached information said that the
> file (and perhaps its parent directory) did not exist?

Hmmm... My understanding of NFS and 'close to open' semantics is that
on 'open' the client should definately contact the server, atleast to
do a GETATTR on the file, and possibly to do a LOOKUP if there is
doubt as to the current information in the name cache.

However the Linux VFS is not very friendly to network filesystems in
this respect.  The NFS client doesn't know if a given name lookup is
for an "open" or for a "stat" and so it cannot impose it's subtley
different semantics.

So I can well imagine an "open" on a file that another client has just
created failing, if a recent name lookup has said that it didn't
exist.

However if you always do an opendir/readdir first, and only try to
open files that were found in the readdir, then the client should be
able to reliably detect the change to the directory and submit a new
LOOKUP request.  I don't know if the Linux NFS client does this or
not.

I think it is fair to say that Linux isn't really ready for this sort
of tightly-coupled-network-filesystem thing yet.  The VFS just isn't
ready.  It doesn't even allow O_CREAT|O_EXCL to work over NFS even
though the NFSv3 protocol supports.  
The implementers of Lustre has enhanced the VFS for their use.  This
may get into mainline in 2.7 (too late for 2.6), or something else
might be developed.

With careful coding it should be possible to achieve any particular
result, but you really need to know exactly what functionality the NFS
client does, and does not, provide.

[[ NOTE: these replies aren't making it to  linux-ha@muc.de as I am
not a subscriber.  Feel free to forward them if you think that is
appropriate]]

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
