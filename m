From: "Murata, Dennis W (SAIC)" <muratadw@bp.com>
Subject: RE: Re: broken umount -f
Date: Wed, 15 Jan 2003 09:35:52 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <134FC8D9C1F126488E3D123A9B2607370B4A02@bp1houex002.bp1.ad.bp.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from amnapsmtp01.bp.com ([208.251.247.82])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Ypac-0001cU-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 07:36:26 -0800
Received: from amhouav002.bp.com (inetgate11.bp.com [63.118.26.162])
	by amnapsmtp01.bp.com (Switch-3.0.0/Switch-3.0.0) with SMTP id h0FFcrgh013668
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 09:38:54 -0600 (CST)
To: "'Scott Mcdermott'" <smcdermott@questra.com>, nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

If you cd out of /mnt/tmp can you then umount -f?  This looks similar to
what happens on Solaris 8 if the directory happens to be the home directory
of a user logged into a system.  The login session has to be killed before
the umount -f works.  I would not think in your case that the user would
have to be forced off.

Wayne

-----Original Message-----
From: Scott Mcdermott [mailto:smcdermott@questra.com]
Sent: Tuesday, January 14, 2003 11:19 PM
To: nfs@lists.sourceforge.net
Subject: Re: [NFS] Re: broken umount -f


Lever, Charles on Tue 14/01 11:36 -0800:
> > Last I checked, the programs wouldn't die even with -KILL when they
> > were stuck in device-wait state.  The only way to reboot a machine
> > with such processes is to reboot -f, which is wrong.  The
> > filesystems should be able to have forced umount at sysadmin's
> > discretion.
> 
> do you remember which kernel this was?
> 
> trond fixed a long-standing "processes stuck in 'D' state" bug in
> 2.4.20.  this bug may be the reason these processes didn't die when
> you killed them.

<on client>

# uname -r
2.4.21-pre3-NFS_ALL

# showmount --exports nfsserver
Export list for nfsserver
/tmp           10.0.0.5

# mount nfsserver:/tmp /mnt/tmp

# cd /mnt/tmp

# ssh nfsserver /etc/init.d/nfs stop
Shutting down NFS mountd: [  OK  ]
Shutting down NFS daemon: [  OK  ]
Shutting down NFS services:  [  OK  ]
Shutting down NFS quotas: [  OK  ]

# /bin/pwd
nfs: server nfsserver not responding, still trying

<hangs>

<now on other tty with pwd=/>

# ps -eo state,wchan,pid,command | grep ^D
D end     1472 /bin/pwd

# kill -KILL 1472

# umount -f /mnt/tmp
Cannot MOUNTPROG RPC: RPC: Program not registered
umount2: Device or resource busy
umount: /mnt/tmp: device is busy

# kill -KILL 1472
# kill -KILL 1472

# umount -f /mnt/tmp
Cannot MOUNTPROG RPC: RPC: Program not registered
umount2: Device or resource busy
umount: /mnt/tmp: device is busy

# kill -KILL 1472
# kill -KILL 1472
# kill -KILL 1472
# kill -KILL 1472
# kill -KILL 1472
# kill -KILL 1472
# kill -KILL 1472

# umount -f /mnt/tmp
Cannot MOUNTPROG RPC: RPC: Program not registered
umount2: Device or resource busy
umount: /mnt/tmp: device is busy

# kill -KILL 1472

# ps -eo state,wchan,pid,command | grep ^D
D end     1472 /bin/pwd


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
