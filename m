From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Re: Unable to kill processes in D-state
Date: Mon, 7 Oct 2002 09:25:54 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210070919150.16350-100000@xpc1.ast.cam.ac.uk>
References: <20021006214037.GA18115@stud.ntnu.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Thomas =?iso-8859-1?Q?Lang=E5s?= <tlan@stud.ntnu.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from plum.csi.cam.ac.uk ([131.111.8.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yTDC-0003XA-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 01:25:58 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20021006214037.GA18115@stud.ntnu.no>
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

On Sun, 6 Oct 2002, Thomas Lang=E5s wrote:

> Jeremy Sanders:
> > This sounds a similar problem (well it has similar symptoms) to what =
we
> > had with RedHat's kernel for (null) and their rawhide kernel. I think=
 this
> > turned out to be an ext3 interaction bug.
>
> We don't use ext3 on any of our systems...

Okay so it's unlikely to be what I saw.

> It's the client systems that have problems, how would it help to get a =
trace
> of the nfsd's?

Probably not. It might be useful to get a trace of the processes stuck in
the 'D' state (ctrl+scroll lock is logged to dmesg), and rpciod, lockd
(and any of the rpc.xxx processes).

Also it might be useful to get a trace using tcpdump of the communication
between the server and client (options -vv -u -s 192 to get extra NFS
information).

Jeremy

PS I'm not an NFS expert, so please don't expect me to solve the problem!

--=20
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
