From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
Subject: Re: Strange behavior of executable bit]
Date: Thu, 03 Jun 2004 22:26:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40BF895C.9090909@byggmek.lth.se>
References: <c3d3acab1f.cab1fc3d3a@llnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVyn6-0004Ty-AE
	for nfs@lists.sourceforge.net; Thu, 03 Jun 2004 13:26:20 -0700
Received: from av7-2-sn4.m-sp.skanova.net ([81.228.10.109])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVyn3-0002HI-MV
	for nfs@lists.sourceforge.net; Thu, 03 Jun 2004 13:26:17 -0700
To: Albert Chu <chu11@llnl.gov>
In-Reply-To: <c3d3acab1f.cab1fc3d3a@llnl.gov>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Albert Chu wrote:

>Hi Jonas,
>
>I'm not sure if you're fixed your problem or not.  I just found a kernel
>bug in RHEL3 that probably fixes your issue.  I've submitted it back to
>Redhat.  I don't know how fast they'll be about getting the bug fix to
>you, but it has already begun its trip through their pipeline.
> =20
>
I think your solution solved the problem, but I want to give it some=20
more days before I am certain. Thanks a lot for your suggestions. I was=20
getting really desperate.

-- Jonas

>Al
>
>--
>Albert Chu
>chu11@llnl.gov
>Lawrence Livermore National Laboratory
>
>----- Original Message -----
>From: Albert Chu <chu11@llnl.gov>
>Date: Wednesday, May 26, 2004 10:43 am
>Subject: Re: [NFS] Strange behavior of executable bit]
>
>
> =20
>
>------------------------------------------------------------------------
>
>Jonas,
>
>We've come upon this problem with RHEL3 on our clusters. So far, we've
>found that the only NFS configurable solution is to remove attribute
>caching (setting "noac" or "acregmin=3D0" in fstab).  Setting the cache
>timeouts to 1 second (acregmin=3D1,acregmax=3D1) isn't good enough to re=
move
>the problem.
>
>Al
>
>--
>Albert Chu
>chu11@llnl.gov
>Lawrence Livermore National Laboratory
>
>----- Original Message -----
>From: Ben Woodard <bwoodard@llnl.gov>
>Date: Wednesday, May 26, 2004 9:36 am
>Subject: [Fwd: [NFS] Strange behavior of executable bit]
>
> =20
>
>>Here is someone else having the same problem it looks like.
>>--=20
>>Ben Woodard <bwoodard@llnl.gov>
>>Red Hat Inc.
>>
>>   =20
>>
>Content-type: multipart/digest; boundary=3D"Boundary_(ID_zZIxsZfaTzLHkpJ=
n4/X1uA)"
>Content-description: Forwarded messages
>
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)
>
>MIME-version: 1.0
>Content-type: message/rfc822
>Content-description: Forwarded message - [NFS] Strange behavior of	execu=
table
> bit
>
>Return-path: <nfs-admin@lists.sourceforge.net>
>Received: from pobox.corp.redhat.com ([unix socket])
> by	pobox.corp.redhat.com (Cyrus v2.1.12) with LMTP; Wed,
> 26 May 2004 04:07:29 -0400
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by pobox.corp.redhat.com
> (8.12.8/8.12.8) with ESMTP id	i4Q87TO6005013; Wed, 26 May 2004 04:07:29=
 -0400
>Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4Q87S009856; =
Wed,
> 26 May 2004 04:07:28 -0400
>Received: from sc8-sf-list2.sourceforge.net
> (lists.sourceforge.net	[66.35.250.206]) by mx1.redhat.com (8.12.10/8.12=
.10)
> with ESMTP id	i4Q87Ri5022931; Wed, 26 May 2004 04:07:27 -0400
>Received: from localhost ([127.0.0.1] helo=3Dprojects.sourceforge.net)
> by	sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
> id 1BStRH-0000PW-3M; Wed, 26 May 2004 01:07:03 -0700
>Received: from sc8-sf-mx2-b.sourceforge.net
> ([10.3.1.12]	helo=3Dsc8-sf-mx2.sourceforge.net) by sc8-sf-list2.sourcef=
orge.net
> with esmtp	(Exim 4.30) id 1BStQQ-0000AW-CN for nfs@lists.sourceforge.ne=
t; Wed,
> 26 May 2004 01:06:10 -0700
>Received: from av5-2-sn3.vrr.skanova.net ([81.228.9.114])
> by	sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
> id 1BStQN-0005li-Db for	nfs@lists.sourceforge.net; Wed,
> 26 May 2004 01:06:07 -0700
>Received: by av5-2-sn3.vrr.skanova.net (Postfix, from userid 502)
> id	93BE337E9F; Wed, 26 May 2004 10:06:01 +0200 (CEST)
>Received: from smtp1-2-sn3.vrr.skanova.net
> (smtp1-2-sn3.vrr.skanova.net	[81.228.9.178]) by av5-2-sn3.vrr.skanova.n=
et
> (Postfix) with ESMTP id	85DA537E42 for <nfs@lists.sourceforge.net>; Wed=
,
> 26 May 2004 10:06:01 +0200 (CEST)
>Received: from byggmek.lth.se (h5n2fls309o1101.telia.com [81.226.193.5])
> by	smtp1-2-sn3.vrr.skanova.net (Postfix) with ESMTP id 44F733800F for
>	<nfs@lists.sourceforge.net>; Wed, 26 May 2004 10:06:01 +0200 (CEST)
>Date: Wed, 26 May 2004 10:05:59 +0200
>From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
>Subject: [NFS] Strange behavior of executable bit
>Sender: nfs-admin@lists.sourceforge.net
>To: nfs@lists.sourceforge.net
>Errors-to: nfs-admin@lists.sourceforge.net
>Message-id: <40B44FE7.6010601@byggmek.lth.se>
>MIME-version: 1.0
>Content-type: text/plain; CHARSET=3DISO-8859-1; FORMAT=3Dflowed
>Content-transfer-encoding: 7BIT
>X-Accept-Language: en-us, en
>Precedence: bulk
>X-BeenThere: nfs@lists.sourceforge.net
>User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.6)
>	Gecko/20040113
>X-Sieve: CMU Sieve 2.2
>X-Spam-Report: Spam Filtering performed by sourceforge.net. See
>	http://spamassassin.org/tag/ for more details. Report problems to
>	http://sf.net/tracker/?func=3Dadd&group_id=3D1&atid=3D200001
>X-Original-Date: Wed, 26 May 2004 10:05:59 +0200
>X-RedHat-Spam-Score: 0
>X-Mailman-Version: 2.0.9-sf.net
>List-Post: <mailto:nfs@lists.sourceforge.net>
>List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dsubscribe>
>List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dunsubscribe>
>List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs>
>List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=3Dhelp>
>List-Id: Discussion of NFS under Linux development, interoperability,
> and	testing. <nfs.lists.sourceforge.net>
>
>Hi!
>
>We have an file server runninng RHEL3 and NFS. Clients are RHEL3 and=20
>FC1. We are having problems with an service that want's to change the=20
>executable bit on a file located on the NFS exported filesystem. The=20
>service is running on RHEL3.
>
>Client:
>
>Linux version 2.4.21-9.0.1.ELsmp (bhcompile@bugs.devel.redhat.com) (gcc=20
>version 3.2.3 20030502 (Red Hat Linux 3.2.3-26)) #1 SMP Mon Feb 9=20
>22:26:51 EST 2004
>redhat-config-nfs-1.0.13-1
>nfs-utils-1.0.6-21EL
>
>Server:
>
>Linux version 2.4.21-9.0.1.EL040519 (root@s1) (gcc version 3.2.3=20
>20030502 (Red Hat Linux 3.2.3-20)) #2 SMP Wed May 19 14:56:39 CEST 2004
>redhat-config-nfs-1.0.13-1
>nfs-utils-1.0.6-21EL
>
>
>The results are strange and listed below:
>
>Running the following script:
>
>for i1 in 0 1 2 3 4 5 6 7 8 9 ; do
>for i2 in 0 1 2 3 4 5 6 7 8 9 ; do
>for i3 in 0 1 2 3 4 5 6 7 8 9 ; do
>ls -l "$joboption_directory/test.sh" 1>&2
>/bin/usleep 100000
>done
>done
>done
>
>
>Produce these results:
>
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
>52341085501427351028959/test.sh
>
>
>And then it stabilizes.
>
>I have no clue to what the problem might be. Is it client or server=20
>related?
>
>Many regards
>
>Jonas Lindemann
>
>
>
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)
>
>MIME-version: 1.0
>Content-type: message/rfc822
>Content-description: Forwarded message - Re: [NFS] Strange behavior of
>	executable bit
>
>Return-path: <nfs-admin@lists.sourceforge.net>
>Received: from pobox.corp.redhat.com ([unix socket])
> by	pobox.corp.redhat.com (Cyrus v2.1.12) with LMTP; Wed,
> 26 May 2004 06:44:35 -0400
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by pobox.corp.redhat.com
> (8.12.8/8.12.8) with ESMTP id	i4QAiZO6019746; Wed, 26 May 2004 06:44:35=
 -0400
>Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4QAiY012629; =
Wed,
> 26 May 2004 06:44:34 -0400
>Received: from sc8-sf-list2.sourceforge.net
> (lists.sourceforge.net	[66.35.250.206]) by mx1.redhat.com (8.12.10/8.12=
.10)
> with ESMTP id	i4QAiXi5007332; Wed, 26 May 2004 06:44:33 -0400
>Received: from localhost ([127.0.0.1] helo=3Dprojects.sourceforge.net)
> by	sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
> id 1BSvsE-0001NT-Qv; Wed, 26 May 2004 03:43:02 -0700
>Received: from sc8-sf-mx2-b.sourceforge.net
> ([10.3.1.12]	helo=3Dsc8-sf-mx2.sourceforge.net) by sc8-sf-list2.sourcef=
orge.net
> with esmtp	(Exim 4.30) id 1BSvrN-00019U-5r for nfs@lists.sourceforge.ne=
t; Wed,
> 26 May 2004 03:42:09 -0700
>Received: from av3-1-sn3.vrr.skanova.net ([81.228.9.109])
> by	sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
> id 1BSvrM-000797-OZ for	nfs@lists.sourceforge.net; Wed,
> 26 May 2004 03:42:08 -0700
>Received: by av3-1-sn3.vrr.skanova.net (Postfix, from userid 502)
> id	B257337EA1; Wed, 26 May 2004 12:42:02 +0200 (CEST)
>Received: from smtp1-2-sn3.vrr.skanova.net
> (smtp1-2-sn3.vrr.skanova.net	[81.228.9.178]) by av3-1-sn3.vrr.skanova.n=
et
> (Postfix) with ESMTP id	A474137E4B for <nfs@lists.sourceforge.net>; Wed=
,
> 26 May 2004 12:42:02 +0200 (CEST)
>Received: from byggmek.lth.se (h5n2fls309o1101.telia.com [81.226.193.5])
> by	smtp1-2-sn3.vrr.skanova.net (Postfix) with ESMTP id 858113801F for
>	<nfs@lists.sourceforge.net>; Wed, 26 May 2004 12:42:02 +0200 (CEST)
>Date: Wed, 26 May 2004 12:42:00 +0200
>From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
>Subject: Re: [NFS] Strange behavior of executable bit
>In-reply-to: <40B462A3.1070704@RedHat.com>
>Sender: nfs-admin@lists.sourceforge.net
>To: nfs@lists.sourceforge.net
>Errors-to: nfs-admin@lists.sourceforge.net
>Message-id: <40B47478.4020101@byggmek.lth.se>
>MIME-version: 1.0
>Content-type: text/plain; CHARSET=3Dus-ascii; FORMAT=3Dflowed
>Content-transfer-encoding: 7BIT
>X-Accept-Language: en-us, en
>Precedence: bulk
>X-BeenThere: nfs@lists.sourceforge.net
>User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.6)
>	Gecko/20040113
>X-Sieve: CMU Sieve 2.2
>X-Spam-Report: Spam Filtering performed by sourceforge.net. See
>	http://spamassassin.org/tag/ for more details. Report problems to
>	http://sf.net/tracker/?func=3Dadd&group_id=3D1&atid=3D200001
>X-Original-Date: Wed, 26 May 2004 12:42:00 +0200
>X-RedHat-Spam-Score: 0
>References: <40B44FE7.6010601@byggmek.lth.se> <40B462A3.1070704@RedHat.c=
om>
>X-Mailman-Version: 2.0.9-sf.net
>List-Post: <mailto:nfs@lists.sourceforge.net>
>List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dsubscribe>
>List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dunsubscribe>
>List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs>
>List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=3Dhelp>
>List-Id: Discussion of NFS under Linux development, interoperability,
> and	testing. <nfs.lists.sourceforge.net>
>
>Steve Dickson wrote:
>
> =20
>
>>Jonas Lindemann wrote:
>>
>>   =20
>>
>>>Running the following script:
>>>
>>>for i1 in 0 1 2 3 4 5 6 7 8 9 ; do
>>>for i2 in 0 1 2 3 4 5 6 7 8 9 ; do
>>>for i3 in 0 1 2 3 4 5 6 7 8 9 ; do
>>>ls -l "$joboption_directory/test.sh" 1>&2
>>>/bin/usleep 100000
>>>done
>>>done
>>>done
>>>
>>>
>>>Produce these results:
>>>
>>>And then it stabilizes.
>>>     =20
>>>
>>I guess I'm  a bit confused... What are the expected results or
>>what do you mean by "stabilizes"?
>>   =20
>>
>
>The file is uploaded via a gridftp. A special service is responsible for
>marking certain files as executable in the above case "test.sh". The
>testscript is called directly after this service has set the bit. The
>problem seems to be that this bit is not directly set, and execution of
>this file fails. Rebooting the server makes the problem go away for
>about a week, then it resurfaces again.
>
>-- Jonas
>
> =20
>
>>SteveD.
>>
>>
>>-------------------------------------------------------
>>This SF.Net email is sponsored by: Oracle 10g
>>Get certified on the hottest thing ever to hit the market... Oracle=20
>>10g. Take an Oracle 10g class now, and we'll give you the exam FREE.
>>http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
>>   =20
>>
>
>
>
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)
>
>MIME-version: 1.0
>Content-type: message/rfc822
>Content-description: Forwarded message - Re: [NFS] Strange behavior of
>	executable bit
>
>Return-path: <nfs-admin@lists.sourceforge.net>
>Received: from pobox.corp.redhat.com ([unix socket])
> by	pobox.corp.redhat.com (Cyrus v2.1.12) with LMTP; Wed,
> 26 May 2004 06:51:25 -0400
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by pobox.corp.redhat.com
> (8.12.8/8.12.8) with ESMTP id	i4QApPO6020625; Wed, 26 May 2004 06:51:25=
 -0400
>Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4QApP014862; =
Wed,
> 26 May 2004 06:51:25 -0400
>Received: from sc8-sf-list2.sourceforge.net
> (lists.sourceforge.net	[66.35.250.206]) by mx1.redhat.com (8.12.10/8.12=
.10)
> with ESMTP id	i4QApNi5010268; Wed, 26 May 2004 06:51:23 -0400
>Received: from localhost ([127.0.0.1] helo=3Dprojects.sourceforge.net)
> by	sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
> id 1BSvz6-0002ik-4V; Wed, 26 May 2004 03:50:08 -0700
>Received: from sc8-sf-mx1-b.sourceforge.net
> ([10.3.1.11]	helo=3Dsc8-sf-mx1.sourceforge.net) by sc8-sf-list2.sourcef=
orge.net
> with esmtp	(Exim 4.30) id 1BSvyB-0002Vz-K7 for nfs@lists.sourceforge.ne=
t; Wed,
> 26 May 2004 03:49:11 -0700
>Received: from av9-1-sn1.fre.skanova.net ([81.228.11.115])
> by	sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
> id 1BSvyB-0007qv-3d for	nfs@lists.sourceforge.net; Wed,
> 26 May 2004 03:49:11 -0700
>Received: by av9-1-sn1.fre.skanova.net (Postfix, from userid 502)
> id	09DE937EAC; Wed, 26 May 2004 12:49:03 +0200 (CEST)
>Received: from smtp3-2-sn1.fre.skanova.net
> (smtp3-2-sn1.fre.skanova.net	[81.228.11.164]) by av9-1-sn1.fre.skanova.=
net
> (Postfix) with ESMTP id	EF09A37E44; Wed, 26 May 2004 12:49:02 +0200 (CE=
ST)
>Received: from byggmek.lth.se (h5n2fls309o1101.telia.com [81.226.193.5])
> by	smtp3-2-sn1.fre.skanova.net (Postfix) with ESMTP id C305337E71; Wed,
> 26 May 2004 12:49:00 +0200 (CEST)
>Date: Wed, 26 May 2004 12:48:58 +0200
>From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
>Subject: Re: [NFS] Strange behavior of executable bit
>In-reply-to: <40B47557.2000400@RedHat.com>
>Sender: nfs-admin@lists.sourceforge.net
>To: Steve Dickson <SteveD@redhat.com>
>Cc: nfs@lists.sourceforge.net
>Errors-to: nfs-admin@lists.sourceforge.net
>Message-id: <40B4761A.6020705@byggmek.lth.se>
>MIME-version: 1.0
>Content-type: text/plain; charset=3DISO-8859-1; format=3Dflowed
>Content-transfer-encoding: 7BIT
>X-Accept-Language: en-us, en
>Precedence: bulk
>X-BeenThere: nfs@lists.sourceforge.net
>User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.6)
>	Gecko/20040113
>X-Sieve: CMU Sieve 2.2
>X-Spam-Report: Spam Filtering performed by sourceforge.net. See
>	http://spamassassin.org/tag/ for more details. Report problems to
>	http://sf.net/tracker/?func=3Dadd&group_id=3D1&atid=3D200001
>X-Original-Date: Wed, 26 May 2004 12:48:58 +0200
>X-RedHat-Spam-Score: 0
>References: <40B44FE7.6010601@byggmek.lth.se> <40B462A3.1070704@RedHat.c=
om>
> <40B4708F.1070707@byggmek.lth.se> <40B47557.2000400@RedHat.com>
>X-Mailman-Version: 2.0.9-sf.net
>List-Post: <mailto:nfs@lists.sourceforge.net>
>List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dsubscribe>
>List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dunsubscribe>
>List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs>
>List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=3Dhelp>
>List-Id: Discussion of NFS under Linux development, interoperability,
> and	testing. <nfs.lists.sourceforge.net>
>
>Steve Dickson wrote:
>
> =20
>
>>Jonas Lindemann wrote:
>>
>>   =20
>>
>>>Steve Dickson wrote:
>>>
>>>     =20
>>>
>>>>I guess I'm  a bit confused... What are the expected results or
>>>>what do you mean by "stabilizes"?
>>>>       =20
>>>>
>>>The file is uploaded via a gridftp. A special service is responsible=20
>>>for marking certain files as executable in the above case "test.sh".=20
>>>The testscript is called directly after this service has set the bit.=20
>>>The problem seems to be that this bit is not directly set, and=20
>>>execution of this file fails. Rebooting the server makes the problem=20
>>>go away for about a week, then it resurfaces again.
>>>     =20
>>>
>>So are you saying that the client has the directory mounted and then
>>this special service runs (on the server) setting the executable bit=20
>>on test.sh
>>but the client never sees that bit being set?
>>   =20
>>
>
>The service runs on the client, and does not see this bit when queried.
>
> =20
>
>>SteveD.
>>
>>   =20
>>
>
>
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)
>
>MIME-version: 1.0
>Content-type: message/rfc822
>Content-description: Forwarded message - Re: [NFS] Strange behavior of
>	executable bit
>
>Return-path: <nfs-admin@lists.sourceforge.net>
>Received: from pobox.corp.redhat.com ([unix socket])
> by	pobox.corp.redhat.com (Cyrus v2.1.12) with LMTP; Wed,
> 26 May 2004 10:03:07 -0400
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by pobox.corp.redhat.com
> (8.12.8/8.12.8) with ESMTP id	i4QE37O6014004; Wed, 26 May 2004 10:03:07=
 -0400
>Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4QE37011797; =
Wed,
> 26 May 2004 10:03:07 -0400
>Received: from sc8-sf-list2.sourceforge.net
> (lists.sourceforge.net	[66.35.250.206]) by mx1.redhat.com (8.12.10/8.12=
.10)
> with ESMTP id	i4QE35i5022652; Wed, 26 May 2004 10:03:05 -0400
>Received: from localhost ([127.0.0.1] helo=3Dprojects.sourceforge.net)
> by	sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
> id 1BSyz2-0000Pr-3o; Wed, 26 May 2004 07:02:16 -0700
>Received: from sc8-sf-mx1-b.sourceforge.net
> ([10.3.1.11]	helo=3Dsc8-sf-mx1.sourceforge.net) by sc8-sf-list2.sourcef=
orge.net
> with esmtp	(Exim 4.30) id 1BSyyL-0000I3-2N for nfs@lists.sourceforge.ne=
t; Wed,
> 26 May 2004 07:01:33 -0700
>Received: from mx1.redhat.com ([66.187.233.31]) by	sc8-sf-mx1.sourceforg=
e.net
> with esmtp (TLSv1:AES256-SHA:256) (Exim 4.30)
> id	1BSyyK-000843-Kb for nfs@lists.sourceforge.net; Wed,
> 26 May 2004 07:01:32 -0700
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by mx1.redhat.com (8.12.10/8.=
12.10)
> with ESMTP id	i4QE1Ui5022002; Wed, 26 May 2004 10:01:30 -0400
>Received: from lacrosse.corp.redhat.com
> (lacrosse.corp.redhat.com	[172.16.52.154]) by int-mx1.corp.redhat.com
> (8.11.6/8.11.6) with ESMTP id	i4QE1U011186; Wed, 26 May 2004 10:01:30 -=
0400
>Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
> by	lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4QE1Tl15274;=
 Wed,
> 26 May 2004 10:01:29 -0400
>Date: Wed, 26 May 2004 10:02:46 -0400
>From: Steve Dickson <SteveD@redhat.com>
>Subject: Re: [NFS] Strange behavior of executable bit
>In-reply-to: <40B4761A.6020705@byggmek.lth.se>
>Sender: nfs-admin@lists.sourceforge.net
>To: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
>Cc: nfs@lists.sourceforge.net
>Errors-to: nfs-admin@lists.sourceforge.net
>Message-id: <40B4A386.8090403@RedHat.com>
>MIME-version: 1.0
>Content-type: text/plain; charset=3Dus-ascii; format=3Dflowed
>Content-transfer-encoding: 7BIT
>X-Accept-Language: en-us, en
>Precedence: bulk
>X-BeenThere: nfs@lists.sourceforge.net
>User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/200401=
13
>X-Sieve: CMU Sieve 2.2
>X-Spam-Report: Spam Filtering performed by sourceforge.net. See
>	http://spamassassin.org/tag/ for more details. Report problems to
>	http://sf.net/tracker/?func=3Dadd&group_id=3D1&atid=3D200001
>X-Original-Date: Wed, 26 May 2004 10:02:46 -0400
>X-RedHat-Spam-Score: 0
>References: <40B44FE7.6010601@byggmek.lth.se> <40B462A3.1070704@RedHat.c=
om>
> <40B4708F.1070707@byggmek.lth.se> <40B47557.2000400@RedHat.com>
> <40B4761A.6020705@byggmek.lth.se>
>X-Mailman-Version: 2.0.9-sf.net
>List-Post: <mailto:nfs@lists.sourceforge.net>
>List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dsubscribe>
>List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dunsubscribe>
>List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs>
>List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=3Dhelp>
>List-Id: Discussion of NFS under Linux development, interoperability,
> and	testing. <nfs.lists.sourceforge.net>
>
>
>
>Jonas Lindemann wrote:
>
> =20
>
>>Steve Dickson wrote:
>>
>>   =20
>>
>>>So are you saying that the client has the directory mounted and then
>>>this special service runs (on the server) setting the executable bit=20
>>>on test.sh
>>>but the client never sees that bit being set?
>>>     =20
>>>
>>The service runs on the client, and does not see this bit when queried.
>>   =20
>>
>
>hmm... so "chmod 700 test.sh ; ls -l test.sh" shows the
>file being set to the 0600 mode... with all changes being
>made from the client... Could you possibly make a compressed
>ethereal trace of this phenomenon available?
>
>SteveD.
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)
>
>MIME-version: 1.0
>Content-type: message/rfc822
>Content-description: Forwarded message - Re: [NFS] Strange behavior of
>	executable bit
>
>Return-path: <nfs-admin@lists.sourceforge.net>
>Received: from pobox.corp.redhat.com ([unix socket])
> by	pobox.corp.redhat.com (Cyrus v2.1.12) with LMTP; Wed,
> 26 May 2004 12:14:40 -0400
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by pobox.corp.redhat.com
> (8.12.8/8.12.8) with ESMTP id	i4QGEeO6007447; Wed, 26 May 2004 12:14:40=
 -0400
>Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4QGEd008405; =
Wed,
> 26 May 2004 12:14:39 -0400
>Received: from sc8-sf-list2.sourceforge.net
> (lists.sourceforge.net	[66.35.250.206]) by mx1.redhat.com (8.12.10/8.12=
.10)
> with ESMTP id	i4QGEbi5016106; Wed, 26 May 2004 12:14:37 -0400
>Received: from localhost ([127.0.0.1] helo=3Dprojects.sourceforge.net)
> by	sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
> id 1BT11Z-0001L2-5F; Wed, 26 May 2004 09:13:01 -0700
>Received: from sc8-sf-mx1-b.sourceforge.net
> ([10.3.1.11]	helo=3Dsc8-sf-mx1.sourceforge.net) by sc8-sf-list2.sourcef=
orge.net
> with esmtp	(Exim 4.30) id 1BT10c-00017O-4O for nfs@lists.sourceforge.ne=
t; Wed,
> 26 May 2004 09:12:02 -0700
>Received: from dh132.citi.umich.edu
> ([141.211.133.132]	helo=3Dlade.trondhjem.org ident=3DDebian-exim)
> by sc8-sf-mx1.sourceforge.net	with esmtp (TLSv1:RC4-SHA:128) (Exim 4.30=
)
> id 1BT10b-0005Ja-Qt for	nfs@lists.sourceforge.net; Wed,
> 26 May 2004 09:12:01 -0700
>Received: from trondmy by lade.trondhjem.org with local (Exim 4.34)
> id	1BT10W-0001Rv-3M; Wed, 26 May 2004 12:11:56 -0400
>Date: Wed, 26 May 2004 12:11:56 -0400
>From: Trond Myklebust <trond.myklebust@fys.uio.no>
>Subject: Re: [NFS] Strange behavior of executable bit
>In-reply-to: <40B44FE7.6010601@byggmek.lth.se>
>Sender: nfs-admin@lists.sourceforge.net
>To: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
>Cc: nfs@lists.sourceforge.net
>Errors-to: nfs-admin@lists.sourceforge.net
>Message-id: <1085587915.3763.12.camel@lade.trondhjem.org>
>MIME-version: 1.0
>X-Mailer: Ximian Evolution 1.4.6
>Content-type: text/plain; charset=3Diso-8859-1
>Content-transfer-encoding: 8BIT
>Precedence: bulk
>X-BeenThere: nfs@lists.sourceforge.net
>X-Sieve: CMU Sieve 2.2
>X-Spam-Report: Spam Filtering performed by sourceforge.net. See
>	http://spamassassin.org/tag/ for more details. Report problems to
>	http://sf.net/tracker/?func=3Dadd&group_id=3D1&atid=3D200001
>X-Original-Date: Wed, 26 May 2004 12:11:56 -0400
>X-RedHat-Spam-Score: 0
>References: <40B44FE7.6010601@byggmek.lth.se>
>X-Mailman-Version: 2.0.9-sf.net
>List-Post: <mailto:nfs@lists.sourceforge.net>
>List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dsubscribe>
>List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dunsubscribe>
>List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs>
>List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=3Dhelp>
>List-Id: Discussion of NFS under Linux development, interoperability,
> and	testing. <nfs.lists.sourceforge.net>
>
>P=E5 on , 26/05/2004 klokka 04:05, skreiv Jonas Lindemann:
> =20
>
>>Hi!
>>
>>We have an file server runninng RHEL3 and NFS. Clients are RHEL3 and=20
>>FC1. We are having problems with an service that want's to change the=20
>>executable bit on a file located on the NFS exported filesystem. The=20
>>service is running on RHEL3.
>>   =20
>>
>
>So basically, you are changing the executable bit on the server, and
>wondering why that changes isn't propagated instantly to the client?
>
>It's 'cos NFS client poll the server for attribute changes. The mount
>options that govern the polling period is documented in the "nfs"
>manpage (see the ac* flags).
>
>Cheers,
>  Trond
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id149&alloc_id=8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)
>
>MIME-version: 1.0
>Content-type: message/rfc822
>Content-description: Forwarded message - Re: [NFS] Strange behavior of
>	executable bit
>
>Return-path: <nfs-admin@lists.sourceforge.net>
>Received: from pobox.corp.redhat.com ([unix socket])
> by	pobox.corp.redhat.com (Cyrus v2.1.12) with LMTP; Wed,
> 26 May 2004 05:27:44 -0400
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by pobox.corp.redhat.com
> (8.12.8/8.12.8) with ESMTP id	i4Q9RiO6012766; Wed, 26 May 2004 05:27:44=
 -0400
>Received: from mx1.redhat.com (mx1.redhat.com [172.16.48.31])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4Q9Ri027711; =
Wed,
> 26 May 2004 05:27:44 -0400
>Received: from sc8-sf-list2.sourceforge.net
> (lists.sourceforge.net	[66.35.250.206]) by mx1.redhat.com (8.12.10/8.12=
.10)
> with ESMTP id	i4Q9Rgi5015769; Wed, 26 May 2004 05:27:42 -0400
>Received: from localhost ([127.0.0.1] helo=3Dprojects.sourceforge.net)
> by	sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
> id 1BSugh-0002nm-Vg; Wed, 26 May 2004 02:27:03 -0700
>Received: from sc8-sf-mx1-b.sourceforge.net
> ([10.3.1.11]	helo=3Dsc8-sf-mx1.sourceforge.net) by sc8-sf-list2.sourcef=
orge.net
> with esmtp	(Exim 4.30) id 1BSufl-0002Z6-46 for nfs@lists.sourceforge.ne=
t; Wed,
> 26 May 2004 02:26:05 -0700
>Received: from mx1.redhat.com ([66.187.233.31]) by	sc8-sf-mx1.sourceforg=
e.net
> with esmtp (TLSv1:AES256-SHA:256) (Exim 4.30)
> id	1BSufk-0003aV-K4 for nfs@lists.sourceforge.net; Wed,
> 26 May 2004 02:26:04 -0700
>Received: from int-mx1.corp.redhat.com
> (int-mx1.corp.redhat.com	[172.16.52.254]) by mx1.redhat.com (8.12.10/8.=
12.10)
> with ESMTP id	i4Q9Pui5015413; Wed, 26 May 2004 05:25:56 -0400
>Received: from RedHat.com (vpn64-5.boston.redhat.com [172.16.66.5])
> by	int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i4Q9Pu027362; =
Wed,
> 26 May 2004 05:25:56 -0400
>Date: Wed, 26 May 2004 05:25:55 -0400
>From: Steve Dickson <SteveD@redhat.com>
>Subject: Re: [NFS] Strange behavior of executable bit
>In-reply-to: <40B44FE7.6010601@byggmek.lth.se>
>Sender: nfs-admin@lists.sourceforge.net
>To: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
>Cc: nfs@lists.sourceforge.net
>Errors-to: nfs-admin@lists.sourceforge.net
>Message-id: <40B462A3.1070704@RedHat.com>
>MIME-version: 1.0
>Content-type: text/plain; charset=3DISO-8859-1; format=3Dflowed
>Content-transfer-encoding: 7BIT
>X-Accept-Language: en-us, en
>Precedence: bulk
>X-BeenThere: nfs@lists.sourceforge.net
>User-Agent: Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.6) Gecko/200401=
13
>X-Sieve: CMU Sieve 2.2
>X-Spam-Report: Spam Filtering performed by sourceforge.net. See
>	http://spamassassin.org/tag/ for more details. Report problems to
>	http://sf.net/tracker/?func=3Dadd&group_id=3D1&atid=3D200001
>X-Original-Date: Wed, 26 May 2004 05:25:55 -0400
>X-RedHat-Spam-Score: 0
>References: <40B44FE7.6010601@byggmek.lth.se>
>X-Mailman-Version: 2.0.9-sf.net
>List-Post: <mailto:nfs@lists.sourceforge.net>
>List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dsubscribe>
>List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
>	<mailto:nfs-request@lists.sourceforge.net?subject=3Dunsubscribe>
>List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=3Dnfs>
>List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=3Dhelp>
>List-Id: Discussion of NFS under Linux development, interoperability,
> and	testing. <nfs.lists.sourceforge.net>
>
>Jonas Lindemann wrote:
>
> =20
>
>>Running the following script:
>>
>>for i1 in 0 1 2 3 4 5 6 7 8 9 ; do
>>for i2 in 0 1 2 3 4 5 6 7 8 9 ; do
>>for i3 in 0 1 2 3 4 5 6 7 8 9 ; do
>>ls -l "$joboption_directory/test.sh" 1>&2
>>/bin/usleep 100000
>>done
>>done
>>done
>>
>>
>>Produce these results:
>>
>>And then it stabilizes.
>>   =20
>>
>
>I guess I'm  a bit confused... What are the expected results or
>what do you mean by "stabilizes"?
>
>SteveD.
>
>
>-------------------------------------------------------
>This SF.Net email is sponsored by: Oracle 10g
>Get certified on the hottest thing ever to hit the market... Oracle 10g.=
=20
>Take an Oracle 10g class now, and we'll give you the exam FREE.
>http://ads.osdn.com/?ad_id=3D3149&alloc_id=3D8166&op=3Dclick
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>
>--Boundary_(ID_zZIxsZfaTzLHkpJn4/X1uA)--
> =20
>




-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
