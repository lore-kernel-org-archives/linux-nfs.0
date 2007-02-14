From: shic <shic@np.css.fujitsu.com>
Subject: A problem with the load_elf_interp() in fs/binfmt_elf
Date: Wed, 14 Feb 2007 17:14:09 +0900
Message-ID: <45D2C4D1.4030809@np.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HHFHX-00064P-Nj
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 00:14:29 -0800
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HHFHT-0007eI-Jw
	for nfs@lists.sourceforge.net; Wed, 14 Feb 2007 00:14:26 -0800
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id
	l1E8EEWv027991
	for <nfs@lists.sourceforge.net> (envelope-from shic@np.css.fujitsu.com);
	Wed, 14 Feb 2007 17:14:14 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 904882AC026
	for <nfs@lists.sourceforge.net>; Wed, 14 Feb 2007 17:14:14 +0900 (JST)
Received: from s11.gw.fujitsu.co.jp (s11.gw.fujitsu.co.jp [10.0.50.81])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 67E4712C0CD
	for <nfs@lists.sourceforge.net>; Wed, 14 Feb 2007 17:14:14 +0900 (JST)
Received: from s11.gw.fujitsu.co.jp (s11 [127.0.0.1])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D639161C00D
	for <nfs@lists.sourceforge.net>; Wed, 14 Feb 2007 17:14:14 +0900 (JST)
Received: from ml0b.s.css.fujitsu.com (ml0b.s.css.fujitsu.com [10.23.4.188])
	by s11.gw.fujitsu.co.jp (Postfix) with ESMTP id 638BF161C009
	for <nfs@lists.sourceforge.net>; Wed, 14 Feb 2007 17:14:13 +0900 (JST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi ,All

When I did some NFS mount operations, I found a problem with the load_elf_interp() in the fs/binfmt_elf. 

I mounted a number of NFS, after lots of continuous mount operations, the fatal error "Segmentation fault" happened with the mount.nfs4, as the count of the mount operations reached about 1000~3000.

Using the strace, I found the mount.nfs4 fails just at the execve().The strace log is as follows.
execve("/sbin/mount.nfs4", ["mount.nfs4", "192.168.236.8:/", "/mnt/nfspt/num_mount_014847/nfs-"...], [/* 24 vars */]) = -1 EINVAL (Invalid argument)
--- SIGSEGV (Segmentation fault) @ 0 (0) ---
+++ killed by SIGSEGV +++

I have investigate it, and found the problem exists in the load_elf_interp() when the "Segmentation fault" happened.

When the mount.nfs4 is executed, the execve() in the kernel is invoked as follows.  
 sys_execve
  | - 
  do_execve
       |
       | - search_binary_handler   
            |-  linux_binfmt= elf_format
            |-  
            |- elf_format-> load_elf_binary
                 | -  elf_entry = load_elf_interp()
                     |-    
                     |  if  (BAD_ADDR(elf_entry)) 
                     |  force_sig(SIGSEGV, 
                     |     retval =-EINVAL;

In the do_execve(), after setting up some data structure, the do_execve() will invoke the search_binary_handler() to get the corresponding ELF binary loader for the mount.nfs4, and read the ELF executable image into memory.
In my test, when the "segment fault" of mount.nfs4 happened, in the procedure of load_elf_binary(),the address elf_entry of the interp segment read from the load_elf_interp() was judged a BAD_ADDR and afterwards the kernel send a forcible signal "SIGSEGV" to the process of mount.nfs4, and exit with the retval "EINVAL".
After I debug the kernel, I have found the cause is the address map_addr in the load_elf_interp(). 
When the problem happens, the map_addr returned from the elf_map() is judged a valid address by BAD_ADDR() in load_elf_interp() , but unluckily the address elf_entry returned by  "map_addr - ELF_PAGESTART(eppnt->p_vaddr)" is judged an invalid address by BAD_ADDR(), then the problem happens in the load_elf_binary().

By now, I've still not got a good method to resolve this problem in the load_elf_interp().
Any good ideas?

Thanks.

Best Regards.
Shi Chao










-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
