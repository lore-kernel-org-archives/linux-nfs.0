From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS client packet storm on 2.6.27.x
Date: Wed, 29 Apr 2009 08:12:38 -0400
Message-ID: <49F84436.5090007@RedHat.com>
References: <1231782009.7322.12.camel@heimdal.trondhjem.org> <1231809446.7322.17.camel@heimdal.trondhjem.org> <20090113152201.GD47559@fit.vutbr.cz> <20090116104802.GF47559@fit.vutbr.cz> <20090118130835.GH47559@fit.vutbr.cz> <20090120150301.GG47559@fit.vutbr.cz> <1232465547.7055.3.camel@heimdal.trondhjem.org> <20090303120848.GV89843@fit.vutbr.cz> <1236089767.9631.4.camel@heimdal.trondhjem.org> <20090418051739.GL64731@fit.vutbr.cz> <20090422172707.GC57877@fit.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kasparek Tomas <kasparek@fit.vutbr.cz>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757266AbZD2MPz@vger.kernel.org>
In-Reply-To: <20090422172707.GC57877@fit.vutbr.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kasparek Tomas wrote:
> On Sat, Apr 18, 2009 at 07:17:39AM +0200, Kasparek Tomas wrote:
>> On Tue, Mar 03, 2009 at 09:16:07AM -0500, Trond Myklebust wrote:
>>> On Tue, 2009-03-03 at 13:08 +0100, Kasparek Tomas wrote:
>>>> On Tue, Jan 20, 2009 at 10:32:27AM -0500, Trond Myklebust wrote:
>>>>> A binary wireshark dump of the traffic between one such client and the
>>>>> server would help.
>>>> I was able to finally got the tcpdump. I got it from 2.6.27.19 client but
>>>> after several weeks without problems. I include the file and place it on
>>>> http://merlin.fit.vutbr.cz/tmp/nfs/dump_kas2_mat.dump_small (have over 1GB
>>>> of dump, but it's all the time the same SYN+RST packets). The packet rate
>>>> maxed at 260000pps from two clients.
>>>>
>>>> This dump is taken from server after reset (the server does not respond
>>>> even to keybord) before clients are disconnected/rebooted. To remind it - all
>>>> clients seems to work well with reversed
>>>> e06799f958bf7f9f8fae15f0c6f519953fb0257c
>>> Yes. I saw that behaviour when testing at Connectathon last week. When
>>> one of the servers I was testing against crashed and later came up
>>> again, the patched client went into that same SYN+RST frenzy. I'm
>>> planning to look at this now that I'm back at home.
>> Hi, got a bit more data today as I get to the client early before it become
>> unresponsible. 
>>
>>
>> The lockup may be becouse I disconnected the cable from that client to stop
>> the packet storm, but still the backtrace may be usefull.
>>
>> Is there anything else I can do, that will help with this problem?
> 
> Hi,
> 
> (I changed the SUBJ to be more descriptive for current problem)
> 
> I got another client lockup today. It was a desktop so I have some more
> dmesg warnings about soft lockup caused probably by network cable unplug
> (but hopefully still showing what happens in rpciod) on
> 
> http://merlin.fit.vutbr.cz/tmp/nfs/pckas-dmesg
> 
> I can check with top, that rpciod was using 100% cpu. I limited the flow
> from client to server with firewall so I was able to save the server and
> get some tcpdump -s0 data (actually RPC null with ERR response from server)
> 
> Just to remind, the client is 2.6.27.21 (i386), the server is 2.6.16.62
> (x86_64).
> 
> Please let me know if I can do anything more, this is really paintfull for
> me.
Try commenting out the tcp6/udp6 entries from /etc/netconfig....
This has help in other places...

steved.
