From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 08:26:02 +1100
Message-ID: <497792EA.5040405@melbourne.sgi.com>
References: <4970B451.4080201@RedHat.com>	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	<497757D1.7090908@RedHat.com>
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
>>> Why can't we simply improve the information content of the dprintks?
>>>       
>> The theory is trace point can be turned on, in production kernels,  
>> with
>> little or no performance issues...
>>     
>
> mount isn't a performance path, 
Perhaps not on the client, but when you have >6000 clients mounting
simultaneously then mount is most definitely a performance path on the
server :-)

> which is one reason I think trace  
> points might be overkill for this case.
>   

I think both dprintks and trace points are the wrong approach for
client-side mount problems.  What you really want there is good and
useful diagnostic information going unconditionally via printk().  Mount
problems happen frequently enough, and are often not the client's fault
but the server's or a firewall's, that system admins need to be able to
work out what went wrong in retrospect by looking in syslog.

But just because Steve chose an unfortunate example doesn't invalidate
his point.  There are plenty of gnarly logic paths in the NFS client and
server which need better runtime diagnostics.  On the server,  anything
involving an upcall to userspace .  On the client, silly rename or
attribute caching.
>
>> Not being an admin guy, I really don't have an answer for this... but
>> I can say since trace point are not so much of a drag on the system as
>> printks are.. with in timing issues using trace point would be a big  
>> advantage
>> over printks
>>     
>
>   
Well that argument works both ways.  Several times now I've seen
problems where a significant part of the debugging process has involved
noticing correlations between timing of dprintks and syslog messages
from other subsystems, like IPoIB or TCP.  That's harder to do if the
debug statements and printks go through separate mechanisms to userspace.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
