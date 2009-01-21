From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 14:37:44 -0500
Message-ID: <49777988.6010401@RedHat.com>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> Hey Steve-
> 
> On Jan 21, 2009, at Jan 21, 2009, 12:13 PM, Steve Dickson wrote:
>> Sorry for the delayed response... That darn flux capacitor broke
>> again! ;-)
>>
>>
>> Chuck Lever wrote:
>>>
>>> I'm all for improving the observability of the NFS client.
>> Well, in theory, trace points will also touch the server and all
>> of the rpc code...
>>
>>>
>>> But I don't (yet) see the advantage of adding this complexity in the
>>> mount path.  Maybe the more complex and asynchronous parts of the NFS
>>> client, like the cached read and write paths, are more suitable to this
>>> type of tool.
>> Well the complexity is, at this point, due to how the trace points
>> are tied to and used by the systemtap. I'm hopeful this complexity
>> will die down as time goes on...
> 
> I understand that your proposed mount path changes were attempting to
> provide a simple example of using trace points that could be applied to
> the NFS client and server in general.
Very true... Its definitely just a template... If/when we agree to a 
format of the template, I would like to simple clone it through the
rest of the code.

> However I'm interested mostly in improving how the mount path in
> specific reports problems.  I'm not convinced that trace points (or our
> current dprintk, for that matter) is a useful approach to solving NFS
> mount issues, in specific.
> 
> But that introduces the general question of whether trace points,
> dprintk, network tracing, or something else is the most appropriate tool
> to address the most common troubleshooting problems in any particular
> area of the NFS client or server.  I'd also like some clarity on what
> our problem statement is here.  What problems are we trying to address?
The problem I'm trying to address is allowing admins to debug (or decipher)
NFS problems on production system in a very non-intrusive way. Meaning
having no ill effects on performance or stability when the trace points
are enabled. 

> 
>>> Why can't we simply improve the information content of the dprintks?
>> The theory is trace point can be turned on, in production kernels, with
>> little or no performance issues...
> 
> mount isn't a performance path, which is one reason I think trace points
> might be overkill for this case.
Maybe so, but again, it was one of the easier paths to convert. Would it 
be more palatable if I converted the I/O paths?

> 
>>> Can you give a few real examples of problems that these new trace points
>>> can identify that better dprintks wouldn't be able to address?
>> They can supply more information that can be used by both a kernel
>> guy and an IT guy.... Meaning they can supply detailed structure
>> information
>> that a kernel guy would need as well as supplying the simple error code
>> that an IT guy would be interested.
> 
> My point is, does that flexibility really help some poor admin who is
> trying to diagnose a mount problem?  Is it going to reduce the number of
> calls to your support desk?
I think so... Once the admin either learn what is available and how
to use them they will be able better more concise bug reports. So maybe
there may not a decrease in calls but each caller (potentially) will
supply the support desk with better information.
  
> 
> I'd like to see an example of a real mount problem or two that dprintk
> isn't adequate for, but a trace point could have helped.  In other
> words, can we get some use cases for dprintk and trace points for mount
> problems in specific?  I think that would help us understand the
> trade-offs a little better.
In the mount path that might be a bit difficult... but with trace
points you would be able to look at the entire super block or entire 
server and client structures something you can't static/canned 
printks... 
 
> 
> Some general use cases for trace points might also widen our dialog
> about where they are appropriate to use.  I'm not at all arguing against
> using trace points in general, but I would like to see some thinking
> about whether they are the most appropriate tool for each of the many
> troubleshooting jobs we have.
I/O paths jumps into my head... since trace points much less of a performance
killer than printks, the I/O path might be an appropriate use...

> 
>>> Generally, what kind of problems do admins face that the dprintks don't
>>> handle today, and what are the alternatives to addressing those issues?
>> Not being an admin guy, I really don't have an answer for this... but
>> I can say since trace point are not so much of a drag on the system as
>> printks are.. with in timing issues using trace point would be a big
>> advantage
>> over printks
> 
> I like the idea of not depending on the system log, and that's
> appropriate for performance hot paths and asynchronous paths where
> timing can be an issue.  That's one reason why I created the NFS and RPC
> performance metrics facility.
Which is total being underutilized... IMHO... I can see a combination of
using both.... Using the metrics to identify a problem and the using
trace point to solve the problem...
 
> 
> But mount is not a performance path, and is synchronous, more or less. 
> In addition, mount encounters problems much more frequently than the
> read or write path, because mount depends a lot on what options are
> selected and the network environment its running in.  It's the first
> thing to try contacting the server, as well, so it "shakes out" a lot of
> problems before a read or write is even done.
> 
> So something like dprintk or trace points or a network trace that have
> some set up overhead might be less appropriate for mount than, say,
> beefing up the error reporting framework in the mount path, just as an
> example.
Trace points by far have much much less overhead than printks... thats
one of their major advantages... 

> 
>>> Do admins who run enterprise kernels actually use SystemTap, or do they
>>> fall back on network traces and other tried and true troubleshooting
>>> methodologies?
>> Currently to run systemtap, one need kernel debug info and kernel
>> developer
>> info installed on the system. Most productions system don't install
>> those types
>> of packages.... But with trace points those type of packages will no
>> longer be
>> needed, so I could definitely see admins using systemtap once its
>> available...
>> Look at Dtrace... people are using that now that its available and
>> fairly stable.
>>
>>> If we think the mount path needs such instrumentation, consider updating
>>> fs/nfs/mount_clnt.c and net/sunrpc/rpcb_clnt.c as well.
>>>
>> I was just following what what was currently being debug when
>> 'rpcinfo -m nfs -s mount' was set...
> 
> `rpcdebug -m nfs -s mount` also enables the dprintks in
> fs/nfs/mount_clnt.c, at least.  As with most dprintk infrastructure in
> NFS, it's really aimed at developers and not end users or admins.  The
> rpcbind client is also an integral part of the mount process, so I
> suggested that too.
> 
ACK...

steved.
