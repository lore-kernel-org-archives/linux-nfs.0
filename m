From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: [2.6.30.1] Significant latency playing video file from NFS4 share
Date: Tue, 21 Jul 2009 23:54:10 +0200
Message-ID: <200907212354.11174.elendil@planet.nl>
References: <200907172250.51504.elendil@planet.nl> <200907211931.50015.elendil@planet.nl> <1248199105.21343.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cpsmtpm-eml104.kpnxchange.com ([195.121.3.8]:49391 "EHLO
	CPSMTPM-EML104.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753974AbZGUVyM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 17:54:12 -0400
In-Reply-To: <1248199105.21343.16.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 21 July 2009, Trond Myklebust wrote:
> This would be where you are losing your performance. 1998.933 ms rtt
> means that you are seeing a 2 second delay from the instant the RPC
> client pushes the request into the socket to the moment that socket
> receives a reply from the server.
>
> Basically, you have either a _very_ slow server, or (more likely) a

The server should be fast enough.

> networking problem. A tcpdump ought to be able to show what the problem
> is: whether it is the packets getting ACKed very slowly, and/or if you
> have dropped packet issues or if it is truly a problem with the server
> taking a long time to reply.

I did run a traceroute alongside and that did not show packet loss, but I 
do now see some TCP data loss events and retransmits of segments in
'netstat -s', and "TCP Previous segment lost" with varying time gaps in 
wireshark. So I guess it is indeed a networking problem.

As I see it both with wired and wireless on the client, the problem must 
be either in the server or the switch near the server (replacing the 
cable from the server did not help).
I suspect the integrated e1000e NIC. Guess I'll add an extra NIC in the 
server soon to see if that helps.

Thanks a lot for your help!


P.S. I see one strange thing in wireshark: NFS (or the networking stack) 
seems to switch between small and large package (?) sizes occasionally in 
the same stream. Is that normal?

Source     Destination   Protocol   Info
[...]
<server>   <client>      RPC        Continuation
<server>   <client>      RPC        Continuation
<client>   <server>      TCP        kink > nfs [ACK] ...
<server>   <client>      RPC        Continuation
<server>   <client>      RPC        Continuation
<client>   <server>      TCP        kink > nfs [ACK] ...
<server>   <client>      TCP        [TCP segment of reassembled PDU]
<server>   <client>      TCP        [TCP segment of reassembled PDU]
<client>   <server>      TCP        kink > nfs [ACK] ...
<server>   <client>      TCP        [TCP segment of reassembled PDU]
<server>   <client>      TCP        [TCP segment of reassembled PDU]
<client>   <server>      TCP        kink > nfs [ACK] ...
[...]
<server>   <client>      TCP        [TCP segment of reassembled PDU]
<server>   <client>      RPC        Continuation     (total: 65535 bytes)
<client>   <server>      TCP        kink > nfs [ACK] ...
<server>   <client>      RPC        Continuation
<server>   <client>      RPC        Continuation
<client>   <server>      TCP        kink > nfs [ACK] ...
[...]
