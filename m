From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] Fix xprt_bindresvport
Date: Sun, 17 Jul 2005 07:36:38 -0400
Message-ID: <42DA42C6.1020005@RedHat.com>
References: <20050711092556.GD27163@suse.de> <42D68C0B.9000106@RedHat.com> <20050716071144.GA7451@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Du7Ry-00062G-R8
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 04:36:50 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Du7Ry-0007rA-E3
	for nfs@lists.sourceforge.net; Sun, 17 Jul 2005 04:36:50 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050716071144.GA7451@suse.de>
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

Olaf Kirch wrote:
> On Thu, Jul 14, 2005 at 12:00:11PM -0400, Steve Dickson wrote:
> 
>>Question, why is 65535 one being used here instead of something
>>like 1023 (or PROT_SOCK-1)? Since since inet_bind() will only
>>succeed with a source ports that are less than PROT_SOCK, so it
>>may not make sense to allow the user to set the max reserver port
>>to a value greater than PROT_SOCK-1, true?
> 
> 
> I don't understand. Of course you can bind to any socket up to 65535,
> not just 1023.
Understood... but ports > 1023 are not considered privileged and
connections that are not using privilege ports will not be accepted
by a number of RPC daemon..

> And in an environment where the admin doesn't care for privileged
> vs unprivileged ports, it's good to give him the choice of allowing
> the kernel to bind to any port.
If such an environment exists, then I agree... but I don't think this
is the norm... I'm pretty sure a lot of RPC daemons check for
privileged port by default... Something I don't think admits can
turn off...

Don't get me wrong, I really like the idea of being able to define
the range of privileged ports the kernel can use (I think it will be
very handy), but by definition a privileged port is between 1 and 1023
and by setting the max port to 1023 we would be maintaining that
definition...

steved.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
