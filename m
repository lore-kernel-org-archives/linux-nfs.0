From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RedHat 8.0 nfs
Date: Thu, 20 Mar 2003 15:28:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E7A2454.7070003@RedHat.com>
References: <D38AFB3080F3D311807300B0D0203E53033A94CB@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nat-pool-rdu.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18w6XL-00087S-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Mar 2003 12:21:15 -0800
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.9.3) with ESMTP id h2KKL7o09419
	for <nfs@lists.sourceforge.net>; Thu, 20 Mar 2003 15:21:08 -0500
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



pwitting@Cyveillance.com wrote

>So what guidelines should I use in setting these values? RH 7.3 limited me
>to 128 threads (I got nervous using ALL the possible threads and backed it
>off), RH8 supports more. Judging by the /proc, there is a significant amount
>of time where all threads are in use, even at 120
>
Not knowing anything about the size of your machines, the type of
traffic, your network, or the history of what works and what doesn't
makes it  tough to give a decisive answer... So I can only suggest
crank it up until it hurts. :-) Theoretically RH8.0 can support up to 32000
processes and 1200 threaded processes, so its all dependent on the size
of your machine (i.e. number of cpus, amount of memory, type of storage)
Experimentation is your friend...

>
>Also, what would be a good number for NFS_QS? Both rmem.default and rmem.max
>will be set to this number; should it be a multiple of threads? Say
>something like smallest binary power (2^n) greater than 1500 (MTU size) *
>$RPCNFSDCOUNT 
>
>So 120*1500 = 180,000 > 262,144, but
>   220*1500 = 330,000 > 524,288
>  
>
Again this dependent on how much memory you have...

>Or should RPCNFSDCOUNT itself be some power of 2?
>
I don't think it matters or at least I don't see why it should...

>
>And while we're on the subject of RedHat, any idea how up to date the NFS
>code is in their latest kernel (2.4.18-27)? Its nice relying on their bug
>testing/security/useful_patches/fixes, but I saw a significant performance
>increase by migrating to 2.4.20 a few months ago. I also ran into a wall
>trying to integrate the Q-Logic FC drivers I need for some of my systems.
>  
>
Unfortunately, we not able to get in some of latest performance 
enhancements
due to our QA cycle...

SteveD.





-------------------------------------------------------
This SF.net email is sponsored by: Tablet PC.  
Does your code think in ink? You could win a Tablet PC. 
Get a free Tablet PC hat just for playing. What are you waiting for? 
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
