From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: (no subject)
Date: Wed, 23 Apr 2003 14:11:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030423191104.GC101439@dhcp-uaus08-128-191.Central.Sun.COM>
References: <20030423183859.28233.qmail@web41304.mail.yahoo.com>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, charles.lever@netapp.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from patan.sun.com ([192.18.98.43])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198Pcr-0005Jy-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 12:09:49 -0700
To: greg@bakers.org
In-Reply-To: <20030423183859.28233.qmail@web41304.mail.yahoo.com>
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


Sorry to step in on the middle of this but I wanted to
comment on a couple of things:

After reading your analysis and results, I would assume
that there is a bug in the Linux NFS/TCP client code.


On Wed, gb wrote:

> ANALYSIS and CONCLUSION
> 
> Linux tcp-nfs is not ready for production in our large
> scale distributed environment with the current set of
> NetApp filers.
> 
> While the root of the problem may be with the tcp-nfs
> implementation on Linux, it is interesting to note
> until a certain load level is generated
> via tcp-nfs accessing a directory on a filer, no
> problems manifest themselves.

I would take this to mean that the Linux NFS/TCP bug
is related to particular traffic patterns either at
a specific client or the client combined with the
server's responsiveness under a particular load point.

> The latest kernel available (2.4.21pre7 + patches via
> Chuck Lever of NetApp) do not appear to fix the
> problem.
> 
> Until this critical problem is resolved, it is a moot
> point to argue the advantages of tcp-nfs vs. udp-nfs
> regarding network traffic or CPU usage.

I hope this is meant to say that it is moot to discuss
the Linux NFS/TCP advantages until the bug is found and
corrected.  It is an implementation problem and not a
protocol problem.  Other clients and server are known
to work quite well under a full range of load.

The Linux NFS client and server have come a long way but
unfortunately, there appears to be a couple more bugs to 
get rid of...

Spencer


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
