From: gb <bakerg3@yahoo.com>
Subject: NFS lockups/hangs on RHEL64 U4 ?
Date: Mon, 24 Jan 2005 14:34:40 -0800 (PST)
Message-ID: <20050124223440.77165.qmail@web41301.mail.yahoo.com>
Reply-To: greg@bakers.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CtCnM-0003jO-Pu
	for nfs@lists.sourceforge.net; Mon, 24 Jan 2005 14:34:52 -0800
Received: from web41301.mail.yahoo.com ([66.218.93.186])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1CtCnK-0006kD-DI
	for nfs@lists.sourceforge.net; Mon, 24 Jan 2005 14:34:52 -0800
To: nfs@lists.sourceforge.net
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


All,

Apologies in advance if this forward is viewed as
uncouth; I wanted to ask the folks here if they have
had any experience, or have seen the NFS problem
described below (well, linked to below may be a better
explanation...)

The showTasks output lists multiple deadlocked tasks
with a Call Trace in the following condition:

(from the sif029.strings included on the Bugzilla
page)

Call Trace:
[<ffffffffa00c6024>]{:nfs:nfs_complete_unlink+308} 

Call Trace: [<ffffffffa00d39c0>]{:nfs:nfs_sops+0}
[<ffffffffa00d3d00>]{:nfs:nfs_fs_type+0} 

Ideas?  Suggestions?  I've also opened a ticket with
internal Redhat support to see if they have any
hypothesis.

Thanks,

--Greg 

>
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=145550
> 
>            Summary: NFS lockups/hangs on RHEL3
> x86_64 U4
>            Product: Red Hat Enterprise Linux
>            Version: 3
>           Platform: x86_64
>         OS/Version: Linux
> 
> 
> Description of problem:
> 
> We have a group of 10 systems to distribute builds
> (gcc).  When these
> systems are under heavy load, the builds (make
> process) hang in a
> blocked, deadlocked state.
> 
> The NFS servers do not show excessive load or any
> problems.
> 
> NFS gcc source: NetApp Release 6.4.5P2
> NFS build source: NetApp Release 6.5.2R1P9:
> 
> The 10 build clients are exactly the same hardware
> and configuration.
>  I'll be attaching the following from a system that
> is exhibiting this
> behavior:
> 
> # lspci -vv
> # lsmod
> # cat /proc/meminfo
> # cat /proc/cpuinfo
> # uname -a
> 
> And as much as I can capture from the console as
> possible.
> 
> Unfortunately, we cannot recreate the hang
> on-demand.
> 
> Please let me know if there is any other information
> I can provide
> that would be helpful. 
> 
> Version-Release number of selected component (if
> applicable):
> 
> Redhat Enterprise Linux 3 Update 4 x86_64


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
