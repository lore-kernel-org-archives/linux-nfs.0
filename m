From: Thomas =?iso-8859-1?Q?Lang=E5s?= <tlan@stud.ntnu.no>
Subject: Re: Re: Unable to kill processes in D-state
Date: Sun, 6 Oct 2002 23:40:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021006214037.GA18115@stud.ntnu.no>
References: <Pine.LNX.4.44.0210062045001.15836-100000@xpc1.ast.cam.ac.uk>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from flaske.stud.ntnu.no ([129.241.56.72])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yJ8l-00006v-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Oct 2002 14:40:43 -0700
To: Jeremy Sanders <jss@ast.cam.ac.uk>
In-Reply-To: <Pine.LNX.4.44.0210062045001.15836-100000@xpc1.ast.cam.ac.uk>
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

Jeremy Sanders:
> This sounds a similar problem (well it has similar symptoms) to what we
> had with RedHat's kernel for (null) and their rawhide kernel. I think this
> turned out to be an ext3 interaction bug.

We don't use ext3 on any of our systems...

> See https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=70561
> (also try ctrl+scrolllock to get a trace of the nfsds on your system).
> This will provide useful info over where it is stuck.

It's the client systems that have problems, how would it help to get a trace
of the nfsd's?

-- 
Thomas


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
