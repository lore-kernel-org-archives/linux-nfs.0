From: pwitting@Cyveillance.com
Subject: Re: Typo in Redhat 8/9 nfs start/stop script
Date: Mon, 23 Jun 2003 13:55:44 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A9622@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Cc: SteveD@RedHat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.26] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UVXt-00064H-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 10:56:01 -0700
To: nfs@lists.sourceforge.net
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

Steve D.,

You may want to do more than that. RH9 is using 2.4.20 kernel, which by my
understanding resets the values to what I thinks is reasonable. For details
on how 2.4.20 calculates queue sizes, see this earlier post by Neil Brown:

http://sourceforge.net/mailarchive/message.php?msg_id=4229482

But the gist is, there is no longer any need for the startup script to reset
these values unless RH has disabled this feature of the kernel nfs code. 

Secondly, it might be wise to automatically install a /etc/sysconfig/nfs
file. The script reads this file, but there's no default included, only be
reading and understanding the script would a user find out that this is now
the preferred way to change the thread count.

Finally, why not release an erratum that corrects the problem instead of
forcing any upgrade to RH10? It would be nice if I didn't have to add
functions to my Kickstart post-install script to correct this problem, and
instead could just upgrade the RPM in my install directory.

Thanks,

>Date: Sat, 21 Jun 2003 08:51:32 -0400
>From: Steve Dickson <SteveD@RedHat.com>
>
>This is fixed in the next release...
>
>SteveD.
>
>Matt Schillinger wrote:
>
>>Note for any Redhat users that need higher than default input queues for
>>NFS.
>>
>>
>># Get the initial values for the input sock queues
>># at the time of running the script.
>>if [ "$TUNE_QUEUE" = "yes" ]; then
>>    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
>>    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
>>    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
>>    [ -z "$NFS_QS" ] && NFS_QS=262144
>>fi
>>
>># See how we were called.
>>case "$1" in
>>  start)
>>        # Start daemons.
>>        # Apply input queue increase for nfs server
>>        if [ "$TUNE_QUEUE" = "yes" ]; then
>>            /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null
>>2>&1
>>            /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
>>        fi
>>
>>
>>
>>NOTE THAT when checking that the variable has a value and setting the
>>variable, NFS_QS is used. But when setting the input queues, $NFSD_QS is
>>used.



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
