From: "Alexander Povolotsky" <pevnev@juno.com>
Subject: Re: I have two Linux ( 2.6.8 ?)   NFS client/server problems
Date: Tue, 12 Oct 2004 14:46:52 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041012.074747.2350.22057@webmail19.lax.untd.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net,
	 'busybox@mail.busybox.net'
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHNzC-0002c4-DB
	for nfs@lists.sourceforge.net; Tue, 12 Oct 2004 07:50:46 -0700
Received: from outbound-mail.lax.untd.com ([64.136.28.164])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CHNxv-000390-QM
	for nfs@lists.sourceforge.net; Tue, 12 Oct 2004 07:50:46 -0700
Received: from outbound29-sr.lax.untd.com (webmail19.lax.untd.com [10.130.30.159])
	by smtpout04.lax.untd.com with SMTP id AABAYZ5XVAL43VBS
	for <nfs@lists.sourceforge.net> (sender <pevnev@juno.com>);
	Tue, 12 Oct 2004 07:48:19 -0700 (PDT)
To: trond.myklebust@fys.uio.no
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


Hi Trond !

Trond Myklebust wrote:

>Actually that should be: pivot_root . tmp
>(and you have to make sure that /fadsroot/tmp does indeed exist).

pivot_root . tmp  worked ! (no errors).

# ps
  PID  Uid     Stat Command
    1 root     S    init
    2 root     R    [ksoftirqd/0]
    3 root     S    [events/0]
    4 root     S    [khelper]
    5 root     S    [kblockd/0]
    6 root     S    [pdflush]
    7 root     S    [pdflush]
    8 root     S    [kswapd0]
    9 root     S    [aio/0]
   15 root     S    /usr/sbin/xinetd -stayalive -reuse -pidfile /tmp/xinetd.pid
  138 root     S    [rpciod]
  253 root     S    -sh
  254 root     S    /bin/sh /bin/application
  256 root     S    sleep 300
  258 root     R    ps

# mkdir /fadsroot 
# mount -o mountvers=2 -onolock 192.168.0.4:/fadsroot /fadsroot
nfs warning: mount version older than kernel
# cd fadsroot
# ls -l
-rw-r--r--    1 0        0               0 Jan  1  1970 XXX
drwxr-xr-x    3 0        0            4096 Oct  7  2004 apache2
drwxr-xr-x    3 0        0            4096 Oct  7  2004 apt
drwxrwxr-x    2 0        500          4096 Oct  7  2004 bin
drwxr-xr-x    2 0        0            4096 Sep 28  2004 boot
drwxr-xr-x    3 0        0            4096 Aug 16  2004 cardmgr
drwxr-xr-x    2 0        0            4096 Sep 28  2004 cdrom
drwxr-xr-x    3 0        0            4096 Oct  7  2004 cgi-bin
drwxrwxr-x    8 0        500          4096 Sep 29  2004 ctcs-1.3.0
drwxr-xr-x    2 0        0            4096 Oct 12  2004 dev
drwxr-xr-x    2 0        0            4096 Oct  7  2004 dpkg
drwxr-xr-x   41 0        0            4096 Sep 29  2004 etc
-rwxr-xr-x    1 500      500           315 Oct  9  2004 fadsroot.sh
drwxr-xr-x    2 0        0            4096 Sep 28  2004 floppy
drwxrwxr-x    2 0        500          4096 Oct  4  2004 gcc-3.4.1
drwxr-xr-x    2 0        0            4096 Oct  7  2004 gconv
-rwxr-xr-x    1 0        0          493696 Apr 19  2004 gdbserver
-rwxr-xr-x    1 0        0           16711 Jul  2  2004 hello
-rwxr--r--    1 0        0             281 Jul  2  2004 hello.c
drwxr-xr-x    5 0        0            4096 Apr 19  2004 home
drwxr-xr-x    4 0        0            4096 Sep 29  2004 initrd
-rw-r--r--    1 500      500       3461120 Sep 29  2004 initrd.tar
drwxr-xr-x    5 0        0            4096 Oct  9  2004 lib
drwxrwxr-x    9 0        500          4096 Sep 27  2004 lmbench-3.0-a4
drwxr-xr-x    2 0        0            4096 Oct  7  2004 locate
drwxrwxr-x    3 0        500          4096 Oct  9  2004 macbench
-rwxr--r--    1 0        0           22749 Jun 29  2004 main.elf
drwxr-xr-x    2 0        0            4096 Oct  4  2004 mkdir
drwxr-xr-x    4 0        0            4096 Sep 28  2004 mnt
drwxr-xr-x   15 8037     50           4096 Jul  5  2004 ncurses-5.4
drwxr-xr-x    2 0        0            4096 Sep 28  2004 opt
drwxr-xr-x    3 0        0            4096 Aug 16  2004 pciutils-2.1.10
drwxrwxr-x    3 0        500          4096 Oct  4  2004 perl
drwxr-xr-x    2 0        0            4096 Apr 19  2004 proc
crw-r--r--    1 0        0          2,   0 Apr 19  2004 ptyp0
drwxr-xr-x    3 0        0            4096 Oct  7  2004 python2.3
drwxr-xr-x    2 0        0            4096 Sep 28  2004 root
drwxr-xr-x    6 0        0            4096 Jul 16  2004 runin
drwxr-xr-x    2 0        0            4096 Oct  7  2004 sasl2
drwxr-xr-x    2 0        0            4096 Sep 28  2004 sbin
drwxr-xr-x    3 0        0            4096 Oct  7  2004 ssl
drwxr-xr-x    2 0        0            4096 Sep 28  2004 sys
drwxr-xr-t    2 0        0            4096 Sep 28  2004 tmp
crw-r--r--    1 0        0          3,   0 Apr 19  2004 ttyp0
drwxr-xr-x   11 0        0            4096 Sep 28  2004 usr
drwxr-xr-x   14 0        0            4096 Sep 28  2004 var
# ls -l | grep tmp
drwxr-xr-t    2 0        0            4096 Sep 28  2004 tmp
# chmod 775 tmp
# pivot_root . tmp
# ls
# pwd

However after that I have the next problem - I am not getting any output from commands (ls, pwd, etc. ) ...
and after a while I am starting to get scrolling error:

root@192:/# Bummer, could not run '/bin/application': No such file or directory 

I guess I need to copy /bin/application to /fadsroot/bin/application

before pivot_root ?

Thanks,
Alex

*************
På ty , 12/10/2004 klokka 02:05, skreiv Alexander Povolotsky:
> Trond Myklebust wrote:
> 
> > Have you tried the form recommended by the manpage?
> 
> >  pivot_root . /tmp
> 
> yes - same failure 

Sorry. Actually that should be

pivot_root . tmp

'cos neither of the 2 directories may lie on the old root (and you have
to make sure that /fadsroot/tmp does indeed exist).

Cheers,
  Trond



________________________________________________________________
Speed up your surfing with Juno SpeedBand.
Now includes pop-up blocker!
Only $14.95/ month - visit http://www.juno.com/surf to sign up today!


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
