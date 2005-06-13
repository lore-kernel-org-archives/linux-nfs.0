From: Oded Maimon <oded.maimon@gmail.com>
Subject: Re: NFS High Availability Cluster
Date: Mon, 13 Jun 2005 22:13:05 +0200
Message-ID: <42ADE8D1.3050005@gmail.com>
References: <42AD5820.4060109@gmail.com> <1118686215.25437.19.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DhuMx-0007La-6M
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 12:13:11 -0700
Received: from wproxy.gmail.com ([64.233.184.194])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DhuMu-0000mx-MN
	for nfs@lists.sourceforge.net; Mon, 13 Jun 2005 12:13:11 -0700
Received: by wproxy.gmail.com with SMTP id 69so1114205wra
        for <nfs@lists.sourceforge.net>; Mon, 13 Jun 2005 12:13:06 -0700 (PDT)
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>,
	nfs@lists.sourceforge.net
In-Reply-To: <1118686215.25437.19.camel@seki.nac.uci.edu>
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

Hi,

I'm looking for a solution that will not make me reboot or even remount 
the file system (unless the remount is autmatically)...


what the reason that the automounter will do this only for read only data?


Thanks,

Oded.


Dan Stromberg wrote:

>I'm told that the current generation of automounter should be able to
>failover readonly versions of the same data.
>
>What we've been doing so far with linux, though, is to have a script
>that, instead of using fstab, instead traceroute's each of the replica
>servers and statically NFS mounts from the one that is up, and shows the
>lowest number of router hops.
>
>The autofs failover should obviate reboots, at least to some extent.
>
>The script I've described, which I'd be happy to share, makes it so
>endusers can just reboot to come up mounting from a different replica.
>
>On Mon, 2005-06-13 at 11:55 +0200, Oded Maimon wrote:
>  
>
>>Hi,
>>
>>Is it possible to set an NFS HA cluster?
>>
>>That means, that several servers will share the same disks in a SAN and 
>>will provide an NFS service for
>>
>>all my other servers?
>>
>>
>>I need that when one NFS server will fail (or the network connection to 
>>it)  then no server using the NFS will be affected and will continue to
>>
>>work with one of the other NFS servers.
>>
>>
>>Is it possible?
>>
>>
>>Thanks,
>>
>>Oded.
>>
>>
>>
>>
>>-------------------------------------------------------
>>This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
>>a projector? How fast can you ride your desk chair down the office luge track?
>>If you want to score the big prize, get to know the little guy.  
>>Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
>>    
>>


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
