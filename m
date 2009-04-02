From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NetworkManager and sm-notify
Date: Thu, 2 Apr 2009 14:03:26 -0400
Message-ID: <20090402180326.GC5560@fieldses.org>
References: <8F917BB8-7590-434B-B8AF-2447E6622A41@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48575 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765523AbZDBSDf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 14:03:35 -0400
In-Reply-To: <8F917BB8-7590-434B-B8AF-2447E6622A41@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 30, 2009 at 01:50:47PM -0400, Chuck Lever wrote:
> Hi Steve-
>
> While playing with some sm-notify testing, I discovered this little  
> bug-a-boo on Fedora 10:  If the system uses NetworkManager to configure 
> its network interfaces, sm-notify doesn't work.
>
> Mar 30 13:25:43 ingres rpc.statd[1692]: Version 1.1.4 StartingMar 30  
> 13:25:43 ingres sm-notify[1694]: Sending Reboot Notification to  
> 'tarkus.1015granger.net' failed: errno 101 (Network is unreachable)
> Mar 30 13:25:43 ingres kernel: RPC: Registered udp transport module.
> Mar 30 13:25:43 ingres kernel: RPC: Registered tcp transport module.
> Mar 30 13:25:44 ingres acpid: starting up
> Mar 30 13:25:45 ingres kernel: it87: Found IT8718F chip at 0xe80,  
> revision 5
> Mar 30 13:25:45 ingres kernel: it87: in3 is VCC (+5V)
> Mar 30 13:25:45 ingres kernel: it87: in7 is VCCH (+5V Stand-By)
> Mar 30 13:25:45 ingres acpid: client connected from 1936[68:68]
> Mar 30 13:25:45 ingres sm-notify[1694]: Sending Reboot Notification to  
> 'tarkus.1015granger.net' failed: errno 101 (Network is unreachable)
> Mar 30 13:25:45 ingres NetworkManager: <info>  starting...
>
> ...
>
> Mar 30 13:25:49 ingres sm-notify[1694]: Sending Reboot Notification to  
> 'tarkus.1015granger.net' failed: errno 101 (Network is unreachable)
> Mar 30 13:25:50 ingres NetworkManager: <info>  (eth0): device state  
> change: 1 -> 2
> Mar 30 13:25:50 ingres NetworkManager: <info>  (eth0): bringing up  
> device.
>
> ...
>
> Mar 30 13:25:54 ingres NetworkManager: <info>  (eth0): device state  
> change: 7 -> 8
> Mar 30 13:25:54 ingres NetworkManager: <info>  Policy set 'System eth0' 
> (eth0) as default for routing and DNS.
> Mar 30 13:25:54 ingres NetworkManager: <info>  Activation (eth0)  
> successful, device activated.
> Mar 30 13:25:54 ingres NetworkManager: <info>  Activation (eth0) Stage 5 
> of 5 (IP Configure Commit) complete.
>
> ...
>
> Then finally:
>
> Mar 30 13:25:57 ingres Backgrounding to notify hosts...
>
> (this comes out after notification is complete because it is done before 
> daemon() and openlog() are called, so it's buffered up).
>
> In this case, I had actually added an entry for 'tarkus' to /etc/hosts  
> by hand, so sm-notify keeps trying until the network comes up.  Before I 
> did that, however, it was attempting to look up 'tarkus' via DNS, and 
> failing immediately; a reboot notification was never sent.
>
> So we have a system boot ordering problem here with NFS and  
> NetworkManager.
>
> I can add more robust retry handling in my sm-notify rewrite that might 
> be able to recover from this... or we could attempt to run sm-notify as 
> part of network bring-up instead of being run by rpc.statd...

(Just make sure it's not called every time network comes up, I guess.)

--b.

> I should 
> probably do the former anyway.
