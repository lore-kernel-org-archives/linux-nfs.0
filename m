From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [pme@devphil.com: Bug#239158: Strange exportfs problems,
 fantastically unhelpful error message]
Date: Mon, 22 Mar 2004 21:12:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <405EBC03.AABE5502@melbourne.sgi.com>
References: <20040321153515.GW29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5MQ1-0006qB-9U
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 02:12:29 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5MQ0-0001S5-Nu
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 02:12:28 -0800
To: Chip Salzenberg <chip@pobox.com>
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

Chip Salzenberg wrote:
> 
> This Debian bug report includes an exportfs problem which I suspect is
> due to one export tree under the other, 

Possibly, if one of /usr/local or /home is a symlink to somewhere
underneath the other.

> and an error message complaint
> which I think is justified....

I second this complaint.  On other OSes that case is checked in
userspace early and a sensible message printed, e.g.

irix# exportfs -av
re-exported /
exportfs: /opt: parent-directory (/) already exported
re-exported /mnt/scratch

> I have no idea why the export fails.  If either line is commented, then
> the export succeeds; presumably that's strong evidence of /something/,
> but I don't know the nfs-kernel-server code at all and so can't say what.

You can get a better idea of what is failing by:

linux# echo 4 > /proc/sys/sunrpc/nfsd_debug

linux# exportfs -av
exporting foo.melbourne.sgi.com:/home/fmeh
exporting bar.melbourne.sgi.com:/home/fmeh
exporting foo.melbourne.sgi.com:/home
exporting bar.melbourne.sgi.com:/home
exporting foo.melbourne.sgi.com:/home/fmeh to kernel
exporting bar.melbourne.sgi.com:/home/fmeh to kernel
exporting foo.melbourne.sgi.com:/home to kernel
foo.melbourne.sgi.com:/home: Invalid argument
exporting bar.melbourne.sgi.com:/home to kernel
bar.melbourne.sgi.com:/home: Invalid argument

linux# tail /var/log/messages
...
Mar 22 09:49:53 4A:quux kernel: exp_export called for foo.melbourne.sgi.com:/home
(403/54526548 fl 24).
Mar 22 09:49:53 4A:quux kernel: exp_export: export not valid (Rule 3).  <------
Mar 22 09:49:53 4A:quux kernel: exp_export called for bar.melbourne.sgi.com:/home
(403/54526548 fl 24).
Mar 22 09:49:53 4A:quux kernel: exp_export: export not valid (Rule 3).  <------

The error message tells you...indirectly...what is going on.  You need
to match it to the source of fs/nfsd/export.c:exp_export() to make any
sense of it.  The "Rule 3" message happens when a child of the given
directory is already exported.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
