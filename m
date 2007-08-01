From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 16:16:13 -0400
Message-ID: <46B0EA0D.1080100@RedHat.com>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>	<46B074A2.4010909@redhat.com>	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>	<46B0C92C.3020807@redhat.com>	<Pine.BSO.4.64.0708011413000.25204@citi.umich.edu>	<46B0CF5B.1000609@redhat.com>
	<46B0E094.2080109@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGKc8-0006bi-Ud
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 13:16:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGKcC-0003om-Hp
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 13:16:16 -0700
In-Reply-To: <46B0E094.2080109@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Chuck Lever wrote:

> The kernel stats themselves should never be zeroed except by umount or 
> reboot.  Otherwise, tools like "sar" and "iostat" that are looking 
> directly at the same set of kernel stats, and producing a "one every 5 
> seconds" type of output, would be totally confused if "nfsstat -z" 
> actually cleared the kernel counters.
In general, I agree. Stats that "sar" and "iostat" see should
not be zeroed.. but the nfsstat's stats do not fall in this
category. They are more like counters than true statistics.
I think if they were call nfscounts instead of nfsstats
there would be less of an uproar since reseting counter
is no big deal...

So in the end.. these counter are used to show nfs activity
for the entire box... so being able to zero them would
incredibly handy for developers and customers alike...


> 
> So if we wanted an "nfsstat --since" or "nfsstat 5 5" kind of thing, 
> maybe we should think about the other tools, how they fit in, and how 
> they work, and see if we can use one of them for that.  Even better, a 
> GUI like gnome-system-monitor would be very nice for watching NFS client 
> and server performance in real time.
> 
> I'm kind of tired of NFS living in its own little world with regard to 
> the other file systems.  The NFS performance metrics I built were 
> precisely for the purpose of making NFS a "first class" file system with 
> regard to reporting errors and performance, and for the purpose of 
> including NFS in the tools sysadmins normally use to watch I/O subsystem 
>  performance data on local disks.
> 
> Can we come up with a plan that moves NFS closer to other file systems?
Yeah... lets build a tool that understand the stats in
/proc/self/mountstats and continue build there... because imho,
thats where the future lies with regard to understanding and
analyzing NFS traffic patterns...

steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
