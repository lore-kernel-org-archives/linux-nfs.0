From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: FC2 NFS server + Solaris 9 4/04 strange permissions problem
Date: Tue, 05 Oct 2004 10:15:44 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1096996544.4460.769.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CEsup-00019z-IH
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 10:15:55 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CEsuk-00075z-5T
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 10:15:55 -0700
To: nfs@lists.sourceforge.net
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


On an FC2 system, I'm:

1) loopback mounting a .iso, with the following options from "mount":
	/tmp/sol-8-hw4-sparc-v1.iso on /mnt/loop type iso9660
	(ro,loop=/dev/loop0)
2) Turning off iptables
3) sharing out the loopback mount over NFS, with the following
/etc/exports entry:
	/mnt/loop autoinst.nacs.uci.edu(ro,insecure,no_root_squash)

Then on the Solaris 9 4/04 system, I:

1) Mount the loopback filesystem, with the following attributes from the
"mount| grep /mnt" command:
	remote/read only/setuid/xattr/dev=430003c
2) Run a:
	find . -depth -print  | cpio -pdmu /some/local/dir

...and when I do this, most files are copied fine, however a small
number of them give 'cpio: Error with fstatat() of
"Product/SUNWxwfnt/reloc/openwin/bin", errno 13, Permission denied'
errors.

I suspect that it isn't the same files giving this errror every time.

To make matters more perplexing, every time I do such a find | cpio, I
get errors, but when I ls these directories, I do Not Get Consistent
Behavior.  Sometimes I see:
	ls -ld ./Product/SUNW1251f/reloc/usr/bin
	./Product/SUNW1251f/reloc/usr/bin: Permission denied
...while other times I see:
	ls -ld ./Product/SUNW1251f/reloc/usr/bin
drwxr-xr-x   2 root     other       2048 Jan  8  2004
./Product/SUNW1251f/reloc/usr/bin


Has anyone else encountered this?

Has anyone come across a solution?

Should I just stop using the loopback mounts, and burn some CD-R's?  :)


Thanks!

-- 
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
