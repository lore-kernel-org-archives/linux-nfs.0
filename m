From: Chip Salzenberg <chip@pobox.com>
Subject: Re: NFS lock and timeout problems
Date: Sat, 21 Sep 2002 22:05:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020922020525.GC30397@perlsupport.com>
References: <20020913144548.455bc477.ciccio@kiosknet.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17tDaL-0002Xs-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Sep 2002 13:44:09 -0700
To: Christoph Simon <ciccio@kiosknet.com.br>
In-Reply-To: <20020913144548.455bc477.ciccio@kiosknet.com.br>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

According to Christoph Simon:
> The server is a debian sid machine with an unpatched 2.4.19 kernel und
> the official debian packages for the kernel server. The client is a
> debian 3.0 (stable) machine with the same kernel, but having only NFS
> client compiled into it, not the kernel nfs server.

Caveat: I don't really know what's going wrong.

However, I think this may be part of the problem:

> /etc/hosts.allow on the client has:
> 	portmap: 192.168.254.15
> 	lockd:   192.168.254.15
> 	rquotad: 192.168.254.15
> 	mountd:  192.168.254.15
> 	statd:   192.168.254.15

The client needs to be able to communicate with itself.  You should
probably have "ALL: 127.0.0.1" in there as well.

Also, in a possibly unrelated matter, I suggest that the client mount
a ramdisk on /var before statd runs from /etc/init.d/nfs-common starts
statd.  Make sure that /var/lib/nfs exists before you start.  This is
probably a good idea anyway given that you surely don't want lots of
clients sharing /var.

> 	nsm_mon_unmon: rpc failed, status=-13
> 	lockd: cannot monitor 192.168.254.15
> 	lockd: failed to monitor 192.168.254.15
> 
> I tried to trace the command from the rcS.d scripts which would cause
> them, and, if there is no delay, the first comes in checkroot.sh, when
> "mount -f -o remount /" is given. I've read that status=-13 tells that
> statd is missing, but at this time it's running on the server and on
> the client [...]

How is it running on the client?  IIRC, checkroot.sh runs long before
'/etc/init.d/nfs-common start'.

> I also found it strange, that "cat /proc/mount" on the client will
> always give:
> 
> 	192.168.254.15:/nfsvol / \
> 	  nfs rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=192.168.254.15
> 
> where v3, rsize, wsize, udp and lock are options I never gave.

Those are the defaults for the given options.

> read that the defaults for rsize,wsize is 1024,

That was long ago.  Nowadays, 8K is the default.
-- 
Chip Salzenberg         - a.k.a.  -        <chip@pobox.com>
         "It furthers one to have somewhere to go."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
