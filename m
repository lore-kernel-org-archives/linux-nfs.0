From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/2] mount: ECONNREFUSED is a permanent error
Date: Fri, 9 Oct 2009 11:13:11 -0400
Message-ID: <DDBA069F-E9B8-4BE3-B13C-2B69406C3C9A@ORACLE.COM>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173703.12619.35788.stgit@matisse.1015granger.net> <4ACF37C2.6030208@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:51033 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758850AbZJIPOO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2009 11:14:14 -0400
In-Reply-To: <4ACF37C2.6030208-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 9, 2009, at 9:16 AM, Steve Dickson wrote:
> On 10/08/2009 01:37 PM, Chuck Lever wrote:
>> I had assumed early on that mount.nfs should retry a refused  
>> connection.
>>
>> Apparently this is not the case.  Legacy mount.nfs4 fails immediately
>> if the NFS server refuses the connection.  Legacy mount.nfs and
>> text-based mount.nfs both fail immediately if the rpcbind service is
>> refusing connections.
>>
> What about if the server is on the way up (i.e the network is up)
> but has not started the NFS service? In that window, the server will
> return ECONNREFUSED since nobody is listening, but in a very short  
> time
> there will be a listener... The mount should not fail in that case...

I agree, but I think it does fail today, and it has behaved this way  
for a long while.  No one has complained about it.  I'm actually not  
arguing in favor of either behavior; just reporting that the current  
behavior is inconsistent.

With the current code, legacy and text-based v2/v3 fails immediately  
if the server's rpcbind refuses connection... Legacy mount.nfs4 fails  
immediately if the NFS server refuses connection.  Text-based  
mount.nfs4 retries in this case.

So we will either need to fix v2/v3 to continue retrying, or fix NFSv4  
to stop retrying.  The retries would stop after mount.nfs's retry  
timer expires (just like the case where the server isn't responding at  
all).

Automounter might want different behavior in this case, but we should  
ask around before making a final decision, probably.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



