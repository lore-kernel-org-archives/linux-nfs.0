From: Panu Matilainen <pmatilai@welho.com>
Subject: Re: 1279 mounts
Date: Fri, 26 Apr 2002 11:25:33 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204261120520.19032-100000@chip.2y.net>
References: <20020425162106.A30736@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs145025.pp.htv.fi ([213.243.145.25] helo=chip.2y.net)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 171134-00044U-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Apr 2002 01:25:47 -0700
To: Pete Zaitcev <zaitcev@redhat.com>
In-Reply-To: <20020425162106.A30736@devserv.devel.redhat.com>
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

On Thu, 25 Apr 2002, Pete Zaitcev wrote:

> I updated my patch that allows to mount unholy numbers of volumes.
> The old version was for 2.4.9 and did not apply anymore.
> I split the unnamed majors patch and the NFS patch.
> Also, CONFIG_ option is gone, because it made the code ugly.
> 
> Majors part:
>  http://people.redhat.com/zaitcev/linux/linux-2.4.19-pre7-unmaj.diff
> NFS part:
>  http://people.redhat.com/zaitcev/linux/linux-2.4.19-pre7-nores.diff
> Userland for NFS:
>  http://people.redhat.com/zaitcev/linux/util-linux-2.11q-nores1.diff
> 
> Is anyone actually interested? Random people periodically ask
> me for patches, get them and disappear into the void. I hear
> nothing good or bad (well, nothing since Trond reviewed it
> several months ago, and also someone found a conflict with NFS
> server code, since fixed). I am thinking about submitting,
> but if users do not ask, why add extra bloat and negotiate
> with LANANA...

I've got quite a few users here who "need" this functionality and it's 
included in our RH-based custom kernels. Having it as a separate patch 
for 2.4 is no problem, for 2.5 I'm hoping we finally move to 32bit device 
numbers...

	- Panu -


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
