From: Simon Nieuviarts <Simon.Nieuviarts@bull.net>
Subject: IO error caused by a race in page cache
Date: Thu, 4 Dec 2003 15:17:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200312041457.13791.Simon.Nieuviarts@bull.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

Hi,

We are running bonnie++ on IA64 SMP machines with the 2.6.0-test9 kernel, over 
a gigabit ethernet network. In some test configurations (nfs v3 over udp, 
with various request sizes) an IO error is sometimes received by the client 
process while the rewrite test, but there is no hardware error displayed on 
the machines. This test reads chunks of a file and modifies them.

I tracked the bug (by putting traces in the kernel) and found something that 
looks like a race in the VFS.
The IO error we encounter is generated in do_generic_mapping_read(), mm/
filemap.c:687 :
                if (!error) {
                        if (PageUptodate(page))
                                goto page_ok;
                        wait_on_page_locked(page);
                        if (PageUptodate(page))
                                goto page_ok;
                        error = -EIO;
                }

According to the traces I added, the function nfs_readpage_result() for this 
page called SetPageUptodate(), but at the same time, another request reply 
called __nfs_refresh_inode() which called invalidate_complete_page() on the 
same page, so the uptodate flag has been cleared before the check after 
wait_on_page_locked().

My quick dirty hack to fix this race is to add these lines just before the 
affectation of the EIO error :

if (!PageError(page)) {
	printk(KERN_WARNING "SN: False IO error avoided on invalidated page.\n");
	goto page_ok;
}

Now, my tests go to completion, and the warning is displayed 6 or 7 times.
I know it is no more time to make changes to the VFS, and I am not sure it is 
the right fix...
What do you think about this bug ?
Cheers,

Simon.

-- 
Simon Nieuviarts, BULL S.A.
Linux R&D, Office B1/367
1, rue de Provence. BP208
38432 Echirolles Cedex, France
Phone : + 33 (0)4 76 29 70 26



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
