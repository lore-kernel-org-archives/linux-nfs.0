From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 15:19:15 -0500
Message-ID: <A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<49777988.6010401@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49777988.6010401@RedHat.com>
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

On Jan 21, 2009, at Jan 21, 2009, 2:37 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> Hey Steve-
>>
>> I'd like to see an example of a real mount problem or two that  
>> dprintk
>> isn't adequate for, but a trace point could have helped.  In other
>> words, can we get some use cases for dprintk and trace points for  
>> mount
>> problems in specific?  I think that would help us understand the
>> trade-offs a little better.
> In the mount path that might be a bit difficult... but with trace
> points you would be able to look at the entire super block or entire
> server and client structures something you can't static/canned
> printks...

I've never ever seen an NFS mount problem that required an admin to  
provide information from a superblock.  That seems like a lot of  
implementation detail that would be meaningless to admins and support  
desk folks.

This is why I think we need to have some real world customer examples  
of mount problems (or read performance problems, or whatever) that we  
want to be able to diagnose in enterprise distributions.  I'm not  
saying this to throw up a road block... I think we really need to  
understand the problem before designing the solution, and so let's  
start with some practical examples.

Again, I'm not saying trace points are bad or wrong, just that they  
may not be appropriate for a particular code path and the type of  
problems that arise during specific NFS operations.  I'm not  
criticizing your particular sample code.  I'm asking "Before we add  
trace points everywhere, are trace points strategically the right  
debugging tool in every case?"

Basically we have to know well in advance what kind of information  
will be needed at each trace point.  Who can predict?  If you have to  
solder in trace points in advance, in some ways that doesn't seem any  
more flexible than a dprintk.  What you've demonstrated is another  
good general tool for debugging, but you haven't convinced me that  
this is the right tool for, say, the mount path, or ACL support, and  
so on.

>> But mount is not a performance path, and is synchronous, more or  
>> less.
>> In addition, mount encounters problems much more frequently than the
>> read or write path, because mount depends a lot on what options are
>> selected and the network environment its running in.  It's the first
>> thing to try contacting the server, as well, so it "shakes out" a  
>> lot of
>> problems before a read or write is even done.
>>
>> So something like dprintk or trace points or a network trace that  
>> have
>> some set up overhead might be less appropriate for mount than, say,
>> beefing up the error reporting framework in the mount path, just as  
>> an
>> example.
> Trace points by far have much much less overhead than printks... thats
> one of their major advantages...

Yeah, but that doesn't matter in some cases, like mount, or  
asynchronous file deletes, or .... so we have to look at some of the  
other issues with using them when deciding if they are the right tool  
for the job.

I think we need to visit this issue on a case-by-case basis.   
Sometimes dprintk is appropriate.  Sometimes printk(KERN_ERR).   
Sometimes a performance metric.  Having specific troubleshooting in  
mind when we design this is critical, otherwise we are going to add a  
lot of kruft for no real benefit.

That's an advantage of something like SystemTap.  You can specify  
whatever is needed for a specific problem, and you don't need to  
recompile the kernel to do it.  Enterprise distributions can provide  
specific scripts for their code base, which doesn't change much.   
Upstream is free to make whatever drastic modifications to the code  
base without worrying about breaking a kernel-user space API.

Trond has always maintained that dprintk() is best for developers, but  
probably inappropriate for field debugging, and I think that may also  
apply to trace points.  So I'm not against adding trace points where  
appropriate, but I'm doubtful that they will be helpful outside of  
kernel development; ie I wonder if they will specifically help  
customers of enterprise distributions.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
