From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Does mountd/statd really need to listen on a privileged
 port??
Date: Thu, 19 Apr 2007 11:15:32 -0400
Message-ID: <46278794.6050307@RedHat.com>
References: <17950.44333.118970.276558@notabene.brown>	<4623BCD9.3090501@RedHat.com>	<200704171208.51797.olaf.kirch@oracle.com>	<17957.50539.958277.446719@notabene.brown>
	<17958.48121.280256.493824@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>, jfs@computer.org,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeYMw-00041I-W6
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 08:16:23 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeYMz-0006G9-0r
	for nfs@lists.sourceforge.net; Thu, 19 Apr 2007 08:16:25 -0700
In-Reply-To: <17958.48121.280256.493824@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net



Neil Brown wrote:
> 
> But that doesn't help with lockd, does it?
> Lockd registers a non-priv port, and fixing that is not trivial.
> We really should be fixing portmap.
I agree...

> 
> Portmap appeared to be a 10 year old program that each distro
> maintains their own copy of...
Well with Fedora Core 7, the pormapper has been replaced with
Bull's rpcbind which will help in the migration to to IPv6
(among other things like warms starts).

> 
> What would people think if I added it to the nfs-utils release and
> made some improvements?  Would that get into distros in parallel with
> nfs-utils?
Pormap/rpcbind is an RPC thing... not an NFS thing... Meaning
there are other service (i.e. NIS) that needed it... so I
really don't think it makes sense to include Pormap/rpcbind
in nfs-utils...

But... that does not mean an "upstream version" of rpcbind
can be maintained by a single entity that everyone (including
the distros) can pull from... Something I could (and would)
support...


steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
