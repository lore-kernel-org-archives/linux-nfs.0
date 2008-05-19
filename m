From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/8] SUNRPC: Add second output line for each RPC task in rpc_show_tasks
Date: Mon, 19 May 2008 13:11:16 -0400
Message-ID: <AB10F95B-F415-442E-BE42-DFB578F4BB36@oracle.com>
References: <20080518021241.8366.12464.stgit@ellison.1015granger.net> <20080518021650.8366.96474.stgit@ellison.1015granger.net> <1211214702.16052.7.camel@localhost> <B58E7754-A434-4E32-B64A-B693E548EB1E@oracle.com> <1211215443.16052.10.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:56590 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925AbYESRMI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 13:12:08 -0400
In-Reply-To: <1211215443.16052.10.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 19, 2008, at 12:44 PM, Trond Myklebust wrote:
> On Mon, 2008-05-19 at 12:41 -0400, Chuck Lever wrote:
>> On May 19, 2008, at 12:31 PM, Trond Myklebust wrote:
>>> On Sat, 2008-05-17 at 22:16 -0400, Chuck Lever wrote:
>>>> Add a second output line displayed for each RPC task shown via
>>>> rpc_show_tasks.  This second line is for non-columnar variable- 
>>>> length
>>>> data (like the name of the RPC wait queue the task is waiting on,  
>>>> or
>>>> the procedure name).
>>>
>>> I don't really agree with this: it makes the output harder to parse
>>> rather than easier. grep, awk and friends don't cope well with
>>> multi-line data...
>>
>> Would it be better to put it all on one line, but the variable length
>> items are at the end and don't get a column header?
>
> That would make it easier, but why the change in format in the first
> place? This is developer-level debugging info: it is not designed for
> user comfort.

Are developers not also users?  If you prick us, do we not bleed?  :-)

We already have a variable length field for the RPC queue name, and  
integer overflows in the other items, which often cause the displayed  
columns not to line up.  This becomes headache-inducing when looking  
at more than a handful of RPC tasks.

The patch series changes the rpc_show_tasks output to display a  
procedure name instead of a number, a program name and version instead  
of numbers, and to use a symbolic name instead of a function address  
for displaying tk_action.

In other words, it makes the output much easier to parse for the  
overworked humans who have to use this interface for very low cost in  
the kernel.  That information, it turns out, was mostly already  
available.

Given that we would then have multiple variable-length fields, it  
seemed logical to me to move all of the variable length items out of  
the columns.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
