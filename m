From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: 1279 mounts
Date: Sat, 27 Apr 2002 21:32:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020427213236.A20253@devserv.devel.redhat.com>
References: <20020425162106.A30736@devserv.devel.redhat.com> <Pine.LNX.4.44.0204261120520.19032-100000@chip.2y.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pete Zaitcev <zaitcev@redhat.com>, nfs@lists.sourceforge.net,
   linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=devserv.devel.redhat.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 171dYO-0005KH-00
	for <nfs@lists.sourceforge.net>; Sat, 27 Apr 2002 18:32:41 -0700
To: Panu Matilainen <pmatilai@welho.com>
In-Reply-To: <Pine.LNX.4.44.0204261120520.19032-100000@chip.2y.net>; from pmatilai@welho.com on Fri, Apr 26, 2002 at 11:25:33AM +0300
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

> Date: Fri, 26 Apr 2002 11:25:33 +0300 (EEST)
> From: Panu Matilainen <pmatilai@welho.com>

> I've got quite a few users here who "need" this functionality and it's 
> included in our RH-based custom kernels. Having it as a separate patch 
> for 2.4 is no problem, for 2.5 I'm hoping we finally move to 32bit device 
> numbers...

Mind, we only ship the unnamed majors part, but not the NFS part.
There is no word from util-linux maintainer about required
changes to mount(8), so I was cautious about doint that.

-- Pete

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
