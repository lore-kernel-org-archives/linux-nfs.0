From: Shanker Balan <shanu@exocore.com>
Subject: Re: 1279 mounts
Date: Fri, 26 Apr 2002 11:27:11 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020426055710.GA3797@exocore.com>
References: <20020425162106.A30736@devserv.devel.redhat.com>
Reply-To: nfs@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from premium.exocore.com ([203.197.173.224])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 170yjJ-0008E4-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Apr 2002 22:57:13 -0700
Received: from godzilla.exocore.com (cix.exocore.com [202.71.153.165])
	(authenticated (0 bits))
	by premium.exocore.com (8.11.6/8.11.6) with ESMTP id g3Q5v1U08918
	for <nfs@lists.sourceforge.net>; Fri, 26 Apr 2002 11:27:01 +0530
To: nfs@lists.sourceforge.net
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

Hello:

Pete Zaitcev wrote,
> I updated my patch that allows to mount unholy numbers of volumes.
> The old version was for 2.4.9 and did not apply anymore.  I split the
> unnamed majors patch and the NFS patch.  Also, CONFIG_ option is gone,
> because it made the code ugly.
> 
> Majors part:
> http://people.redhat.com/zaitcev/linux/linux-2.4.19-pre7-unmaj.diff
> NFS part:
> http://people.redhat.com/zaitcev/linux/linux-2.4.19-pre7-nores.diff
> Userland for NFS:
> http://people.redhat.com/zaitcev/linux/util-linux-2.11q-nores1.diff
 
> Is anyone actually interested? Random people periodically ask me for
> patches, get them and disappear into the void. 

Heh, one of them would be me! :-D

> I hear nothing good or bad (well, nothing since Trond reviewed it
> several months ago, and also someone found a conflict with NFS server
> code, since fixed). 

The requirement for such a large number of mounts does not exist for me
anymore so the patches never went into the production environment for
me.

> I am thinking about submitting, but if users do not ask, why add extra
> bloat and negotiate with LANANA...

IMHO, the Linux kernel's inability to handle mounts > 256 mounts is a
deficiency. 

AFAIK, FreeBSD does not have this problem. I would really appreciate it
if these patches made it into the kernel so that I wont be surprised to
realize that Linux cant do more than 256 mounts out of the box the
next time I try it.

Zaitcev, thanx for making those patches available in the first place.
Oh, will you be rolling the user land patches to util-linux to the RedHat
RPMS?

-- Shanu

-- 
Workers of the world, arise!  You have nothing to lose but your
chairs.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
