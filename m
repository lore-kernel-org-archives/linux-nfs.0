From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: fsid syntax
Date: Thu, 8 Aug 2002 14:44:13 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208081444.13646.bernd-schubert@web.de>
References: <200208071711.00712.bernd-schubert@web.de> <200208071830.54734.bernd-schubert@web.de> <15697.33669.398331.848444@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cmeO-0006Vu-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 05:44:24 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15697.33669.398331.848444@notabene.cse.unsw.edu.au>
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

> Sorry, you cannot do that.  The filehandles created with fsid=foo are
> different from any filehandle created without fsid=.
>
> If you want to change the device on the server what you need to do is:
>
> 1/ well in advance, add an 'fsid=42'(*) export option.
>    Clients using old file handles will still work.  Clients that
>    subsequently mount will get new-style file handles.
> 2/ At your convenience, remount the filesystem on all clients, either
>    by umount/mount or reboot or whatever.
> 3/ When all, or enough, clients have remounted, you can safely change
>    the device number without affecting clients.
>
> (*)  I really don't think that basing the fsid on the device number is
> at all sensible.  Afterall, that is what we are trying to avoid.
> Just pick a number, any number.
> 1 for the first filesystem, 2 for the second.
> Your age for the filesystem storing you home directory.
> 42 for the filesystem storing the Great Question of Life, The
> Universe, and Everything.
>
> NeilBrown
>

Hello Neil,

thank you for telling me about this. 

Bernd


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
