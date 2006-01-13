From: Andi Kleen <ak@suse.de>
Subject: Re: LTP NFS data corruption in 2.6.15-git9 II
Date: Fri, 13 Jan 2006 21:38:43 +0100
Message-ID: <200601132138.43460.ak@suse.de>
References: <200601132137.10615.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: neilb@suse.de, trond.myklebust@fys.uio.no,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExVhF-0003Sd-KA
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 12:38:53 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ExVhF-0005D0-Bo
	for nfs@lists.sourceforge.net; Fri, 13 Jan 2006 12:38:53 -0800
To: okir@suse.de
In-Reply-To: <200601132137.10615.ak@suse.de>
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

On Friday 13 January 2006 21:37, Andi Kleen wrote:
> 
> FWIW - i was just running LTP- for 2.6.15-git9 on a x86-64 nfs root machine
> talking to 2.6.15 machine with NFSv3/UDP. During the IO tests I got 
> this. Export was with rw,async. 
> 
> The network was 100 GBit/s so I wouldn't assume it was caused by 
> fragment reordering [Why UDP? That is what the kernel nfs root 
> mounter selected]
> 
> To reproduce just run LTP 20051103 runltp over NFS.

As a followup the test machine got a lot of 


do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!
do_vfs_lock: VFS is out of sync with lock manager!

messages after the test.

-Andi


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
