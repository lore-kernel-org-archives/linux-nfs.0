From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: take away nfs write permissions instantly
Date: Fri, 21 Jun 2002 13:00:49 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15634.38625.279876.874050@notabene.cse.unsw.edu.au>
References: <3D11B0FF.8030008@psi.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17LEei-00025U-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Jun 2002 20:00:12 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <rene.kapeller@psi.ch>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 21 Jun 2002 13:00:01 +1000
To: Kapeller Rene PSI <rene.kapeller@psi.ch>
In-Reply-To: message from Kapeller Rene PSI on Thursday June 20
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Thursday June 20, rene.kapeller@psi.ch wrote:
> Can anyone help me on the following problem:
> 
> In order to take away nfs write permissions instantly for a previously 
> mounted
> nfs directory called '/data', I'm changing the export options for '/data'
> on the server to 'ro', while keeping the mount on the client.
> 
> exportfs -io ro,sync,wdelay,no_root_squash nfsclient:/data
                                             ^^^^^^^^^
> 
> exportfs -v
> /data   nfsserver(ro,wdelay,no_root_squash)
          ^^^^^^^^^

Presumably both should read "nfsclient" - yes?

This should work.

What version of nfs-utils are you using?? (showmount -v)

What does /proc/fs/nfs/exports say for nfsclient after you try to
re-export it?

Can you give more details?  What is in /etc/exports that relates to
the client (is it a wildcard export, a netgroup export...)..

NeilBrown


-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
