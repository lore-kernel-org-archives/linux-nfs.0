From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: Typo in Redhat 8/9 nfs start/stop script
Date: Sat, 21 Jun 2003 08:51:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF454D4.3010406@RedHat.com>
References: <1056050865.15737.282.camel@mosix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ThqO-00007h-00
	for <nfs@lists.sourceforge.net>; Sat, 21 Jun 2003 05:51:48 -0700
To: Matt Schillinger <mschilli@vss.fsi.com>
In-Reply-To: <1056050865.15737.282.camel@mosix>
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

This is fixed in the next release...

SteveD.

Matt Schillinger wrote:

>Note for any Redhat users that need higher than default input queues for
>NFS.
>
>
># Get the initial values for the input sock queues
># at the time of running the script.
>if [ "$TUNE_QUEUE" = "yes" ]; then
>    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
>    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
>    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
>    [ -z "$NFS_QS" ] && NFS_QS=262144
>fi
>
># See how we were called.
>case "$1" in
>  start)
>        # Start daemons.
>        # Apply input queue increase for nfs server
>        if [ "$TUNE_QUEUE" = "yes" ]; then
>            /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null
>2>&1
>            /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
>        fi
>
>
>
>NOTE THAT when checking that the variable has a value and setting the
>variable, NFS_QS is used. But when setting the input queues, $NFSD_QS is
>used.
>
>
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
