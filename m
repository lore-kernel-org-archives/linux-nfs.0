From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs-utils 1.0.8-rc1
Date: Fri, 6 Jan 2006 12:58:13 -0500
Message-ID: <20060106175813.GE4759@fieldses.org>
References: <17314.22172.913247.595571@cse.unsw.edu.au> <1134718387.3699.10.camel@lade.trondhjem.org> <17318.4720.969963.469187@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Euvr8-0000rZ-KS
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 09:58:26 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Euvr6-0005jw-Ay
	for nfs@lists.sourceforge.net; Fri, 06 Jan 2006 09:58:26 -0800
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17318.4720.969963.469187@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
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

On Mon, Dec 19, 2005 at 12:52:48PM +1100, Neil Brown wrote:
> 75 	nor 	P3 	Oth 	bfields@fieldses.org 	NEW 		pseudofilesystem paths are confusing and v3-incompatible
> 
>   That's a fair comment, but the solution isn't obvious.
>   The apparently straight forward approach might be:
>     If 'fsid=0' isn't given in /etc/exports, then auto-export
>       /var/lib/nfs/pseudo-root
>     as fsid=0,ro,... and bind-mount all other exported filesystems
>     into a suitable place in there.

Yes, I've thought about doing something like that.  It has the advantage
that we can fix everything in nfs-utils, without needing new kernel
interfaces.

Another change is needed so that mountd doesn't report that it's
exporting a bunch of paths starting with /var/lib/nfs/pseudo-root.  We'd
need to hide that part of any such path from the mount protocol
entirely--so the export

	/var/lib/nfs/pseudo-root/path

would be referred to as "/path" for the purposes of mount requests and
responses.

Should we start coding all this?  I'm a little nervous about making
exportfs suddenly do a bunch of bind mounts behind the administrators
back, but I guess we can control that behaviour with configuration
and/or commandline operations and let administrators and users decide
how to handle the transition.

--b.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
