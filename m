From: Arun Sharma <arun.sharma@intel.com>
Subject: Re: VFS: Busy inodes after unmount on 2 way SMP
Date: Fri, 12 Sep 2003 17:08:58 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F62601A.5000105@intel.com>
References: <200309122333.h8CNXbW09877@moisil.badula.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, autofs@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xy0I-0003q1-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 17:11:06 -0700
Received: from fmr04.intel.com ([143.183.121.6] helo=caduceus.sc.intel.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19xy0H-00055v-Tg
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 17:11:05 -0700
To: Ion Badulescu <lists@news.cs.columbia.edu>
In-Reply-To: <200309122333.h8CNXbW09877@moisil.badula.org>
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

Ion Badulescu wrote:
> 
> I don't know if it's the same issue, but I've seen it many many times 
> while testing amd's autofs functionality. It occurs when a non-empty 
> autofs filesystem is unmounted, e.g. if it has some leftover 
> subdirectories from previous mounts. Therefore I'd say it's quite 
> clearly an autofs issue, at least in my case.

Do you have a case that can deterministically reproduce the issue ? 

> Do you see it when shutting down the automounter, or in other cases as 
> well?

Everytime I've seen it, it's during an unmount by /usr/sbin/automount after the mount has expired. It's usually coupled with a temporarily unreachable NFS server.

	-Arun



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
