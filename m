From: Steve Dickson <SteveD@redhat.com>
Subject: Re: statd simplified
Date: Mon, 02 Feb 2004 12:56:59 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <401E8F6B.5040400@RedHat.com>
References: <20040202140851.GH3145@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-list1-b.sourceforge.net ([10.3.1.7] helo=sc8-sf-list1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Anibw-00064k-Ed
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 10:15:52 -0800
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 4.30)
	id 1AniJn-0007n0-NU
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 09:57:07 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AniJm-0004qj-UN
	for nfs@lists.sourceforge.net; Mon, 02 Feb 2004 09:57:07 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id i12Hv0b05430
	for <nfs@lists.sourceforge.net>; Mon, 2 Feb 2004 12:57:00 -0500
Received: from RedHat.com (vpn64-3.boston.redhat.com [172.16.66.3])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id i12Huxa26279
	for <nfs@lists.sourceforge.net>; Mon, 2 Feb 2004 12:56:59 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20040202140851.GH3145@suse.de>
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

>So I sat down last week and dusted off some old ideas how to simplify
>NLM/NSM interaction quite a bit.
>  
>
Putting statd in the kernel I think  a good idea... Probably the only
reason it has not been done, is the fact, managing the state file from
the kernel is a real pain...

>The approach I implemented was to get rid of all the SM_MON/SM_UNMON
>calls completely. If lockd wants a remote host to be "monitored", simply
>add it's IP address to /var/lib/nfs/sm. This used to be statd's job,
>but there's no reason why we cannot do that in the kernel.
>  
>
Letting /var/lib/nfs/sm grow uncontrollably (i.e. not using SM_UNMON to
clean it up) may not be a good idea... Since users can't go in and clean 
in up by hand
(since they could be removing live state), there probably should be some
way to cleaned up (and up to date)

>In addition, lockd now understands a very limited subset of NSM
>procedures: NULL, and SM_NOTIFY. If it receives an SM_NOTIFY message,
>it initiated reclaim for all locks we hold on that server (if any)
>and ditch all locks this client holds on our box (if any).
>
>(As a special bonus, the new code actually initializes nsm_local_state
>from /var/lib/nfs/state, which we previously didn't).
>  
>
Currently when statd can not open the state file (in change_state()),  
it dies
which in turn causes lock requests to fail because that can't be monitored.
In your kernel implementation, this failure seems to be ignored.  Since
the failure would probably do to the sm directory not existing,  which
also means state file will not able to be created,  it might make sense
to fail the loading of lockd when this happens.

Also I notice that the new nsm_monitor() will only fail with ENOMEM,
regardless if it was able to save state... If it can not save state, 
shouldn't it fail?

SteveD.




-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
