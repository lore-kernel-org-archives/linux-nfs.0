From: Panu Matilainen <pmatilai@welho.com>
Subject: Re: 1279 mounts
Date: Sun, 28 Apr 2002 20:57:59 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <aahekq$77b$2@main.gmane.org>
References: <20020427213236.A20253@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs145025.pp.htv.fi ([213.243.145.25] helo=chip.2y.net)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 171sw9-0002LM-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Apr 2002 10:58:14 -0700
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20020427213236.A20253@devserv.devel.redhat.com>
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

On Sat, 27 Apr 2002, Pete Zaitcev wrote:

> > Date: Fri, 26 Apr 2002 11:25:33 +0300 (EEST)
> > From: Panu Matilainen <pmatilai@welho.com>
> 
> > I've got quite a few users here who "need" this functionality and it's 
> > included in our RH-based custom kernels. Having it as a separate patch 
> > for 2.4 is no problem, for 2.5 I'm hoping we finally move to 32bit device 
> > numbers...
> 
> Mind, we only ship the unnamed majors part, but not the NFS part.
> There is no word from util-linux maintainer about required
> changes to mount(8), so I was cautious about doint that.

Sure, I know. In these cases getting the limit from 255 to around 800 is 
enough so the mount patch isn't even needed.

	- Panu -


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
