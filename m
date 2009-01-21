From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 10:11:02 +1100
Message-ID: <4977AB86.4030603@melbourne.sgi.com>
References: <4970B451.4080201@RedHat.com>	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	<497757D1.7090908@RedHat.com>	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>	<49777988.6010401@RedHat.com>	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>	<4977A385.8000406@melbourne.sgi.com>
	<1232578570.7692.96.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1232578570.7692.96.camel@heimdal.trondhjem.org>
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
> On Thu, 2009-01-22 at 09:36 +1100, Greg Banks wrote:
>   
>> Chuck Lever wrote:
>>     
>>>
>>>       
>> It depends on whether distros can be convinced to enable it by default,
>> and install by default any necessary userspace infrastructure.   The
>> most important thing for field debugging is Just Knowing that you have
>> all the bits necessary to perform useful debugging without having to
>> find some RPM that matches the kernel that the machine is actually
>> running now, and not the one that was present when the machine was
>> installed.
>>     
>
> Which is precisely why dprintk() is such a bad choice as a basis for a
> set of trace points: every new patch and bugfix that the distro applies
> will result in a reshuffling of the trace points as code is cleaned up
> and moved around or removed entirely.
>   
Yes, if the filename and line number were the only information going
out.  The dprintk() format is usually enough (ignoring the patchy
quality of the current dprintk set)  to give a developer enough clue
about which dprintk is which.  Or am I missing something?

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
