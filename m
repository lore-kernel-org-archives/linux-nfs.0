From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: NFS as a Cluster File System.
Date: Tue, 14 Jan 2003 07:40:38 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15907.9286.737016.365337@notabene.cse.unsw.edu.au>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
	<3E1DE9D6.7040406@unix.sh>
	<15907.5456.68906.820989@notabene.cse.unsw.edu.au>
	<1042489523.2807.291.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Robertson <alanr@unix.sh>,
    Lorn Kay <lorn_kay@hotmail.com>,
    NFS mailing list <nfs@lists.sourceforge.net>,
    linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YBOb-0005vW-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 12:41:21 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <dritch@hpti.com>) (for <alanr@unix.sh>)
	(for <lorn_kay@hotmail.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-ha@muc.de>) By tone With Smtp ;
	Tue, 14 Jan 2003 07:40:52 +1100
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
> I agree that cache coherency is not a sensible goal for a cluster
> filesystem.  However, cache coherency of metadata is rather important. 
> For example, when one node creates a file of intermediate data, it is
> important for the other nodes to be able to see that.  Using actime=0 is
> the conventional mechanism for allowing file creation and deletion to be
> propagated quickly.  Usually, one can tweak that a bit to reduce the
> burden on the server.  However, it might be be nice if there were a
> mechanism to propagate this sort of metadata change without dumping all
> metadata over a second or two old.

If the 'other nodes' open the file and look in it, then they should
see current data (if they don't it's a bug).  If they just 'stat' it
to see if it has changed then they may see and old timestamp.

I recommend openning the file.  It is an explicit way for the
application to say "I really want to know the current state of this
file". 

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
