From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: Exportfs not showing exported file systems (was RE: stdio and
	nfs-utils)
Date: Thu, 26 Jul 2007 11:43:10 -0700
Message-ID: <01AE8AF878612047A442668306EAEB05D02161@SACEXMV01.hq.netapp.com>
References: <20070725223723.GH7943@fieldses.org><20070726000700.GK7943@fieldses.org><18088.3581.647761.879253@notabene.brown>
	<20070726031755.GB19901@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE8Iy-0006ex-6i
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 11:43:20 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IE8J0-0007kC-Sg
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 11:43:24 -0700
In-Reply-To: <20070726031755.GB19901@fieldses.org>
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

Could all this be related to a problem that we've been seeing while
working on v4/4.1 at netapp, where exportfs doesn't show any output even
when there are exported file systems?  Ricardo recently observed that if
you redirect the output of 'exportfs' then you actually do get the
correct output (e.g., exportfs > afile, or exportfs | more).  This lead
to some experiments with strace that show exportfs behaving differently
when its output is going to a tty.  We've seen this behavior across a
variety of kernels (2.6.18-2.6.20) and a variety of nfs-utils
(prepackaged with FC6, RHEL4/5, and built from a local copy of 1.0.12).

N.B. no output from the first exportfs, but correct output when piped to
'more':

[root@teal ~]# exportfs -a
[root@teal ~]# exportfs
[root@teal ~]# exportfs | more
/               <world>


Now looking at straces with and without redirect:

[root@teal ~]# strace exportfs 2> exportfs.noredirect
[root@teal ~]# strace exportfs | more 2> exportfs.redirect


In the 'no redirection' case, there's an ioctl that fails, and the
output never appears in the xterm window (assuming that's related to the
ioctl failure the returns ENOTTY).  N.B., we see the 'write' system call
in the strace, but don't see any output from that call. From
exportfs.noredirect:

ioctl(1, SNDCTL_TMR_TIMEBASE or TCGETS, 0xbf8aabc8) = -1 ENOTTY
(Inappropriate ioctl for device)
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1,
0) = 0xb7fba000
write(1, "/             \t<world>\n", 23) = 23
exit_group(0)                           = ?


In the case of redirection, we don't do the ioctl, and you can see the
'write' of the exportfs output in the strace as well as the result of
the 'write'.  From exportfs.redirect:

fstat64(1, {st_mode=S_IFIFO|0600, st_size=0, ...}) = 0 mmap2(NULL, 4096,
PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb7f8e000
write(1, "/             \t<world>\n", 23) = 23
exit_group(0)                           = ?
/               <world>
Process 8408 detached 

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Wednesday, July 25, 2007 8:18 PM
To: Neil Brown
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] stdio and nfs-utils

On Thu, Jul 26, 2007 at 12:59:09PM +1000, Neil Brown wrote:
> While I can see the value it avoiding the stdio code, I can also see 
> some in hanging on to it, so I would first like to see if we can make 
> the current code work with just minor modifications.
> 
> Could you check how calling 'clearerr' interacts with this code on the

> two different systems?

I tried inserting a clearerr into the loop:

	fprintf();
	fflush();
	clearerr();

No change in behavior.

I see the advantage to doing just one step at a time--so if we can
figure out a minimal fix for now, fine.  But surely we've got to replace
the stdio stuff at some point.  We need precise control over the writes,
so the buffering can only get in the way.

--b.

------------------------------------------------------------------------
-
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
