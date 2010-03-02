From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv3/NFSv4 problem.
Date: Tue, 2 Mar 2010 12:16:14 -0500
Message-ID: <20100302171614.GH5553@fieldses.org>
References: <D27EC8DD-AD1C-432D-99FD-E4AB6C26D189@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Anton Starikov <ant.starikov@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41986 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752174Ab0CBRPF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 12:15:05 -0500
In-Reply-To: <D27EC8DD-AD1C-432D-99FD-E4AB6C26D189@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 01, 2010 at 04:01:42PM +0100, Anton Starikov wrote:
> Hi, 
> 
> 
> my config is diskless NFSv3 nfsroot (+ some extra NFDSv3 mounts) and NFSv4 /home/* automount.
> Centos 5.4, kernel 2.6.18-164.11.1.el5.

That's the client?  What's the server?

That's pretty old kernel; I'd file a bug with CentOS.

> Periodically my nodes hangs, nothing appeared in the logs (remote syslog + netconsole).
> Node is kind of alive, you can ping, some deamons (for example pbs_mom) reports that it's alive etc.
> But anything which require FS access - frozen.
> 
> Another symptom, it looks like portmap doesn't answer. At lease if I try "rpcinfo -p node_name", then it ends with
> "rpcinfo: can't contact portmapper: rpcinfo: RPC: Timed out"
> 
> In principal, this can have something with locking.
> At least, I had to mount all my NFSv3 mounts with nolock, to reduce frequency of problem (nfsroot was nolock, obviously. but there are couple of extra v3 mounts, like /opt with extra software and RW directory for torque.
> 
> What can be a problem here?
> 
> What kind of information I have to collect from system to figure out what it real problem?

Is there any server-side logging?

Can you see any interesting network traffic after the hang?

--b.
