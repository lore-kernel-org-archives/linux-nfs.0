From: Keith Owens <kaos@sgi.com>
Subject: Re: NFS server stalls with 2.4.18 + XFS 1.1
Date: Fri, 05 Jul 2002 08:39:50 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ag2j0e$8o4$2@main.gmane.org>
References: <3D2474C6.461E618@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-xfs@oss.sgi.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.ocs.com.au ([203.34.97.2])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17QFGd-0001FB-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jul 2002 15:40:04 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: Your message of "Thu, 04 Jul 2002 17:16:06 +0100."
             <3D2474C6.461E618@moving-picture.com>
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

On Thu, 04 Jul 2002 17:16:06 +0100, 
James Pearson <james-p@moving-picture.com> wrote:
>We have noticed a problem with a couple of our NFS servers (running
>RedHat 7.2 with a stock 2.4.18 kernel with XFS v1.1) whereby NFS access
>slows to a crawl or stalls.
>
>The exported filesystem(s) are XFS with 8 nfsd's running - when we have
>the problem the load average is about 8 - but CPU usage, disk access and
>network traffic are minimal.
>
>I found, by accident, that running the command 'sync' appears to 'fix'
>the situation...
>
>I'm not sure if this is an XFS or NFS related problem (hence posting to
>both lists).

XFS.  2.4.18 would sometimes get into a situation where two XFS
operations were waiting on locks (not deadlocked) and nothing was
moving.  Performing some other disk activity such as sync would get
things moving again.

AFAICT this is fixed in the XFS CVS tree, against 2.4.19-rc1.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
