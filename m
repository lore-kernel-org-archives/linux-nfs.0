From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: permission denied.
Date: Fri, 22 Nov 2002 10:34:53 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15837.28061.841206.456134@notabene.cse.unsw.edu.au>
References: <Pine.LNX.4.44.0211211536580.17129-100000@filer.packetgeneral.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18F0qj-0001L1-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Nov 2002 15:35:09 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <rtu@packetgeneral.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 22 Nov 2002 10:34:59 +1100
To: "Rongqing \"Frank\" Tu" <rtu@packetgeneral.com>
In-Reply-To: message from "Rongqing \"Frank\" Tu" on Thursday November 21
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

On Thursday November 21, rtu@packetgeneral.com wrote:
> Hi All,
> I am running on Linux 2.4.18-3 and try to setup a "link" nfs, but got a 
> "permission denied".
> 
> a link nfs is like this:
> in machine 1:  export A
> in machine 2:  mount A to B and then export B
> in mahcine 3:  mount B to C.
> 
> the "permission denied" occurs at the last step when I tried to mount B to 
> C.
> 
> I am working on a software which needs this kind of structure, so I wonder 
> if NFS support such "link" exporting and mounting?

re-exporting NFS filesystems is not supported and it is unlikely that
it will be.  Partly there are protocol issues that make it an
unsolvable problem in general (though many specific cases can probably
be made to work).  Partly there is usually a better solution to the
underlying problem.

One thing you could try if you were really set on this path is to use
the user-space nfs server aka "Universal NFS daemon" aka unfsd.  This
can export any filesystem, but has speed and some reliability issues.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
