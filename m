From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: Re: exportfs operations hang
Date: 18 Jun 2003 11:47:46 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055954867.13314.8.camel@mosix>
References: <1055879177.10166.3.camel@mosix>  <3EEF914A.8030000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Sg5u-0002jZ-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 09:47:34 -0700
To: Steve Dickson <SteveD@RedHat.com>
In-Reply-To: <3EEF914A.8030000@RedHat.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 2003-06-17 at 17:08, Steve Dickson wrote:
> Here does strace say its hanging?
> 
> SteveD.

Duh! No I haven't.. I will do that when issues occur again.. However, I
may or may not have found the problem..

A few new things that I've found.

rpc.mountd is not displaying any syslog entries when hangs occur on
clients.. the client gets 'Permission Denied' when trying to mount (via
automount). Other clients are accessing the mounts just fine.. 

I found that there is a -o or --descriptor option for file descriptors,
which the default operation is 256 file descriptors. This got me
thinking about how many file descriptors that I should have.. I couldn't
find anything about tuning file descriptors for rpc.mountd. Could
someone give me a guideline or idea?

I went ahead and bumped the file descriptors up to 512 for good measure.
( this required a kill of the current rpc.mountd and restart of it.)
After the restart, the clients that were getting 'Permission Denied',
were able to access the mounts. I do not know yet if the restart fixed
the problem, or the increased file descriptors, or both.

I would really like to know what the recommended file descriptor number
should be.

Default is 256, but the default nfsd threads is 8. 
I am running 64 threads, with an Input Queue of 2097152

Should rpc.mountd file descriptors move up in relation to number of
threads?

Thanks for your help,

Matt Schillinger
mschilli@vss.fsi.com
> 
> Matt Schillinger wrote:
> 
> >Hello,
> >
> >I am having reproducible problems with exportfs.
> >
> >When I try to run exportfs or exportfs -u, it simply stalls and never
> >drops back to commandline.. if i CTRL+C, i see that (in the case of an
> >exportfs) the mountpoint is still not shared. In the case of an exportfs
> >-u, If i CTRL+C it, the mountpoint IS still shared.  I do not know what
> >is causing the problem.. the only workaround that I have found is to
> >restart nfsd.. Is there something in rmtab/xtab/etab that could cause an
> >exportfs hangup?
> >
> >I am using 64 threads, and am having no thread utilization issues
> >according to /proc/net/rpc/nfsd
> >
> >Has anyone else had this problem?
> >
> >Thanks for your help
> >  
> >
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
