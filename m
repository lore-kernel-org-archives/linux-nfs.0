From: "Rongqing \"Frank\" Tu" <rtu@packetgeneral.com>
Subject: Re: permission denied.
Date: Fri, 22 Nov 2002 11:11:11 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211221042001.24067-100000@filer.packetgeneral.com>
References: <15837.28061.841206.456134@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [204.52.248.2] (helo=filer.packetgeneral.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18FGQJ-0008TT-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Nov 2002 08:12:55 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15837.28061.841206.456134@notabene.cse.unsw.edu.au>
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

Dear Neil,
Thank you for your help. 
I don't think Universal NFS is suitable for my situation. 

My situation is there is a linux box sitting between NFS server and end 
users. This linux box will transfer the NFS server to the end user, so in 
this linux box, I need to mount the NFS server, then export mounted point 
to the end users.

		    NFS			NFS
	NFS_server ------> Linux_Box --------> end users

In the linux box, there are two commands:
	mount -t nfs NFS_server:/path/dir   /linux_box_path/dir
	exportfs -ra 
	(in /etc/exports: /linux_box_path/dir *(rw) )

In the normal situation, such "link" exporting and mounting is not 
necessary since the end user can directly mount the NFS server to itself, 
but I need to add some functions in my Linux_Box and this becomes 
necessary.

Are you very sure NFS protocol doesn't support such "link" exporting and 
mounting?

Thanks.

Frank

 On Fri, 22 Nov 2002, Neil Brown 
wrote:

> On Thursday November 21, rtu@packetgeneral.com wrote:
> > Hi All,
> > I am running on Linux 2.4.18-3 and try to setup a "link" nfs, but got a 
> > "permission denied".
> > 
> > a link nfs is like this:
> > in machine 1:  export A
> > in machine 2:  mount A to B and then export B
> > in mahcine 3:  mount B to C.
> > 
> > the "permission denied" occurs at the last step when I tried to mount B to 
> > C.
> > 
> > I am working on a software which needs this kind of structure, so I wonder 
> > if NFS support such "link" exporting and mounting?
> 
> re-exporting NFS filesystems is not supported and it is unlikely that
> it will be.  Partly there are protocol issues that make it an
> unsolvable problem in general (though many specific cases can probably
> be made to work).  Partly there is usually a better solution to the
> underlying problem.
> 
> One thing you could try if you were really set on this path is to use
> the user-space nfs server aka "Universal NFS daemon" aka unfsd.  This
> can export any filesystem, but has speed and some reliability issues.
> 
> NeilBrown
> 



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
