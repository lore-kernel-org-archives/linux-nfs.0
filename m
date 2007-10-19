From: Neil Brown <neilb@suse.de>
Subject: (no subject)
Date: Fri, 19 Oct 2007 13:44:14 +1000
Message-ID: <18200.10254.606486.511995@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iiimb-0004UO-5G
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 20:44:25 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Iiimf-0005yu-81
	for nfs@lists.sourceforge.net; Thu, 18 Oct 2007 20:44:26 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id B4F1522E4F
	for <nfs@lists.sourceforge.net>; Fri, 19 Oct 2007 05:44:19 +0200 (CEST)
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

Subject: ANNOUNCE nfs-utils-1.1.1
X-Mailer: VM 7.19 under Emacs 21.4.1
FCC: ~/.mail/nfs-utils
X-face:	[Gw_3E*Gng}4rRrKRYotwlE?.2|**#s9D<ml'fY1Vw+@XfR[fRCsUoP?K6bt3YD\ui5Fh?f
	LONpR';(ql)VM_TQ/<l_^D3~B:z$\YC7gUCuC=sYm/80G=$tt"98mr8(l))QzVKCk$6~gldn~*FK9x
	8`;pM{3S8679sP+MbP,72<3_PIH-$I&iaiIb|hV1d%cYg))BmI)AZ
--text follows this line--

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
