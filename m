From: Charles-Edouard Ruault <ce@idtect.com>
Subject: Re: Linux 2.4.25, nfs client hangs when talking to a MacOS nfs server.
Date: Wed, 17 Mar 2004 18:41:12 +0100
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <4825B7F5-783A-11D8-97E9-000A95CFFC9C@idtect.com>
References: <117F2C39-7800-11D8-93C6-000A95CFFC9C@idtect.com> <1079542707.3047.12.camel@lade.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v613)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1079542707.3047.12.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <nfs.lists.sourceforge.net>


On Mar 17, 2004, at 5:58 PM, Trond Myklebust wrote:

> P=E5 on , 17/03/2004 klokka 05:44, skreiv Charles-Edouard Ruault:
>
> [snip]

> Your Mac server is replying slooooooooowwwwwwwwllllllllllyyyyyyyyyyy.
> That either indicates that you have a dirty network which is losing
> packets (can happen if you are mixing 10Mbps and 100Mbps segments) or
> the Mac server is hanging.
>
> Cheers,
>   Trond
>
Hi Trond,
thanks for the quick reply.
As you pointed out i've got a network which mixes 100Mbps and 1Gbps (=20
the mac is on 1Gps and the linux on 100Mbps ).
However i've done a little troubleshooting on the network and i achieve=
=20
full 100Mbps speed scp'ing files from/to both machines.
I've also tried to use nfs over tcp instead of udp and it does not=20
change anything.
I've got a Gigabit card for the Linux box and i've scheduled to install=
=20
it within the next few days. I'll see if this helps or not.
In the meantime, any other hint is welcome.
Thanks.


Charles-Edouard Ruault
Idtect SA
tel: +33-1-42-81-81-84
fax: +33-1-42-81-82-21
http://www.idtect.com
-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
