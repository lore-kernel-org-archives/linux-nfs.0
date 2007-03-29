From: Neil Brown <neilb@suse.de>
Subject: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 14:12:45 +1000
Message-ID: <17931.15549.578071.112573@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWm0L-0003gB-L6
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 21:12:53 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HWm0M-0008CF-0P
	for nfs@lists.sourceforge.net; Wed, 28 Mar 2007 21:12:55 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id AA1AA122E1
	for <nfs@lists.sourceforge.net>; Thu, 29 Mar 2007 06:12:49 +0200 (CEST)
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


I've finished fiddling with statd, and am happy with mount.nfs now, so
it must be time for the first release candidate for nfs-utils-1.1.0.

You can find it at:

   http://www.kernel.org/pub/linux/utils/nfs/
   https://sourceforge.net/project/showfiles.php?group_id=14&package_id=174&release_id=497197

   git://linux-nfs.org/nfs-utils/

Any testing and reports would be most appreciated.
The "NEWS" file currently contains the following.

Thnaks,
NeilBrown



Significant changes for nfs-utils 1.1.0 - March/April 2007

 - rpc.lockd is gone.  One 3 old kernel releases need it.
 - /sbin/{u,}mount.nfs{,4} is now installed so 'mount' will
   use these to mount nfs filesystems instead of internal code.
  + mount.nfs will check for 'statd' to be running when mounting
    a filesystem which requires it.  If it is not running it will
    run "/usr/sbin/start-statd" to try to start it.
    If statd is not running and cannot be started, mount.nfs will
    refuse to mount the filesystem and will suggest the 'nolock'
    option.
 - Substantial changes to statd
  + The 'notify' process that must happen at boot has been split
    into a separate program "sm-notify".  It ensures that it
    only runs once even if you restart statd.  This is correct
    behaviour.
  + statd stores state in the files in /var/lib/nfs/sm/ so that
    if you kill and restart it, it will restore that state and
    continue working correctly.
  + statd makes more use of DNS lookup and should handle
    multi-homed peers better.
 - If you export a directory as 'crossmnt', all filesystems
   mounted beneath are automatically exported with the same
   options (unless explicitly exported with different options).
 - subtree_check is no-longer the default.  The default is now
   no_subtree_check.
 - By default the system 'rpcgen' is used while building
   nfs-utils rather than the internal one.


Further notes on statd:

 statd should be installed in /usr/sbin, not /sbin.
 If you need to mount /usr via nfs, use 'nolock'

 At boot time, run "/usr/sbin/sm-notify".
 Run "statd" only when starting the NFS server.
 "statd" should be run before starting the NFS server.
 You do not need to start statd at boot time incase an
 NFS filesystem is mounted.  mount.nfs will take care of that.

 Make sure /usr/sbin/start-statd will run statd with required
 arguments.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
