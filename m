From: Goutham Kurra <kurrag1@yahoo.com>
Subject: force unmount not working 2.4.22
Date: Sat, 9 Oct 2004 14:22:31 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041009212231.78436.qmail@web20524.mail.yahoo.com>
References: <Pine.LNX.4.58.0410091031520.1370@donald.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CGOfi-0006V2-A3
	for nfs@lists.sourceforge.net; Sat, 09 Oct 2004 14:22:34 -0700
Received: from web20524.mail.yahoo.com ([216.136.227.41])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CGOff-0006Ao-4T
	for nfs@lists.sourceforge.net; Sat, 09 Oct 2004 14:22:34 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.58.0410091031520.1370@donald.themaw.net>
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


Force unmount simply isn't working on a standard linux
2.4.22 kernel. Isn't it supposed to unmount NFS
filesystems no matter what?

In my case, the backend server is still up and
working, I have a "tail -f /mnt/nfs/foo" of some file
on the mount, and "umount -f" fails with "device or
resource is busy"

I notice that rpc_killall_tasks() is called from the
umount_begin(), but none of the processes get an EIO.
They continue to work as before.

I've also noticed this on stock RH 2.4.20-9 kernels.

Any idea what's going on?

Thanks!
g



		
__________________________________
Do you Yahoo!?
Take Yahoo! Mail with you! Get it on your mobile phone.
http://mobile.yahoo.com/maildemo 


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
