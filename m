From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: nfs v3: chown not permitted
Date: Tue, 23 Mar 2004 10:18:51 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040323091851.GA11416@janus>
References: <20040322143922.GA2452@posern.org> <20040322150642.GC23862@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5i4T-000762-EC
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 01:19:41 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5i4T-00049N-0h
	for nfs@lists.sourceforge.net; Tue, 23 Mar 2004 01:19:41 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20040322150642.GC23862@suse.de>
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

On Mon, Mar 22, 2004 at 04:06:43PM +0100, Olaf Kirch wrote:
> On Mon, Mar 22, 2004 at 03:39:22PM +0100, foo@posern.org wrote:
> > me@jolie:/mnt$ groups
> > mine root adm disk lp dialout cdrom floppy audio www-data src video
> > prg data mp3 maildata newmp3 wg users lpadmin
> 
> You have too many groups. SunRPC AUTH_UNIX authentication will transport
> up to 16 groups, and "users" is item #19 in your list. "chgrp mp3"
> would probably work, but users doesn't because the NFS server doesn't
> see it in your list of groups.

The Linux 2.4 NFS client patch to bypass this limitation can be found here:

	http://frankvm.xs4all.nl/nfs-ngroups/

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
