From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: empty /etc/exports causes nfs rc script to exit
Date: Mon, 3 Feb 2003 12:10:56 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15933.49568.944151.870943@notabene.cse.unsw.edu.au>
References: <Pine.LNX.4.44.0302031125590.16330-100000@sherman.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18fV8w-0007JO-00
	for <nfs@lists.sourceforge.net>; Sun, 02 Feb 2003 17:11:26 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <markgw@sgi.com>) (for <nfs@lists.sourceforge.net>) By tone With
	Smtp ; Mon, 3 Feb 2003 12:11:15 +1100
To: Mark Goodwin <markgw@sgi.com>
In-Reply-To: message from Mark Goodwin on Monday February 3
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

On Monday February 3, markgw@sgi.com wrote:
> 
> Is there some good reason why the nfs rc script exits if /etc/exports
> is empty?  [ -s /etc/exports ] || exit 0

Empty (or non-existant) /etc/exports means that you don't want to
export anything, so the relevant daemons aren't run at all.

> 
> If an admin adds something to /etc/exports, they have to kick the
> rc script too. Seems silly.

If you want to start a service that wasn't previously configured, then
running the rc script is the normal thing to do.

Put a comment in /etc/exports if you really want the daemons, but no
exports.

NeilBrown


> 
> -- Mark
> 
> 
> 
> -------------------------------------------------------
> This SF.NET email is sponsored by:
> SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
> http://www.vasoftware.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
