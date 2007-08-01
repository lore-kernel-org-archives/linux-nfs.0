From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/7] nfsstat: adding -D/--diff-stat to nfsstat
Date: Wed, 01 Aug 2007 15:35:48 -0400
Message-ID: <46B0E094.2080109@oracle.com>
References: <Pine.BSO.4.64.0707311651120.13370@citi.umich.edu>	<46B074A2.4010909@redhat.com>	<Pine.BSO.4.64.0708011149240.25204@citi.umich.edu>	<46B0C92C.3020807@redhat.com>	<Pine.BSO.4.64.0708011413000.25204@citi.umich.edu>
	<46B0CF5B.1000609@redhat.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020508080508020908080702"
Cc: Neil Brown <neilb@suse.de>, Peter Staubach <staubach@redhat.com>,
	Andrew Richardson <chardson@umich.edu>, Alex Soule <soule@umich.edu>,
	"david m. richter" <richterd@citi.umich.edu>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGK0z-0002T6-GO
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 12:37:50 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IGK11-0004jC-4O
	for nfs@lists.sourceforge.net; Wed, 01 Aug 2007 12:37:53 -0700
In-Reply-To: <46B0CF5B.1000609@redhat.com>
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

This is a multi-part message in MIME format.
--------------020508080508020908080702
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Peter Staubach wrote:
> david m. richter wrote:
>>> Now, if someone was proposing a way to do "nfsstat 5" and make the
>>> output look useful, then I would be behind that 100%.
>>>
>>>    Thanx...
>>>
>>>       ps
>>>     
>>
>> 	do you mean "gather stats for the next 5 seconds"?  i don't 
>> understand the arg.
> 
> Sorry, I should have been more explicit.  I have wished for
> something that would behave like "vmstat 5", ie. print nfsstat
> statistics in some sort short hand fashion once every few
> seconds, 5 in this example.
> 
> The problem has always been that there are too many operations
> for summarize them on one line in any sort of interesting way.
> This becomes particularly true for NFSv4 which has its multitude
> of operations...
> 
> Perhaps we should just bite the bullet and produce the large
> output, much like "iostat 5" seems to.

First, thanks to David and the citi guys for the patches.

The kernel stats themselves should never be zeroed except by umount or 
reboot.  Otherwise, tools like "sar" and "iostat" that are looking 
directly at the same set of kernel stats, and producing a "one every 5 
seconds" type of output, would be totally confused if "nfsstat -z" 
actually cleared the kernel counters.

There's a bigger picture here.  nfsstat does not live in a vacuum, it 
lives in the presence of all the other I/O tools like sar, vmstat, and 
iostat.  For that matter, we already have "watch nfsstat" and 
"nfswatch".  Those tools already provide a "once every 5 seconds" type 
of interface.  I might even be inclined to argue that adding "once every 
5 seconds" type functionality is really outside of nfsstat's job 
description.

So if we wanted an "nfsstat --since" or "nfsstat 5 5" kind of thing, 
maybe we should think about the other tools, how they fit in, and how 
they work, and see if we can use one of them for that.  Even better, a 
GUI like gnome-system-monitor would be very nice for watching NFS client 
and server performance in real time.

I'm kind of tired of NFS living in its own little world with regard to 
the other file systems.  The NFS performance metrics I built were 
precisely for the purpose of making NFS a "first class" file system with 
regard to reporting errors and performance, and for the purpose of 
including NFS in the tools sysadmins normally use to watch I/O subsystem 
  performance data on local disks.

Can we come up with a plan that moves NFS closer to other file systems?

--------------020508080508020908080702
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel
version:2.1
end:vcard


--------------020508080508020908080702
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--------------020508080508020908080702
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------020508080508020908080702--
