From: Neil Brown <neilb@suse.de>
Subject: Re: Clients not displaying NFS quotas
Date: Mon, 7 May 2007 11:19:38 +1000
Message-ID: <17982.32426.148387.521946@notabene.brown>
References: <200705030213.l432DFce017563@turbo.physics.adelaide.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HkrtR-0000ez-Pf
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 18:20:01 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HkrtT-0003Cl-TC
	for nfs@lists.sourceforge.net; Sun, 06 May 2007 18:20:04 -0700
In-Reply-To: message from Jonathan Woithe on Thursday May 3
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday May 3, jwoithe@physics.adelaide.edu.au wrote:
> We have a Slackware 9.1 box (with numerous software upgrades) exporting a
> directory to various NFS clients.  While running a 2.4.x kernel this all
> worked fine - users on clients could use "quota" to display their quota
> information.  When the system was moved to a 2.6.19.2 kernel a few months
> ago the clients could no longer display quota information.  The server
> still knew and enforced the quotas, it's just that from the client's
> point of view there were no quotas.
> 
> The system is running the following software versions:
> 
>   * kernel 2.6.19.2
>   * nfs-utils 1.0.10
>   * util-linux 2.12
>   * portmap 5.0
> 
> The filesystem concerned is reiserfs3.  The kernel has reiserfs quota
> support enabled.

Hmm... what "rquotad" is running?  It appears that both the "quota"
package and the "nfs-utils" package contains "rquotad".   And the one
in nfs-utils is fairly thoroughly broken (only recognises ext2 and
ext3 for a start).

You can tell which you are using by running it with "-v".
e.g.
   /usr/sbin/rpc.rquotad -v

The "nfs-utils" one will say 
   rquotad 1.0.10
The "quota" one will give a "Usage" message because it doesn't
understand -v.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
