From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: Re: [sdg@dir.bg: Bug#239230: nfs-kernel-server: exportfs fails to export a dir with a ``#'' (pound sign) in name even when ``#'' is given as \043]
Date: Mon, 22 Mar 2004 12:28:34 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322112834.GA8229@janus>
References: <20040321171325.GX29237@perlsupport.com> <20040322095358.GC11393@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5NcX-0007ED-Ky
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 03:29:29 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B5NcW-0003rB-Gv
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 03:29:28 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20040322095358.GC11393@suse.de>
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

On Mon, Mar 22, 2004 at 10:53:58AM +0100, Olaf Kirch wrote:
> On Sun, Mar 21, 2004 at 12:13:25PM -0500, Chip Salzenberg wrote:
> > 	Blank  lines  are  ignored.  A pound sign ("#") introduces a comment to
> > 	the end of the line.
> 
> He should try /weird-dir-\#

IMO it is better to recognize comment only when the '#' is preceded by
white space (or start of line), similar to what /bin/sh does.


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
