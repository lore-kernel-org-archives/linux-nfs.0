From: Tobias Burnus <tobias.burnus@physik.fu-berlin.de>
Subject: Re: Heavy problems with NFS (2.4.20)
Date: Fri, 21 Feb 2003 13:06:25 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0302211302001.5569-100000@g31.physik.fu-berlin.de>
References: <shs65rezip1.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from down.physik.fu-berlin.de ([160.45.34.6])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18mBxC-0008WA-00
	for <nfs@lists.sourceforge.net>; Fri, 21 Feb 2003 04:06:59 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <shs65rezip1.fsf@charged.uio.no>
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

Hi,

On 20 Feb 2003, Trond Myklebust wrote:
> >>>>> " " == Tobias Burnus <tobias.burnus@physik.fu-berlin.de> writes:
>      > Any ideas how we can reduce the inpact?
> You might perhaps consider using an automounter. Either amd or autofs
> should do the job.

We actually us autofs (v4), but I suspect that some of the problems might
even come from it (high kernel load), given the problems we have with it
so far. (Such that `autofs reload' may start more than one userspace
daemon per one mountpoint, which races causes similar problems (and huge
logs).)

Seems as if we have to live with it :-(

Tobias



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
