From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 13:01:31 -0500
Message-ID: <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
References: <4970B451.4080201@RedHat.com> <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com> <497757D1.7090908@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:62563 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541AbZAUSCI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 13:02:08 -0500
In-Reply-To: <497757D1.7090908-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Steve-

On Jan 21, 2009, at Jan 21, 2009, 12:13 PM, Steve Dickson wrote:
> Sorry for the delayed response... That darn flux capacitor broke  
> again! ;-)
>
>
> Chuck Lever wrote:
>>
>> I'm all for improving the observability of the NFS client.
> Well, in theory, trace points will also touch the server and all
> of the rpc code...
>
>>
>> But I don't (yet) see the advantage of adding this complexity in the
>> mount path.  Maybe the more complex and asynchronous parts of the NFS
>> client, like the cached read and write paths, are more suitable to  
>> this
>> type of tool.
> Well the complexity is, at this point, due to how the trace points
> are tied to and used by the systemtap. I'm hopeful this complexity
> will die down as time goes on...

I understand that your proposed mount path changes were attempting to  
provide a simple example of using trace points that could be applied  
to the NFS client and server in general.

However I'm interested mostly in improving how the mount path in  
specific reports problems.  I'm not convinced that trace points (or  
our current dprintk, for that matter) is a useful approach to solving  
NFS mount issues, in specific.

But that introduces the general question of whether trace points,  
dprintk, network tracing, or something else is the most appropriate  
tool to address the most common troubleshooting problems in any  
particular area of the NFS client or server.  I'd also like some  
clarity on what our problem statement is here.  What problems are we  
trying to address?

>> Why can't we simply improve the information content of the dprintks?
> The theory is trace point can be turned on, in production kernels,  
> with
> little or no performance issues...

mount isn't a performance path, which is one reason I think trace  
points might be overkill for this case.

>> Can you give a few real examples of problems that these new trace  
>> points
>> can identify that better dprintks wouldn't be able to address?
> They can supply more information that can be used by both a kernel
> guy and an IT guy.... Meaning they can supply detailed structure  
> information
> that a kernel guy would need as well as supplying the simple error  
> code
> that an IT guy would be interested.

My point is, does that flexibility really help some poor admin who is  
trying to diagnose a mount problem?  Is it going to reduce the number  
of calls to your support desk?

I'd like to see an example of a real mount problem or two that dprintk  
isn't adequate for, but a trace point could have helped.  In other  
words, can we get some use cases for dprintk and trace points for  
mount problems in specific?  I think that would help us understand the  
trade-offs a little better.

Some general use cases for trace points might also widen our dialog  
about where they are appropriate to use.  I'm not at all arguing  
against using trace points in general, but I would like to see some  
thinking about whether they are the most appropriate tool for each of  
the many troubleshooting jobs we have.

>> Generally, what kind of problems do admins face that the dprintks  
>> don't
>> handle today, and what are the alternatives to addressing those  
>> issues?
> Not being an admin guy, I really don't have an answer for this... but
> I can say since trace point are not so much of a drag on the system as
> printks are.. with in timing issues using trace point would be a big  
> advantage
> over printks

I like the idea of not depending on the system log, and that's  
appropriate for performance hot paths and asynchronous paths where  
timing can be an issue.  That's one reason why I created the NFS and  
RPC performance metrics facility.

But mount is not a performance path, and is synchronous, more or  
less.  In addition, mount encounters problems much more frequently  
than the read or write path, because mount depends a lot on what  
options are selected and the network environment its running in.  It's  
the first thing to try contacting the server, as well, so it "shakes  
out" a lot of problems before a read or write is even done.

So something like dprintk or trace points or a network trace that have  
some set up overhead might be less appropriate for mount than, say,  
beefing up the error reporting framework in the mount path, just as an  
example.

>> Do admins who run enterprise kernels actually use SystemTap, or do  
>> they
>> fall back on network traces and other tried and true troubleshooting
>> methodologies?
> Currently to run systemtap, one need kernel debug info and kernel  
> developer
> info installed on the system. Most productions system don't install  
> those types
> of packages.... But with trace points those type of packages will no  
> longer be
> needed, so I could definitely see admins using systemtap once its  
> available...
> Look at Dtrace... people are using that now that its available and  
> fairly stable.
>
>> If we think the mount path needs such instrumentation, consider  
>> updating
>> fs/nfs/mount_clnt.c and net/sunrpc/rpcb_clnt.c as well.
>>
> I was just following what what was currently being debug when
> 'rpcinfo -m nfs -s mount' was set...

`rpcdebug -m nfs -s mount` also enables the dprintks in fs/nfs/ 
mount_clnt.c, at least.  As with most dprintk infrastructure in NFS,  
it's really aimed at developers and not end users or admins.  The  
rpcbind client is also an integral part of the mount process, so I  
suggested that too.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
