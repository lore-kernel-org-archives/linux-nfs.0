From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: fsid syntax
Date: Wed, 7 Aug 2002 18:30:54 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208071830.54734.bernd-schubert@web.de>
References: <200208071711.00712.bernd-schubert@web.de> <shsk7n2d70y.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cTi9-0000CU-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 09:31:01 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsk7n2d70y.fsf@charged.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wednesday 07 August 2002 17:26, Trond Myklebust wrote:
> >>>>> " " == Bernd Schubert <bernd-schubert@web.de> writes:
>      > Hi, probably on Friday I need to make use of setting the fsid
>      > in the /etc/exports.
>      >
>      > Since I can't find the syntax in the exports manpage (manpage
>      > was last time changed on Januar, while the fsid-feature seems
>      > to be become added to cvs on February).
>      >
>      > So I'd like to know the exact sytanx, is for example:
>      >
>      > /testdir testnode(fsid=/dev/sdb)
>
> The fsid is a number, not a device. In principle you can set it to any
> number you like as long as you keep it consistent over reboots.
>
> One suggestion is to use the device major/minor number in the format
> minor + (major * 256). (That's what nfsd uses by default for block
> devices.)
>
> Cheers,
>   Trond
>
>

Uh, good that I asked for this, so I was completely wrong.

Is there a way to get the current fsid (after a reboot on Friday the fsid will 
change and I don't want to reboot our clients) ? Or is it simply the fsid of 
e.g.  /dev/sdb, so that I can get it with statfs() ?

Thanks for your help,

Bernd


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
