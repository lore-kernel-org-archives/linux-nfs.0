From: pwitting@Cyveillance.com
Subject: RE: Typo in Redhat 8/9 nfs start/stop script
Date: Fri, 20 Jun 2003 10:39:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <D38AFB3080F3D311807300B0D0203E53033A9619@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Cc: mschilli@vss.fsi.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.100.163.26] (helo=mercury.cyveillance.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TNKL-0006Vl-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 07:57:21 -0700
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


I would recommend 2.4.20 if you can. I have seen a 15-20% increase when I
migrated to 2.4.20. Granted that increase is likely from the kernel's better
handling of the queues, it was running RH 7.3 whose nfs script did not
modify queue sizes. (I was working to get nfs stable on a jfs filesystem.
Its very stable now with the latest code). I had a nightly script that
copied a large (20-40GB file from an AIX box to Linux, I had the script mail
me the results and calculate the kbps of the transfer, so I'm confident of
that increase.

Anyway, for details on how 2.4.20 calculates queue sizes, see this earlier
post by Neil Brown:

http://sourceforge.net/mailarchive/message.php?msg_id=4229482

for pre-2.4.20 kernels, see this post (also by Neil Brown)

http://sourceforge.net/mailarchive/message.php?msg_id=4221019

The gist of which is that QS is on a per socket level. I took this to mean
that each incoming connection got its own QS, but on re-reading I'm not so
sure. And unfortunately, the box that still has a 2.4.18 kernel (storage in
on a SAN, so I like RedHat's kernels with Qlogic drivers merged) doesn't
have convient performance metrics being mailed out every day and is in
production. But here's my thread utilization:

th 220 43091 25453.472 5411.218 2381.306 1093.449 641.435 1678.058 327.580
115.388 82.265 102.480

So I'm getting good use out of those 220 threads :^)

>From: Matt Schillinger <mschilli@vss.fsi.com>
>Date: 20 Jun 2003 08:37:49 -0500
>
>A couple of things.. If i'm reading your /etc/sysconfig/nfs right, you
>are using 120 threads, with a 256K input queue.. Is this correct? I
>thought that the goal was to allow 32K per thread. Is this not the case?
>My understanding was that 256K input queue was to increase NFSD write
>performance for 8 threads (the default), and that the input queue should
>scale with the number of threads. Is this incorrect?
>
>Also, 2.4.20.. would it be better for me to use that as opposed to
>2.4.19? I use a vanilla kernel with an NFSD patch that creates a
>workaround for an IRIX < 6.5.13 CWD bug.  If it is recommended to go to
>2.4.20, does anyone know if that patch is available for 2.4.20?
>Actually, I've forgotten my source for that patch, so if anyone knows
>the address, i'd greatly appreciate recieving that info.
>
>
>Thanks,
>
>Matt Schillinger
>mschilli@vss.fsi.com
>
>On Thu, 2003-06-19 at 15:50, pwitting@Cyveillance.com wrote:
>> Good catch. I went over these scripts a while ago and missed this. I did
>> find that they are now referencing /etc/sysconfig/nfs for variables, so I
>> set one up:
>>
>> /etc/sysconfig/nfs
>>
>> # Referenced by Red Hat 8.0 nfs script to set initial values
>> #
>> # Number of threads start.
>> RPCNFSDCOUNT=120
>>
>> # yes, no, or auto (attempts to auto-detect support)
>> MOUNTD_NFS_V2=auto
>> MOUNTD_NFS_V3=auto
>>
>> # Should we tune TCP/IP settings for nfs (consumes RAM)
>> TUNE_QUEUE=yes
>> # 256kb recommended minimum size based on SPECsfs NFS benchmarks
>> # default values:
>> #       net.core.rmem_default    65535
>> #       net.core.rmem_max       131071
>> NFS_QS=262144
>>
>> ===
>>
>> Note that since RedHat 9 uses 2.4.20 this should no longer matter, as nfs
>> now determines its own values for queue size on startup as of 2.4.20,
>> ignoring whatever values are there.
>>
>> >From: Matt Schillinger <mschilli@vss.fsi.com>
>> >Date: 19 Jun 2003 14:27:44 -0500
>> >
>> >Note for any Redhat users that need higher than default input queues for
>> >NFS.
>> >
>> >
>> ># Get the initial values for the input sock queues
>> ># at the time of running the script.
>> >if [ "$TUNE_QUEUE" = "yes" ]; then
>> >    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
>> >    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
>> >    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
>> >    [ -z "$NFS_QS" ] && NFS_QS=262144
>> >fi
>> >
>> ># See how we were called.
>> >case "$1" in
>> >  start)
>> >        # Start daemons.
>> >        # Apply input queue increase for nfs server
>> >        if [ "$TUNE_QUEUE" = "yes" ]; then
>> >            /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null
>> >2>&1
>> >            /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
>> >        fi
>> >
>> >
>> >
>> >NOTE THAT when checking that the variable has a value and setting the
>> >variable, NFS_QS is used. But when setting the input queues, $NFSD_QS is
>> >used.
>> >
>> >
>> >--
>> >Matt Schillinger
>> >
>> >mschilli@vss.fsi.com



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
