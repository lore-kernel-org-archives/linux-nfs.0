From: Mark Price <mkprice@us.ibm.com>
Subject: wsize & PAGE_SIZE issues on IA64 clients.
Date: Thu, 27 Mar 2003 13:24:28 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0303271219410.2496-100000@mprice-laptop.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yeqT-0000hy-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 13:23:33 -0800
Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e31.co.us.ibm.com (8.12.8/8.12.2) with ESMTP id h2RLMZWO102344
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 16:22:35 -0500
Received: from gateway.beaverton.ibm.com (gateway.beaverton.ibm.com [138.95.180.1])
	by westrelay03.boulder.ibm.com (8.12.8/NCO/VER6.5) with ESMTP id h2RLNFFv134364
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 14:23:15 -0700
Received: from crg8.beaverton.ibm.com (crg8.beaverton.ibm.com [9.47.57.33])
	by gateway.beaverton.ibm.com (8.11.6/8.11.6) with ESMTP id h2RLMFn12704
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 13:22:15 -0800
Received: from dyn9-47-9-142.beaverton.ibm.com (dyn9-47-9-142.beaverton.ibm.com [9.47.9.142])
	by crg8.beaverton.ibm.com (8.10.0.Beta10/8.8.5/token.aware-1.2) with ESMTP id h2RLNEm27288
	for <nfs@lists.sourceforge.net>; Thu, 27 Mar 2003 13:23:14 -0800 (PST)
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


Hi Folks,

I've been chasing a very poor performance problem from a SuSE Sles-8 
(2.4.19) system on an IA64 box to an AIX NFS server. Writes to the same 
AIX server on an IA32 box also running Sles-8 performed as expected. 

These are v3 mounts with a 4K rsize/wsize. Eg.

mount -t nfs -o nfsvers=3,udp,rsize=4096,wsize=4096,hard rs75:/linux_test 
/linux_test

I tracked the problem down to the default PAGE_SIZE on ia64, which is 16K, 
versus the wsize which was 4K. 

In nfs_updatepage() if the wsize is smaller than the page size the write 
is performed synchronously. It appears though that the block size is then 
reduced further, in this case to 512 bytes. From what I could work out, 
it was cp_new_stat() in linux/fs/stat.c that determined the new preferred 
block size from the remote filesystem. 

On ia32 both the page size and the wsize were 4K, and no problem was seen. 

Can someone give me rough explanation of why that logic is used? ie. Why 
the page is written synchronously if its smaller than the page size? and 
Why even when its written synchronously the wsize wasn't used, but the 
remote filesystems block size was used?

The fix/workaround was to either increase wsize to 16K, or reduce 
PAGE_SIZE to 4K, obviously increasing wsize to 16K makes more sense.

However this leads to a problem between Linux clients and servers where 
the maximum supported block size on the server is 8K and the page size on 
the IA64 client is 16K.

Is increasing the maximum blocksize for the server as simple as changing 
NFSSVC_MAXBLKSIZE (linux/include/linux/nfsd/const.h) to 16K or 32K ? Or is 
more porting work required?

Cheers, Mark. 

-- 
Mark Price
IBM Linux Change Team
(503)-578-7524






-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
