From: "Rongqing \"Frank\" Tu" <rtu@packetgeneral.com>
Subject: Re: permission denied.
Date: Sat, 23 Nov 2002 22:03:04 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211232200190.9544-100000@filer.packetgeneral.com>
References: <200211231922.19392.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [204.52.248.2] (helo=filer.packetgeneral.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Fn4n-0000XU-00
	for <nfs@lists.sourceforge.net>; Sat, 23 Nov 2002 19:04:53 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200211231922.19392.bernd-schubert@web.de>
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

Thanks.
I found the place to resolve the problem.
in the kernel code of nfsd, exp_export() in export.c, ignore the check of 
fs flag of FS_REQUIRES_DEV.
inode->i_sb->s_type->fs_flags.

Frank
On Sat, 23 Nov 2002, Bernd Schubert wrote:

> On Friday 22 November 2002 17:11, Rongqing \"Frank\" Tu wrote:
> > Dear Neil,
> > Thank you for your help.
> > I don't think Universal NFS is suitable for my situation.
> >
> 
> Hi Frank,
> 
> Using any other user-space export daemon should also do what you want. So you 
> could try to use samba for example.
> 
> Bernd
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
