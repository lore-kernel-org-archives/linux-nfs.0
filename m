From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Thu, 13 Jan 2005 19:57:24 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501131952140.11608@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com> <16164.29864.268358.781865@gargle.gargle.HOWL>
 <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <16871.11926.507904.373575@cse.unsw.edu.au>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpHeU-0006gJ-K8
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 18:57:30 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpHeS-0006vM-U0
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 18:57:30 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16871.11926.507904.373575@cse.unsw.edu.au>
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

On Fri, 14 Jan 2005, Neil Brown wrote:

> On Thursday January 13, Ara.T.Howard@noaa.gov wrote:
>>
>> i am seeing problems here on my system (which has rebooted and now has stale
>> locks on server)
>>
> ..
>>    server:
>>
>>      mussel:~ > rpcinfo -u bligh status
>>      rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
>>      program 100024 is not available
> ...
>>
>>    client:
>>
>>      bligh:~ > rpcinfo -p
>>         program vers proto   port
>>          100000    2   tcp    111  portmapper
>>          100000    2   udp    111  portmapper
>>          100024    1   udp  32768  status
>>          100024    1   tcp  32768  status
> ...
>
>
> So bligh, the client, is running statd (the "status" service), but
> mussel can not talk to it.  This is a problem.
>
> It would appear that some for of firewall is blocking access to
> bligh's statd from mussel, or that  bligh's statd is ignoring requests
> from mussel.  I don't know which.
>
> NeilBrown

alright - i'll look into this.  as you might have guessed, i'm the developer
and not the sysad so i can't do much at the moment.  i'm guessing you are
correct on the former count.  i surely wasn't told about any changes but that
has been known to happen before.  in addition to that government security
policies get stricter and stricter and redhat could have done something in the
new kernel that is 'safer'.  i'll investigate and get back to you.

thanks tons for the lead... i'll post more tomorrow.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
