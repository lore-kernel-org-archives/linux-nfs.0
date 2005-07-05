From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Re: time after which statd gives up
Date: Tue, 5 Jul 2005 07:41:03 -0700 (PDT)
Message-ID: <20050705144103.58968.qmail@web51613.mail.yahoo.com>
References: <42CA91E3.5070900@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DpocE-0000Vc-T0
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 07:41:38 -0700
Received: from web51613.mail.yahoo.com ([68.142.224.86])
	by sc8-sf-mx2-new.sourceforge.net with smtp (Exim 4.44)
	id 1Dpobl-0007nn-Ke
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 07:41:39 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <42CA91E3.5070900@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
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

Hi Steve ,=20
 These are the messages on server side.
 Shouldnt statd mv file from sm to sm.bak
 if its not able to notify client and later
 try to notify client(files in sm.bak) with
 low frequency.

[root@vcslinux5 tmp]# uname -a
Linux vcslinux5.vxindia.veritas.com 2.6.9-6.37.ELsmp
#1 SMP Tue Mar 29 15:43:19
EST 2005 i686 i686 i386 GNU/Linux




[root@vcslinux5 ~]# rpc.statd -d -F
07/05/2005 20:03:10 rpc.statd[26896]: Version 1.0.6
Starting
07/05/2005 20:03:10 rpc.statd[26896]: Flags: No-Daemon
Log-STDERR
07/05/2005 20:03:10 rpc.statd[26896]: New state: 93
07/05/2005 20:03:10 rpc.statd[26896]: Waiting for
reply... (timeo 5)
07/05/2005 20:03:16 rpc.statd[26896]: Waiting for
reply... (timeo 5)
07/05/2005 20:03:20 rpc.statd[26896]: Waiting for
reply... (timeo 1)
07/05/2005 20:03:22 rpc.statd[26896]: Waiting for
reply... (timeo 5)
07/05/2005 20:03:26 rpc.statd[26896]: Waiting for
reply... (timeo 1)
07/05/2005 20:03:28 rpc.statd[26896]: Waiting for
reply... (timeo 5)
07/05/2005 20:03:34 rpc.statd[26896]: Waiting for
reply... (timeo 5)
07/05/2005 20:03:38 rpc.statd[26896]: Waiting for
reply... (timeo 1)
07/05/2005 20:03:40 rpc.statd[26896]: Cannot notify
10.212.99.95, giving up.

07/05/2005 20:03:40 rpc.statd[26896]: Can't notify
10.212.99.95, giving up.
07/05/2005 20:03:40 rpc.statd[26896]: Unlinked
/var/lib/nfs/statd/sm.bak/10.212.99.95
07/05/2005 20:03:40 rpc.statd[26896]: Waiting for
client connections.
07/05/2005 20:03:44 rpc.statd[26896]: Caught signal 2,
un-registering and exitin

thanks,
 kiran

--- Steve Dickson <SteveD@redhat.com> wrote:

> mehta kiran wrote:
> > Hi ,=20
> >       On RHEL4 U1 i have observed that statd
> >       sends notification only till the=20
> >       max(if cannot notify) time 30 seconds.
> To be clear, you saying when rpc.statd is started
> it sends out SM_NOTIFY messages notifying the
> clients
> this machine just rebooted and it seems to do this
> for
> 30 seconds?
>=20
> >=20
> >       Is this the expected behavior ?
> Again not knowing the type of message you seeing,
> its
> hard to tell...
>=20
> steved.
>=20
>=20
>
-------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux
> Migration Strategies
> from IBM. Find simple to follow Roadmaps,
> straightforward articles,
> informative Webcasts and more! Get everything you
> need to get up to
> speed, fast.
>
http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclick
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20



	=09
____________________________________________________=20
Yahoo! Sports=20
Rekindle the Rivalries. Sign up for Fantasy Football=20
http://football.fantasysports.yahoo.com


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
