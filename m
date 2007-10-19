From: Neil Brown <neilb@suse.de>
Subject: ANNOUNCE nfs-utils-1.1.1
Date: Fri, 19 Oct 2007 13:57:19 +1000
Message-ID: <18200.11039.903222.121815@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Steve Dickson <SteveD@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiizG-0005f4-2y
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 20:57:26 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IiizJ-0000uS-Uo
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 20:57:31 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


(not sure what went wrong the first time - let's try again)

About 5 months since 1.1.0, nfs-utils-1.1.1 has just been released.

It can be found on sourceforge   http://download.sourceforge.net/nfs
or kernel.org                    http://www.kernel.org/pub/linux/utils/nfs/nfs-utils-1.1.1.tar.gz

It includes:

   Lots of fixes and improvements to mount.nfs and umount.nfs
    - The new "text based mount options" kernel interface is now
       supported, but is not yet the default
    - new mount option 'nosharecache'
    - shorter timeouts for TCP connections (not 75 seconds!)
   More efficient support for site with a large number of netgroups.
   "nfsstate --since" for easily reporting incremental statistics.
   Lots of compile warnings silenced.
   Clean up of the logging code.
   Fixed memory leaks in mountd.

I will be handing over maintenance of the nfs-utils package to 
    Steve Dickson <SteveD@redhat.com>

so please ensure that any patches you want included get sent to him.
(Thanks Steve!!)

We suspect that in the next release the use of text based mount
options will be the default (on kernels that support it).  In the mean
time, please consider testing this functionality by using "-i".
e.g
    /sbin/mount.nfs host:/path /my/directory -i -o options

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
