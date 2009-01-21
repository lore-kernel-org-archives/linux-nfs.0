From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 12:13:53 -0500
Message-ID: <497757D1.7090908@RedHat.com>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
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

Sorry for the delayed response... That darn flux capacitor broke again! ;-)
 

Chuck Lever wrote:
> 
> I'm all for improving the observability of the NFS client.
Well, in theory, trace points will also touch the server and all
of the rpc code... 

> 
> But I don't (yet) see the advantage of adding this complexity in the
> mount path.  Maybe the more complex and asynchronous parts of the NFS
> client, like the cached read and write paths, are more suitable to this
> type of tool.
Well the complexity is, at this point, due to how the trace points
are tied to and used by the systemtap. I'm hopeful this complexity 
will die down as time goes on... 

> 
> Why can't we simply improve the information content of the dprintks?
The theory is trace point can be turned on, in production kernels, with
little or no performance issues... 

> Can you give a few real examples of problems that these new trace points
> can identify that better dprintks wouldn't be able to address?
They can supply more information that can be used by both a kernel
guy and an IT guy.... Meaning they can supply detailed structure information
that a kernel guy would need as well as supplying the simple error code 
that an IT guy would be interested.

> Generally, what kind of problems do admins face that the dprintks don't
> handle today, and what are the alternatives to addressing those issues?
Not being an admin guy, I really don't have an answer for this... but 
I can say since trace point are not so much of a drag on the system as
printks are.. with in timing issues using trace point would be a big advantage
over printks

> 
> Do admins who run enterprise kernels actually use SystemTap, or do they
> fall back on network traces and other tried and true troubleshooting
> methodologies?
Currently to run systemtap, one need kernel debug info and kernel developer
info installed on the system. Most productions system don't install those types
of packages.... But with trace points those type of packages will no longer be 
needed, so I could definitely see admins using systemtap once its available... 
Look at Dtrace... people are using that now that its available and fairly stable. 
 
> 
> If we think the mount path needs such instrumentation, consider updating
> fs/nfs/mount_clnt.c and net/sunrpc/rpcb_clnt.c as well.
> 
I was just following what what was currently being debug when
'rpcinfo -m nfs -s mount' was set... maybe I missed something...
I'll take a look...

steved.
