From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: exportfs operations hang
Date: Tue, 17 Jun 2003 18:08:10 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EEF914A.8030000@RedHat.com>
References: <1055879177.10166.3.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SOcs-0004iM-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 15:08:26 -0700
To: Matt Schillinger <mschilli@vss.fsi.com>
In-Reply-To: <1055879177.10166.3.camel@mosix>
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

Here does strace say its hanging?

SteveD.

Matt Schillinger wrote:

>Hello,
>
>I am having reproducible problems with exportfs.
>
>When I try to run exportfs or exportfs -u, it simply stalls and never
>drops back to commandline.. if i CTRL+C, i see that (in the case of an
>exportfs) the mountpoint is still not shared. In the case of an exportfs
>-u, If i CTRL+C it, the mountpoint IS still shared.  I do not know what
>is causing the problem.. the only workaround that I have found is to
>restart nfsd.. Is there something in rmtab/xtab/etab that could cause an
>exportfs hangup?
>
>I am using 64 threads, and am having no thread utilization issues
>according to /proc/net/rpc/nfsd
>
>Has anyone else had this problem?
>
>Thanks for your help
>  
>



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
