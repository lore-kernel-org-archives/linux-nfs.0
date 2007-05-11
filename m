From: Neil Brown <neilb@suse.de>
Subject: ANNOUNCE nfs-utils 1.1.0
Date: Fri, 11 May 2007 13:53:39 +1000
Message-ID: <17987.59587.183275.371388@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HmMCp-0000bV-1b
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 20:54:11 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HmMCr-0004Zu-4p
	for nfs@lists.sourceforge.net; Thu, 10 May 2007 20:54:13 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 4630921099
	for <nfs@lists.sourceforge.net>; Fri, 11 May 2007 05:54:10 +0200 (CEST)
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


Ok, I finally bit the bullet and did it.
nfs-util-1.1.0 is final,  You can find it on sourceforge or kernel.org
or in the git repository.

The NEWS file is below for easy access.

Note that I haven't listed any of the bugs that have been added.  You
have to find them for yourself :-)

NeilBrown

Significant changes for nfs-utils 1.1.0 - March/April 2007

 - rpc.lockd is gone.  One 3 old kernel releases need it.
 - rpc.rquotad is gone.  Use the one from the 'quota' package.
   Everone else does.
 - /sbin/{u,}mount.nfs{,4} are now installed so 'mount' will
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
    multi-homed peers better.  In particular, files in
    /var/lib/nfs/sm/ are named with the Full Qualified Domain Name
    if available.
 - If you export a directory as 'crossmnt', all filesystems
   mounted beneath are automatically exported with the same
   options (unless explicitly exported with different options).
 - subtree_check is no-longer the default.  The default is now
   no_subtree_check.
 - By default the system 'rpcgen' is used while building
   nfs-utils rather than the internal one.
 - Exportfs will warn if you try to export a filesystem that does
   not support NFS export.
 - Comprehensive notes on startup dependencies have been added
   to the README file.
 - Mount and statd now listen on a non-privileged port by default.
   For maximum safety an upgrade to portmap-6.0 is recommended.
        http://neil.brown.name/portmap/
        git://neil.brown.name/portmap

 - This release should work with MIT Kerberos and Heimdal 0.8.1 and later.

 - A new option, -n, was added to rpc.gssd which specifies that
   accesses by root should not use 'machine credentials' when
   accessing NFS file systems mounted with Kerberos.  Using this
   option allows the root user to access the NFS space using any
   Kerberos principal, rather than always using the machine
   credentials.  However, its use also requires that root manually
   authenticate before attempting a mount with Kerberos.

   When rpc.gssd uses machine credentials, the selection algorithm has
   been changed.  Instead of simply using the first "nfs/*" key in the
   keytab, the keytab is now searched for keys in the following
   defined order:

     root/<fqdn>@REALM
     nfs/<fqdn>@REALM
     host/<fqdn>@REALM
     root/<any-name>@REALM
     nfs/<any-name>@REALM
     host/<any-name>@REALM


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
