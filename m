From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: NFS as a Cluster File System.
Date: Tue, 14 Jan 2003 06:36:48 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15907.5456.68906.820989@notabene.cse.unsw.edu.au>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
	<3E1DE9D6.7040406@unix.sh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lorn Kay <lorn_kay@hotmail.com>,
    nfs@lists.sourceforge.net,
    linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YAOS-0000yd-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 11:37:09 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <alanr@unix.sh>) (for <lorn_kay@hotmail.com>)
	(for <nfs@lists.sourceforge.net>) (for <linux-ha@muc.de>) By tone
	With Smtp ; Tue, 14 Jan 2003 06:36:52 +1100
To: Alan Robertson <alanr@unix.sh>
In-Reply-To: message from Alan Robertson on Thursday January 9
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

On Thursday January 9, alanr@unix.sh wrote:
> 
> NFS V3 and before have problems with "cache coherency".  That is, the 
> different nodes in the cluster are not guaranteed to see the same contents.
> 
> I think this is supposed to be fixed in v4.
> 

NFSv4 does not try to "fix" this.  It makes no attempts at "cache
coherency" beyond what NFSv2/3 provide which is "close to open"
cohenrence, meaning that if only one process has a file open at a
time, then everythnig will appear coherent, and if multiple processes
have the file open at the same time, they need to use record locking.

I really don't think total cache coherency is a sensible goal for a
network filesystem, even a cluster filesystem.  It imposes lots of
extra network traffic that most of the time will be of no value.
If an application needs some degree of coherence, it should be
explicit about it's needs (using open/close or locking) so that the
protocol can provide it then, and only then.

NeilBrown


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
