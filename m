From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] SGI 907674: document fsid export option
Date: Tue, 24 Feb 2004 14:39:25 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16442.51053.96888.392883@notabene.cse.unsw.edu.au>
References: <40188282.36FBA905@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvTQO-0005T3-Em
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 19:40:00 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AvTPx-0000Un-MH
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 19:39:33 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gnb@melbourne.sgi.com>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Tue, 24 Feb 2004 14:39:26 +1100
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Thursday January 29
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

On Thursday January 29, gnb@melbourne.sgi.com wrote:
> G'day,
> 
> This patch against nfs-utils 1.0.6 documents the fsid=num export
> option.

Thanks.  I've added a paragraph about the special meaning of fsid=0
for NFSv4 and committed it to CVS.

NeilBrown

> 
> --- nfs-utils-sgi/nfs-utils-1.0.6/utils/exportfs/exports.man	Thu Jan 29 13:52:34 2004
> +++ nfs-utils-work/nfs-utils-1.0.6/utils/exportfs/exports.man	Thu Jan 29 14:22:17
> 2004
> @@ -271,6 +271,24 @@
>  then the nominted path must be a mountpoint for the exportpoint to be
>  exported.
>  
> +.TP
> +.IR fsid= num
> +This option forces the filesystem identification portion of the file
> +handle and file attributes used on the wire to be
> +.I num
> +instead of a number derived from the major and minor number of the
> +block device on which the filesystem is mounted.  Any 32 bit number
> +can be used, but it must be unique amongst all the exported filesystems.
> +
> +This can be useful for NFS failover, to ensure that both servers of
> +the failover pair use the same NFS file handles for the shared filesystem
> +thus avoiding stale file handles after failover.
> +
> +Some Linux filesystems are not mounted on a block device; exporting
> +these via NFS requires the use of the 
> +.I fsid
> +option (although that may still not be enough).
> +
>  .SS User ID Mapping
>  .PP
>  .I nfsd
> 
> 
> Greg.
> -- 
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> I don't speak for SGI.
> 
> 
> -------------------------------------------------------
> The SF.Net email is sponsored by EclipseCon 2004
> Premiere Conference on Open Tools Development and Integration
> See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
> http://www.eclipsecon.org/osdn
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
