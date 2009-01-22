From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Thu, 22 Jan 2009 13:04:33 +1100
Message-ID: <4977D431.1020906@melbourne.sgi.com>
References: <4970B451.4080201@RedHat.com>	
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>	
	<497757D1.7090908@RedHat.com>	
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>	
	<49777988.6010401@RedHat.com>	
	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>	
	<4977A385.8000406@melbourne.sgi.com>	
	<1232578570.7692.96.camel@heimdal.trondhjem.org>	
	<4977AB86.4030603@melbourne.sgi.com>
	<1232581675.7692.121.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1232581675.7692.121.camel@heimdal.trondhjem.org>
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
> On Thu, 2009-01-22 at 10:11 +1100, Greg Banks wrote:
>   
>> Trond Myklebust wrote:
>>     
>>> On Thu, 2009-01-22 at 09:36 +1100, Greg Banks wrote:
>>>   
>>>       
>>>> Chuck Lever wrote:
>>>>     
>>>>         
>>>>>       
>>>>>           
>>>> It depends on whether distros can be convinced to enable it by default,
>>>> and install by default any necessary userspace infrastructure.   The
>>>> most important thing for field debugging is Just Knowing that you have
>>>> all the bits necessary to perform useful debugging without having to
>>>> find some RPM that matches the kernel that the machine is actually
>>>> running now, and not the one that was present when the machine was
>>>> installed.
>>>>     
>>>>         
>>> Which is precisely why dprintk() is such a bad choice as a basis for a
>>> set of trace points: every new patch and bugfix that the distro applies
>>> will result in a reshuffling of the trace points as code is cleaned up
>>> and moved around or removed entirely.
>>>   
>>>       
>> Yes, if the filename and line number were the only information going
>> out.  The dprintk() format is usually enough (ignoring the patchy
>> quality of the current dprintk set)  to give a developer enough clue
>> about which dprintk is which.  Or am I missing something?
>>     
>
> The current dprintk() set was never designed to be anything other than a
> logging tool with a very coarse filter (the bitmask
> in /proc/sys/sunrpc/*_debug). It was designed to be human-readable only
> (no fixed format).
>
> As I understand it, you are not only proposing to make that filter
> extremely fine (individually addressable trace points), but also to
> enable the application of scripting tools like systemtap and LTTng in
> order to provide bespoke debugging of your customer problems. Have I
> misunderstood you, or is that correct?
>   

These are two separate proposals between which we're trying to find some
commonality.

In my proposal, the dprintk()s remain designed primarily for humans
(support staff or kernel developers) to read in conjunction with the
correct source code, but control is made fine-grain to make the
mechanism more controllable.  This can be done regardless of whether
trace points are involved and regardless of whether we attempt to
support scripts.

Changing dprintk() to add a trace point is just a way to get some trace
points with strictly minimum changes to callsites.

Replacing dprintk()s with new trace points has more or less the same
result but means more futzing with callsites.

> The question then is how is this going to work out in an environment
> where the individually addressable trace points/dprintk()s pop in and
> out of existence at the whim of a patch, and where the output format is
> similarly volatile?
> IOW: I'm referring to the difference between an interface that was
> designed purely to be interpreted by humans, and one that is designed
> from scratch to be interpreted by scripts.
>
>   

The maintenance problem of correlating any kind of instrumentation point
in kernel code with scripts living out in userspace exists regardless of
how you choose to implement the instrumentation.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
