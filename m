From: Rex Dieter <rdieter@math.unl.edu>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Wed, 7 Aug 2002 10:37:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208071037.39377.rdieter@math.unl.edu>
References: <3D513E56.CAF735B6@lmco.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: jeffrey.b.layton@lmco.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17cSsX-0007D1-00
	for <nfs@lists.sourceforge.net>; Wed, 07 Aug 2002 08:37:42 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <3D513E56.CAF735B6@lmco.com>
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

On Wednesday 07 August 2002 10:35 am, Jeff Layton wrote:

>    I remember reading on the list about the terrible NFS
> performance of the latest RH kernels. Would someone
> care to summarize this for me (UDP or TCP, etc.)? Also,
> does anyone have any rough estimates of the performance
> hit?

The Hit is big and bad.  When using the default NFS export options (in=20
particular sync), I see NFS write performance of ~50k with the 2.4.18-5=20
kernels.  When set async, performance comes back up to par.  I can give y=
ou=20
the bugzilla # I reported it under, if you like.

-- Rex


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
