From: Andreas Behnert <abehn@gmx.net>
Subject: Re: nfs over TCP stable?
Date: Mon, 05 May 2003 12:49:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EB641B0.50903@gmx.net>
References: <3EB44527.6090005@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pop.gmx.de ([213.165.65.60] helo=mail.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19CdXO-0003CX-00
	for <nfs@lists.sourceforge.net>; Mon, 05 May 2003 03:49:38 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <3EB44527.6090005@wanadoo.es>
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

Xose Vazquez Perez wrote:
> hi,
> 
> Red Hat 9-kernel 2.4.20-9 doesn't include nfs over TCP because they
> said that "it doesn't work good enough in our testing....."
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=88583
> 
> Are there any problems at standard kernels or only at
> mega-patched rh kernels?
> 
> -thanks in advance-
> 
> regards,

(Sorry 'bout my poor English)

Linux NFS server, UNIX clients:
I used 2.2.20 for NFSv3 over UDP for a long time and did some tests
with 2.4.21-rc7 for NFSv3 over TCP. Unfortunately there were a lot of
problems. "Normal" stress tests (mounting, creating some very large
and many small files, copying, ...) showed no problems but CATIA is
running on the clients and CATIA, at least 4.2.2/4.2.4, seems to use
some special fs access methods (sorry, can't be more specific becuse
I simply don't know :) and heavily relies on statd/lockd. With CATIA
running IRIX worked almost without a problem, AIX5L didn't work at all,
HP-UX11 was (and still is) _extremely_ slow, saving/loading a 90 MB
model file takes forever. AIX client behaviour could be fixed with a
"proto=udp" mount option, HP-UX11 couldn't be fixed until now because
it seems to ignore the "proto=udp" mount option I put into /etc/fstab
and the manpages seem to differ from the real behaviour. So apart from
the NFSv3 over TCP problems there seems to be a bug in HP-UX11, at
least in the release that's running here. Log files didn't say anything
relevant, not on the server and also not on the clients. To be honest -
at the moment I don't know what to do to get NFS over TCP to work
reliably and performant with all these client systems.
Next step will be a recompiled kernel 2.4.21-rc7 on the server with
deactivated TCP support for knfsd and I hope that then everything will
work as expected again because it did before with kernel 2.2.20 and UDP
only.

Server is Debian 3.0r1+security, replaced distribution nfs-utils package
with a Debian package built from current 1.0.3 nfs-utils, network 
100MBit, switched.

Regards,
Andreas



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
