From: Lincoln Dale <ltd@cisco.com>
Subject: Re: [PATCH] direct-IO API change
Date: Sat, 05 Oct 2002 19:49:29 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.1.0.14.2.20021005194507.031018c0@mira-sjcm-3.cisco.com>
References: <3D9E1847.F6DDA3AE@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Andrew Morton <akpm@digeo.com>, Chuck Lever <cel@citi.umich.edu>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sj-msg-core-3.cisco.com ([171.70.157.152])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17xlbB-00016B-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Oct 2002 02:51:49 -0700
To: Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <Pine.LNX.4.44.0210041621170.2526-100000@home.transmeta.com
 >
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

At 04:23 PM 4/10/2002 -0700, Linus Torvalds wrote:
>Especially since I thought that O_DIRECT on the regular file (or block
>device) performed about as well as raw does anyway these days? Or is that
>just one of my LSD-induced flashbacks?

from my multiple 64/66 PCI bus + multiple 2gbit/s FC HBA tests, yes, 
they're around the same.
(now up to 390mbyte/sec throughput on latest & greatest x86 hardware i 
have; front-side-bus no longer the limiting factor, but dual 64/66 PCI).

of course, purely synthetic tests designed to stress Fibre Channel 
switching infrastructure, not real-world disk i/o..


cheers,

lincoln.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
