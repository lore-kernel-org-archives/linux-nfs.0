From: Olaf Kirch <okir@suse.de>
Subject: Re: nfs v3: chown not permitted
Date: Mon, 22 Mar 2004 16:06:43 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322150642.GC23862@suse.de>
References: <20040322143922.GA2452@posern.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5R2S-00010y-Pu
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 07:08:28 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5R2Q-0005TD-Va
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 07:08:28 -0800
To: foo@posern.org
In-Reply-To: <20040322143922.GA2452@posern.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, Mar 22, 2004 at 03:39:22PM +0100, foo@posern.org wrote:
> me@jolie:/mnt$ groups
> mine root adm disk lp dialout cdrom floppy audio www-data src video
> prg data mp3 maildata newmp3 wg users lpadmin

You have too many groups. SunRPC AUTH_UNIX authentication will transport
up to 16 groups, and "users" is item #19 in your list. "chgrp mp3"
would probably work, but users doesn't because the NFS server doesn't
see it in your list of groups.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
