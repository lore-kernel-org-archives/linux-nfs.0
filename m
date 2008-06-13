From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP
	snd/rcv buffer values
Date: Fri, 13 Jun 2008 16:56:20 -0400
Message-ID: <20080613205620.GN8501@fieldses.org>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com> <C04F3083-91B2-464B-8F5C-958B243EB46C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dean Hildebrand <seattleplus@gmail.com>, linux-nfs@vger.kernel.org,
	aglo@citi.umich.edu
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939AbYFMU4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 16:56:23 -0400
In-Reply-To: <C04F3083-91B2-464B-8F5C-958B243EB46C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2008 at 02:51:18PM -0400, Chuck Lever wrote:
> On Jun 12, 2008, at 5:03 PM, Dean Hildebrand wrote:
>> I think the problem there is that the only way to set the buffer size 
>> automatically would be to know the rtt and bandwidth of the network 
>> connection.  Excessive numbers of packets can get dropped if the TCP 
>> buffer is set too large for a specific network connection.
>
>> In this case, the window opens too wide and lets too many packets out 
>> into the system, somewhere along the path buffers start overflowing and 
>> packets are lost, TCP congestion avoidance kicks in and cuts the window 
>> size dramatically and performance along with it.  This type of 
>> behaviour creates a sawtooth pattern for the TCP window, which is less 
>> favourable than a more steady state pattern that is created if the TCP 
>> buffer size is set appropriately.
>
> Agreed it is a performance problem, but I thought some of the newer TCP 
> congestion algorithms were specifically designed to address this by not 
> closing the window as aggressively.
>
> Once the window is wide open, then, it would appear that choosing a good 
> congestion avoidance algorithm is also important.

Any references for Olga or I to read on that sort of behavior?

--b.
