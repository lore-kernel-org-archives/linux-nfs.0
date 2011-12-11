Return-Path: linux-nfs-owner@vger.kernel.org
Received: from frankvm.xs4all.nl ([83.163.148.79]:60875 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751914Ab1LKOJ1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 09:09:27 -0500
Date: Sun, 11 Dec 2011 15:09:25 +0100
From: Frank van Maarseveen <frankvm@frankvm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: 3.1.4: NFSv3 RPC scheduling issue?
Message-ID: <20111211140925.GA11414@janus>
References: <20111205165021.GA24165@janus>
 <1323128376.7237.7.camel@lade.trondhjem.org>
 <20111206081115.GA3570@janus>
 <1323201463.3199.18.camel@lade.trondhjem.org>
 <20111207134359.GA29828@janus>
 <1323486601.32695.2.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1323486601.32695.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 09, 2011 at 10:10:01PM -0500, Trond Myklebust wrote:
> [...]
> I'm still mystified as to what is going on here...

There is some network traffic I don't understand but it might be relevant.

Client machine: 172.17.1.49
server hardware: 172.17.2.241

The server has an additional IP addres for every exported mount point. The
one which is mounted and blocked on the client doesn't show up in traffic
below. The server itself serves NIS too but the client is bound to a
different physical machine for this. The following was captured (added
some tshark -V output to clarify a bit):

Frame Time      Data
  1   0.000000  172.17.1.49 -> 172.17.255.255 Portmap V2 CALLIT Call
--------------------------------------------------------------------
User Datagram Protocol, Src Port: 38242 (38242), Dst Port: sunrpc (111)
Remote Procedure Call, Type:Call XID:0x42d68775
    Program: Portmap (100000)
    Program Version: 2
    Procedure: CALLIT (5)
    Credentials
        Flavor: AUTH_UNIX (1)
        Length: 40
    Verifier
        Flavor: AUTH_NULL (0)
        Length: 0
Portmap DOMAIN_NONACK call
    [Program Version: 2]
    [V2 Procedure: CALLIT (5)]
    Program: YPSERV (100004)
    Version: 2
    Procedure: DOMAIN_NONACK (2)
    Argument length: 8
    Domain: TSKU
        length: 4
        contents: TSKU

  2   0.000544 172.17.2.241 -> 172.17.1.49  UDP Source port: rda  Destination port: 38242
-----------------------------------------------------------------------------------------
User Datagram Protocol, Src Port: rda (630), Dst Port: 38242 (38242)
Data (36 bytes)		// no clue from tshark
0000  42 d6 87 75 00 00 00 01 00 00 00 00 00 00 00 00   B..u............
0010  00 00 00 00 00 00 00 00 00 00 03 5b 00 00 00 04   ...........[....
0020  00 00 00 01                                       ....


  3   0.000740  172.17.1.49 -> 172.17.2.241 ICMP Destination unreachable (Port unreachable)
-------------------------------------------------------------------------------------------
Internet Control Message Protocol
    Type: 3 (Destination unreachable)
    Code: 3 (Port unreachable)
    User Datagram Protocol, Src Port: rda (630), Dst Port: 38242 (38242)

  4   5.016300 Dell_e7:1f:f0 -> Dell_38:31:b8 ARP Who has 172.17.1.49?  Tell 172.17.2.241
  5   5.016443 Dell_38:31:b8 -> Dell_e7:1f:f0 ARP 172.17.1.49 is at 00:14:22:38:31:b8
  6  20.001647  172.17.1.49 -> 172.17.255.255 Portmap V2 CALLIT Call
  7  20.002132 172.17.2.241 -> 172.17.1.49  UDP Source port: rda  Destination port: 49408
  8  20.002375  172.17.1.49 -> 172.17.2.241 ICMP Destination unreachable (Port unreachable)
  9  25.013384 Dell_38:31:b8 -> Dell_e7:1f:f0 ARP Who has 172.17.2.241?  Tell 172.17.1.49
 10  25.013397 Dell_e7:1f:f0 -> Dell_38:31:b8 ARP 172.17.2.241 is at 00:18:8b:e7:1f:f0
 11  40.003525  172.17.1.49 -> 172.17.255.255 Portmap V2 CALLIT Call
 12  40.004003 172.17.2.241 -> 172.17.1.49  UDP Source port: rda  Destination port: 51755
 13  40.004249  172.17.1.49 -> 172.17.2.241 ICMP Destination unreachable (Port unreachable)

The UDP port seems random and doesn't show up in rpcinfo -p for client
or server. What bothers me is the ICMP Destination unreachable. It
applies to a port (code=3) but it might have some adverse effect on other
traffic from the same hardware to the client. And I don't understand
why the ICMP error occurs. But maybe this is all irrelevant.

-- 
Frank
