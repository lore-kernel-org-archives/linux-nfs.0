From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: BKL removal from find_exported_dentry()
Date: Thu, 11 Mar 2004 15:10:20 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040311211020.GA1296@rx8.ibm.com>
References: <20040309135451.GC30766@rx8.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B1XZP-0007ax-6Y
	for nfs@lists.sourceforge.net; Thu, 11 Mar 2004 13:18:23 -0800
Received: from e35.co.us.ibm.com ([32.97.110.133])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B1WzP-0004I7-ME
	for nfs@lists.sourceforge.net; Thu, 11 Mar 2004 12:41:11 -0800
Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e35.co.us.ibm.com (8.12.10/8.12.2) with ESMTP id i2BL7gF4232080
	for <nfs@lists.sourceforge.net>; Thu, 11 Mar 2004 16:07:42 -0500
Received: from austin.ibm.com (d03av02.boulder.ibm.com [9.17.193.82])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i2BL7fDf104982
	for <nfs@lists.sourceforge.net>; Thu, 11 Mar 2004 14:07:41 -0700
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
In-Reply-To: <20040309135451.GC30766@rx8.ibm.com> (from jrsantos@austin.ibm.com on Tue, Mar 09, 2004 at 07:54:51 -0600)
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


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=ISO-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On 03/09/04 07:54:51, Jose R. Santos wrote:
> Is there anything in particular the BKL is trying to protect here or is it 
> safe to remove?

Should I push this through Andrew Morton or should this go through you guys 
first?  Is there a particular scenario were this would be unsafe?

Looking at the code it seems there is a possibility of racing if directories
get rename or remove, but BKL doesn't seem to protect against these races, it
may slow down thing a bit to avoid them though.

I'm attaching a patch that removes BKL from find_exported_dentry().  I see a 
huge improvement on SpecSFS benchmark and haven't seen any failure up to date.

Comments?

Thanks

-JRS
--0OAP2g/MAC+5xKAE
Content-Type: text/x-patch; charset=unknown-8bit
Content-Disposition: attachment; filename="exportfs_bkl_removal.patch"

===== fs/exportfs/expfs.c 1.13 vs edited =====
--- 1.13/fs/exportfs/expfs.c	Sun Apr 20 01:22:23 2003
+++ edited/fs/exportfs/expfs.c	Thu Mar 11 13:59:35 2004
@@ -135,7 +135,6 @@
 	 * the noprogress counter.  If we go through the loop 10 times (2 is
 	 * probably enough) without getting anywhere, we just give up
 	 */
-	lock_kernel();
 	noprogress= 0;
 	while (target_dir->d_flags & DCACHE_DISCONNECTED && noprogress++ < 10) {
 		struct dentry *pd = target_dir;
@@ -232,7 +231,6 @@
 		/* something went wrong - oh-well */
 		if (!err)
 			err = -ESTALE;
-		unlock_kernel();
 		goto err_target;
 	}
 	/* if we weren't after a directory, have one more step to go */
@@ -254,7 +252,6 @@
 		}
 	}
 	dput(target_dir);
-	unlock_kernel();
 	/* now result is properly connected, it is our best bet */
 	if (acceptable(context, result))
 		return result;

--0OAP2g/MAC+5xKAE--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
