From: "Steven N. Hirsch" <shirsch@adelphia.net>
Subject: Re: Exporting samba mounts through NFS.
Date: Tue, 23 Jul 2002 18:14:42 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207231811370.2837-100000@atx.fast.net>
References: <42997589360DBA4D931A5DE531290D06246597@nobelium.simstar.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtprelay8.dc2.adelphia.net ([64.8.50.40])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X7vl-0003ee-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 15:14:57 -0700
To: Charlie Brownell <cbrownell@simstar.com>
In-Reply-To: <42997589360DBA4D931A5DE531290D06246597@nobelium.simstar.com>
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

On Tue, 23 Jul 2002, Charlie Brownell wrote:

> Hey guys,
> 
>    I'm going nuts with this. I'm trying to give a Solaris box access to
> some windows files, but NFS on the Linux box in the middle isn't
> cooperating. The smbmount is fine, but I cannot share the smbmount
> directly through NFS, nor will anything show up in the mounted directory
> when I share it's parent. I've also tried NFS sharing and NFS mount and
> got the same results.

The knfsd server cannot reexport mounts from other networked filesystems.  
You'd need to use the old unfsd (user-space server), in which case there 
are plenty of other problems (see the list archives for previous 
discussions.)

Note, however, that you can cheerfully reexport an NFS mount with SMB, 
since the latter runs in user-space.

Steve




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
