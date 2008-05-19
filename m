From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/8] SUNRPC: Add second output line for each RPC task in rpc_show_tasks
Date: Mon, 19 May 2008 12:41:32 -0400
Message-ID: <B58E7754-A434-4E32-B64A-B693E548EB1E@oracle.com>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021650.8366.96474.stgit@ellison.1015granger.net> <1211214702.16052.7.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:53749 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbYESQmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 12:42:43 -0400
In-Reply-To: <1211214702.16052.7.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2008, at 12:31 PM, Trond Myklebust wrote:
> On Sat, 2008-05-17 at 22:16 -0400, Chuck Lever wrote:
>> Add a second output line displayed for each RPC task shown via
>> rpc_show_tasks.  This second line is for non-columnar variable-length
>> data (like the name of the RPC wait queue the task is waiting on, or
>> the procedure name).
>
> I don't really agree with this: it makes the output harder to parse
> rather than easier. grep, awk and friends don't cope well with
> multi-line data...

Would it be better to put it all on one line, but the variable length  
items are at the end and don't get a column header?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
