From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RH8.0 nfs server, client RPC time_time_out issues
Date: Fri, 14 Feb 2003 16:32:30 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E4D606E.6000308@RedHat.com>
References: <OF24B722A7.F9405887-ON88256CCA.005ABDD0-88256CCA.005D624F@nb.jazzsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jnMi-00069s-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 13:27:24 -0800
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h1ELRHH14659
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 16:27:17 -0500
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

Hi,

Make sure there are not errors on the
network interface with 'ifconfig eth?'.

Also see what nfsstat -s says. See if your getting
badcalls or bad[whatever]....

I there anything interesting in /var/log/messages?
also ethereal (tethereal) will show any otw issues...

I hope this helps....

SteveD.

alexander.liu@jazzsemi.com wrote:

>
> Hello,
>
> We are having issues with our nfs server based on Redhat 8.0.
> It seen that every other day or so, our nfs clients which are HPUX 
> 10.20 and Tru64 4.0D and Solaris 8 will not be able to access the server.
> Linux clients do not have any problems.
>
> Client error messages include:
>
> HPUX -    automount[621]: xx_fs:/raid/auto/home/rt_util server not 
> responding: RPC_TIMED_OUT
> TRU64 -  vmunix: NFS2 server not responding still trying
> Solaris 8 - automountd[163]: [ID 748625 daemon.error] xx_fs server not 
> responding: RPC_TIMED_OUT
>
> The server appears to be fine.
>
> I have searched the archives for RPC timeout errors and have 
> implemented some of the suggestions such as:
> Making sure the server name is in DNS and the local host table for 
> reverse and forward resolution.
>
> However, the problem continues.
>
> Problem resolution currently means stopping and restarting NFS on the 
> server.
>
> Has anyone experience similar problems, am I overlooking something 
> obvious, any suggestion on what I should look at next.
>
> Thanks,
>
> Alex Liu 





-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
