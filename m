From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 10:49:43 -0500
Message-ID: <49789597.8030504@RedHat.com>
References: <4970B451.4080201@RedHat.com>	
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	
	<497757D1.7090908@RedHat.com>	
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>	
	<1232566140.7692.64.camel@heimdal.trondhjem.org>	
	<49777E4C.2020501@RedHat.com>	
	<1232569427.7692.70.camel@heimdal.trondhjem.org>	
	<49786F9F.7030400@RedHat.com>
	<1232638257.7589.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1232638257.7589.16.camel@heimdal.trondhjem.org>
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



Trond Myklebust wrote:
> On Thu, 2009-01-22 at 08:07 -0500, Steve Dickson wrote:
>>> I think it might be a good idea to flesh out a bit what you mean by
>>> "debugging" here. Since you mentioned it in conjunction with the two
>>> words "administrators" and "scripts", I assume that you are not talking
>>> about kernel code debugging?
>> I'm talking debugging for both admins and kernel people...
>>
>> With trace points and systemtap you can do both.
> 
> Yes, but we still need to figure out details of what each type of user
> is expecting/wants.
Will that be possible? Until we get something in their hands, how will
they even know what they want or need.

> 
> I suspect that when we get down to cases, we will find that a lot of the
> tracepoints that administrators find useful will want to be put in the
> VFS rather than in the filesystems themselves. If you have tracepoints
> in sys_stat() and sys_fstat(), why would you also need a tracepoint in
> nfs_getattr()? AFAICS, that would just make scripting ugly...
I believe there is an effort to do some type of system call tracing 
as we speak and that effort should be followed to ensure there is
no duplicate of effort... But in the end, I would think more would be
better then less... since each point can be explicitly enabled and disabled
a little duplication may not be all that bad..

steved.
