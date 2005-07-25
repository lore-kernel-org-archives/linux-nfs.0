From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS in kernel 2.6 and Netapp: privileged ports problem
Date: Mon, 25 Jul 2005 03:03:19 -0400
Message-ID: <42E48EB7.60400@RedHat.com>
References: <20050721100913.D93F.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dwwzt-0001Ut-TB
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 00:03:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dwwzt-0000SH-HS
	for nfs@lists.sourceforge.net; Mon, 25 Jul 2005 00:03:33 -0700
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050721100913.D93F.BRANDEN@terra.com.br>
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

Filipe Brandenburger wrote:
> I'm having problems when mounting NFS in a Netapp FAS 740 filer on a
> Linux RHAS4 Kernel 2.6 client. The message I get is:
> 
> [root@talara ~]# mount -a
> mount: RPC: Authentication error; why = Client credential too weak
Your running out of privileged ports....

The problem is the glibc pmap_getport() routine uses
privileged ports to get ports from portmapper (when TCP
is specified) which is wrong. So these ports end up in
TIME_WAIT, which makes them (temporary) unusable for mounts.
(Do a netstat -an | grep TIME_WAIT and notice all the ports are < 1024).
Now, when a privileged port is not available, a normal port (i.e. >
1023) will be used which will cause the above message.

Note: the glibc is fixed in FC4 and in upcoming RHEL3 and RHEL4
releases.

> Sometimes it works, most times it fails with the message above. If I use
> the same setup above but with RH7.3 Kernel 2.4, it works without a
> problem.
This is because UDP is the default protocol for mounts where as with
later releases TCP is the default.

> 
> So I ask:
> 
> - Anyone experienced this too?
Yes... see https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=154678

> - Is there a way on kernel 2.6 to force it to use privileged ports to do
> the mount?
I don't think so...

> - This one is not related to Linux, but anyone knows if it's possible to
> disable the privileged port restriction on the Netapp filer? This would
> be acceptable to me to solve this problem.
You could try adding 'insecure' to your exports options... and
you could also try using UDP mounts by specifying the '-o udp'
mount option.

steved.




-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
