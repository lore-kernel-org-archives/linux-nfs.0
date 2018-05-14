Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59812 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752312AbeENVSW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 May 2018 17:18:22 -0400
Date: Mon, 14 May 2018 17:18:22 -0400
To: Goran <sendmailtogoran@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: unstable nfs connection
Message-ID: <20180514211822.GD29264@fieldses.org>
References: <CABS5c+GR6xJwV6im=N36Qmax-P6ZWrJYwDDVdekF3LWQ0tToXw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CABS5c+GR6xJwV6im=N36Qmax-P6ZWrJYwDDVdekF3LWQ0tToXw@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 11, 2018 at 12:21:59PM +0200, Goran wrote:
> I have an issue with nfs which I'm using the first time.
> 
> I have a server running arch linux. Further the server is running
> several container, each container itself is running arch linux too.
> One container is running nfsd.
> 
> The nfs-container is connected via a virtual bridge. The bridge is
> hosted by the server. One physical device is connected to that bridge.
> A physical switch is connected to that physical device. The client is
> connected to the physical switch.
> 
> To keep it simpler:
> client -- clients NIC -- physical switch -- server NIC -- server
> bridge -- container NIC -- container
> 
> At first sight, everything works well, I can boot diskless/readonly
> from NFS. I use dracut for that. I can log into the client and start
> working.
> 
> If the client is just doing nothing I get after some time (e.g. 5 minutes)
> 
> nfs: server 172.17.0.5 not responding. still trying
> 
> or
> 
> nfs: server 172.17.0.5 not responding.timed out
> 
> If 10 clients starts at same time, the above error comes immediatly.
> 
> I took a look like at the containers nic
> 
> 23: eth0@if24: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> noqueue state UP mode DEFAULT group default qlen 1000
>     link/ether 42:3b:82:03:c0:7d brd ff:ff:ff:ff:ff:ff link-netnsid 0
>     RX: bytes  packets  errors  dropped overrun mcast
>     44184595   388170   0       205     0       0
>     TX: bytes  packets  errors  dropped carrier collsns
>     902023963  112922   0       0       0       0
> 
> but this seems not too much dropped packages for me. I'm more a C++
> guy, not as much an Linux admin. So I'm asking how can I debug this
> nfs-connection to make it stable?

I don't know.  My first impulse would be to blame some problem at the
networking level rather than NFS itself.  (Are those dropped packets
normal?  Can you reproduce problems with any protocol other than NFS?)

What are you using to set up the containers?  What does the server
bridge look like?  I wonder if there's some misconfiguration of the
bridge or of the server's virtual NIC, or an odd firewalling issue.

It *might* help to try watching the traffic over various interfaces with
wireshark.

--b.
