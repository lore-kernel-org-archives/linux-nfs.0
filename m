From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Locking from Tru64
Date: Wed, 5 Feb 2003 15:19:54 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.53.0302051517390.1790@xpc1.ast.cam.ac.uk>
References: <Pine.LNX.4.53.0302041525090.22528@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gold.csi.cam.ac.uk ([131.111.8.12])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18gRLf-0003Un-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Feb 2003 07:20:27 -0800
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by gold.csi.cam.ac.uk with esmtp (Exim 4.10)
	id 18gRL9-0006Jw-00
	for nfs@lists.sourceforge.net; Wed, 05 Feb 2003 15:19:55 +0000
Received: from xserv1.ast.cam.ac.uk (IDENT:E7/mY1CS+mfVO4Ag89O7xuIBqBqBt0b5@xserv1.ast.cam.ac.uk [131.111.69.235])
	by cass41.ast.cam.ac.uk (8.12.5+Sun/8.12.5) with ESMTP id h15FJsNS009385
	for <nfs@lists.sourceforge.net>; Wed, 5 Feb 2003 15:19:55 GMT
Received: from xpc1.ast.cam.ac.uk (IDENT:gnOJMs6gt1+MstacFMFYQvezVoY0xemV@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xserv1.ast.cam.ac.uk (8.11.6/8.11.6) with ESMTP id h15FJsU27199
	for <nfs@lists.sourceforge.net>; Wed, 5 Feb 2003 15:19:54 GMT
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.53.0302041525090.22528@xpc1.ast.cam.ac.uk>
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

On Tue, 4 Feb 2003, Jeremy Sanders wrote:

> I have got an additional problem which I don't understand. We're locking
> mail spools over NFS from a Tru64 5.1B client machine to Linux
> 2.4.18-17.7.x (RedHat) server. Using a simple C program which opens the
> file, does lockf (fd, F_LOCK, 1)) and then closes it after 10 seconds,
> some users are able to lock their mail spool (one seen, actually) and many
> users are unable!

As an additional point of data, if the user who can lock their mail spool
copies the file to another file _with exactly the same permissions and
ownership_, then they are unable to lock this new file!

This behaviour seems bizarre and it's the linux server which isn't
replying with a

15:04:37.125897 linux.799 > tru64.1035:  udp 136 (DF)

response, so I'd guess it's a Linux specific problem.

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
