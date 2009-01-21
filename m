From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 14:58:04 -0500
Message-ID: <49777E4C.2020501@RedHat.com>
References: <4970B451.4080201@RedHat.com>	
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	
	<497757D1.7090908@RedHat.com>	
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<1232566140.7692.64.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1232566140.7692.64.camel@heimdal.trondhjem.org>
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

Hey,

Trond Myklebust wrote:
> On Wed, 2009-01-21 at 13:01 -0500, Chuck Lever wrote:
>> `rpcdebug -m nfs -s mount` also enables the dprintks in fs/nfs/ 
>> mount_clnt.c, at least.  As with most dprintk infrastructure in NFS,  
>> it's really aimed at developers and not end users or admins.  The  
>> rpcbind client is also an integral part of the mount process, so I  
>> suggested that too.
> 
> This would be my main gripe with suggestions that we convert all the
> existing dprintks. As Chuck says, they are pretty much a hodgepodge of
> messages designed to help kernel developers to debug the NFS and RPC
> code.
Well as I see it, this is our chance to clean it up... 

> 
> If you want something dtrace-like to allow administrators to run scripts
> to monitor the health of their cluster and troubleshoot performance
> problems, then you really want to start afresh. That really needs to be
> designed as a long-term API, and should ideally represent the desired
> functionality in a manner that is more or less independent of the
> underlying code (something that is clearly not the case for the current
> mess of dprintks). 
I'm not sure how the trace points could independent of the underlying code,
but I do agree a well designed API would be optimal.... But before we go
off designing something I think we need to decide with the end game is.

Do we want to trace points:
    1) at all 
    2) for debugging 
    3) for performance
    4) 2 and 3

Once we get the above nailed down then we can decide how to go...

Also, Greg and Jason Baron (from Red Hat) are off working on 
improving the dprintk() that are currently exist... I would
suspect we would want to also tie in with that to see if
it would be applicable...


> Otherwise, scripts will have to be rewritten every
> time we make some minor tweak or change to the code (i.e. for every
> kernel release).
No matter how well we design this, I'm sure there will always be
a need for tweaks in the user level scripts... but we call always
leave that up to the nfs-utils maintainer....  (Doh!) 8-)

steved.
