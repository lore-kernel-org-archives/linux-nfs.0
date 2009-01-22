From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 08:55:24 -0500
Message-ID: <49787ACC.8090002@RedHat.com>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<49777988.6010401@RedHat.com>
	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
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
> On Jan 21, 2009, at Jan 21, 2009, 2:37 PM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>> Hey Steve-
>>>
>>> I'd like to see an example of a real mount problem or two that dprintk
>>> isn't adequate for, but a trace point could have helped.  In other
>>> words, can we get some use cases for dprintk and trace points for mount
>>> problems in specific?  I think that would help us understand the
>>> trade-offs a little better.
>> In the mount path that might be a bit difficult... but with trace
>> points you would be able to look at the entire super block or entire
>> server and client structures something you can't static/canned
>> printks...
> 
> I've never ever seen an NFS mount problem that required an admin to
> provide information from a superblock.  That seems like a lot of
> implementation detail that would be meaningless to admins and support
> desk folks.
True... but my point is with trace points and systemtap scripts
one has access to BOTH highly technical data (for the developer)
and simple error codes (for the admins).... Unlike with printks...
  
> 
> This is why I think we need to have some real world customer examples of
> mount problems (or read performance problems, or whatever) that we want
> to be able to diagnose in enterprise distributions.  I'm not saying this
> to throw up a road block... I think we really need to understand the
> problem before designing the solution, and so let's start with some
> practical examples.
I'm not sure this is an obtainable goal.... I see it as we put in a 
well design infrastructure (something I think Trond is suggesting)
and then let the consumers of the infrastructure tell us what is need... 
Believe there are enterprise people that know *exactly* what
they are looking for... ;-)

> 
> Again, I'm not saying trace points are bad or wrong, just that they may
> not be appropriate for a particular code path and the type of problems
> that arise during specific NFS operations.  I'm not criticizing your
> particular sample code.  I'm asking "Before we add trace points
> everywhere, are trace points strategically the right debugging tool in
> every case?"
Good point... but the fact trace points very little overhead with them its
kinda hard to see why they would not be the right tool... But again
I do see your point... 
 
> 
> Basically we have to know well in advance what kind of information will
> be needed at each trace point.  Who can predict?  If you have to solder
> in trace points in advance, in some ways that doesn't seem any more
> flexible than a dprintk.  What you've demonstrated is another good
> general tool for debugging, but you haven't convinced me that this is
> the right tool for, say, the mount path, or ACL support, and so on.
No worries.. I'll keep trying! ;-) 

To your point, I know for a fact there are customers asking for
trace points in particular areas of the code (not the NFS code atm).
So, again, I think we should take the "build it and will come"
approach... Meaning, give people something to work with and they
will let us know what they need...
 
> 
> I think we need to visit this issue on a case-by-case basis.  Sometimes
> dprintk is appropriate.  Sometimes printk(KERN_ERR).  Sometimes a
> performance metric.  Having specific troubleshooting in mind when we
> design this is critical, otherwise we are going to add a lot of kruft
> for no real benefit.
I can agree with this...

> 
> That's an advantage of something like SystemTap.  You can specify
> whatever is needed for a specific problem, and you don't need to
> recompile the kernel to do it.  Enterprise distributions can provide
> specific scripts for their code base, which doesn't change much. 
> Upstream is free to make whatever drastic modifications to the code base
> without worrying about breaking a kernel-user space API.
> 
> Trond has always maintained that dprintk() is best for developers, but
> probably inappropriate for field debugging, and I think that may also
> apply to trace points.  So I'm not against adding trace points where
> appropriate, but I'm doubtful that they will be helpful outside of
> kernel development; ie I wonder if they will specifically help customers
> of enterprise distributions.
> 
Time will tell... I think once customers see how useful and powerful
traces can but they be come addicted.... fairly quickly....

steved.
