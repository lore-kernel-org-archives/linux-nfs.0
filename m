From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: Re: broken umount -f
Date: Wed, 15 Jan 2003 00:19:28 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115051928.GB30478@questra.com>
References: <6440EA1A6AA1D5118C6900902745938E07D551EB@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Yfxb-0003LD-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 21:19:31 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 1955AAB7D9
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 00:19:29 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D551EB@black.eng.netapp.com>
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
