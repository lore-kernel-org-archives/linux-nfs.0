From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: KNFSD information  needed
Date: Sat, 3 May 2003 14:27:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200305031427.19693.bernd-schubert@web.de>
References: <002301c310aa$0ef33350$6e00a8c0@compaq3> <200305021626.42933.bernd-schubert@web.de> <001f01c3112a$5ef5c6d0$6e00a8c0@compaq3>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Bw7c-0006qj-00
	for <nfs@lists.sourceforge.net>; Sat, 03 May 2003 05:28:09 -0700
To: "David Shirley" <dave@cs.curtin.edu.au>, <nfs@lists.sourceforge.net>
In-Reply-To: <001f01c3112a$5ef5c6d0$6e00a8c0@compaq3>
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

On Saturday 03 May 2003 06:13, David Shirley wrote:
> Bernd,
>
> This is why I am getting confused, because I have seen papers
> comparing userspace nfsd with knfsd - performance and feature wise.

Why do you want to compare unfsd and knfsd ? Just believe me, unless you have 
very special conditions, you won't want to try unfsd. 
Furthermore those papers should be rather outdated since except the ClusterNFS 
users (we belong to them) nobody uses unfsd nowadays.

>
> Also some people are making reference to a knfsd process which
> i dont have, even though i have the appropriate options turned on
> in the kernel.

Running 'ps ax' knfsd should appear like this:

  637 ?        SW   569:03 [nfsd]

Whereas unfsd (in our case ClusterNFS) would appear as:

  522 ?        S     14:39 [rpc.nfsd.cnfs]


Or are you the 'Debian User' who doesn't manage to get knfsd running ? Without 
further information from his log-files nobody will we able to help him in any 
case.

>
> Yes i have see the howto and there is no reference to knfsd, which
> is why i am getting confused - perhaps the was once a knfsd but now it
> is merged with the other nfsd?

The hole howto is about knfsd ;)


Bernd


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
