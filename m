From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: NFS client eventually stalls with automount
Date: Wed, 26 Jun 2002 20:53:23 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020626205323.A19030@lucon.org>
References: <3D1A5B18.7050601@scripps.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-143-38.client.attbi.com ([12.234.143.38] helo=ocean.lucon.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17NQLW-0006HY-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Jun 2002 20:53:26 -0700
To: Michael Feig <meikel@scripps.edu>
In-Reply-To: <3D1A5B18.7050601@scripps.edu>; from meikel@scripps.edu on Wed, Jun 26, 2002 at 05:23:52PM -0700
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

On Wed, Jun 26, 2002 at 05:23:52PM -0700, Michael Feig wrote:
> shows up when trying to create a tar file)
> on an automounted directory the process starts up fine, but pretty 
> quickly slows down and eventually
> 
> I ran into this with the RedHat 7.3 distribution kernel (2.4.18) but 
> also tried the very latest 2.4.19-rc1 with
> Trond's latest NFS_ALL patches (for pre10).

I won't use autofs in RedHat 7.3 myself. It doesn't even support
autofs4.


H.J.


-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabberConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
