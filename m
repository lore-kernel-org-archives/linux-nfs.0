From: Chris Caputo <ccaputo@alt.net>
Subject: cache/mmap()/server coherency problems
Date: Mon, 13 Jan 2003 20:56:55 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301132011250.12181-100000@nacho.alt.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nacho.alt.net ([207.14.113.18])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YJ8h-000809-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Jan 2003 20:57:27 -0800
To: nfs@lists.sourceforge.net
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

On 2.4.18 and 2.4.20 I am seeing the following problem:

 1) client A process C opens and mmaps (PROT_READ, MAP_SHARED) a file on
    an NFS server.  It keeps it mapped for the duration of the following
    steps.

 2) client B process D opens, adds data to the end of the same file, and 
    then closes it.

 3) client B process E runs md5sum on the file.

 4) client A process F runs md5sum on the file too.  But the result is 
    different than the result of the md5sum in step 3.

Under kernel 2.2.21 this problem did not happen.

An analysis of the file from client A shows that there are zeros in the
file (where there should be new text) between where process C originally
opened and mmaped the file and the end of a page boundary, ala:

  00aa3d0 3838 3631 0934 4341 5346 333a 312f 312f
  00aa3e0 3437 3737 6635 3162 6433 3d32 3639 2f36
  00aa3f0 0a31 0000 0000 0000 0000 0000 0000 0000
  00aa400 0000 0000 0000 0000 0000 0000 0000 0000
  *
  00ab000 6134 2e78 6f63 3e6d 3c09 3631 7473 7631
  00ab010 3438 3776 6371 3870 6462 6a76 3066 686c
  00ab020 7061 3034 6738 6d37 3033 6661 3440 7861
  00ab030 632e 6d6f 203e 303c 6264 3132 3834 6465

Now, if the mmap from step 1 is munmaped and the file is closed the file
will still be corrupted.  I assume this is because the file is still in
the file cache and it is not accurate there too.  Once it has been purged
from the file cache, when I then run md5sum, the checksum is correct.

Is this expected behavior?

I was thinking that when the file is opened, the lookup NFS call will
result in new file size info being shared with the VFS, and the VFS would
know that the data in any page cached, beyond its previously known file
length, is invalid and that the whole page would need to be reloaded next
time the file is accessed.  This all seems to happen, except when someone
has mmaped the file...

Chris



-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
