From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Fri, 23 Jan 2009 13:17:15 -0500
Message-ID: <EED5C113-E675-414A-8540-A3FDD17CF6EA@oracle.com>
References: <4970B451.4080201@RedHat.com>
	<5B2817A2-B0FF-4FB5-9244-9E13C55EF6B2@oracle.com>
	<497757D1.7090908@RedHat.com>
	<F4767392-1D53-41C3-B96C-D71E3C4A6836@oracle.com>
	<49777988.6010401@RedHat.com>
	<A3A2C7E0-3403-4863-A670-862886AF9EC9@oracle.com>
	<4977A385.8000406@melbourne.sgi.com>
	<20090121225619.GI4295@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	SystemTAP <systemtap@sources.redhat.com>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Greg Banks <gnb@melbourne.sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090121225619.GI4295@fieldses.org>
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

On Jan 21, 2009, at Jan 21, 2009, 5:56 PM, J. Bruce Fields wrote:
> On Thu, Jan 22, 2009 at 09:36:53AM +1100, Greg Banks wrote:
>> Chuck Lever wrote:
>>>
>>>
>>> I think we need to visit this issue on a case-by-case basis.
>>> Sometimes dprintk is appropriate.  Sometimes printk(KERN_ERR).
>>> Sometimes a performance metric.
>> Well said.
>>
>>> Trond has always maintained that dprintk() is best for developers,  
>>> but
>>> probably inappropriate for field debugging,
>> It's not a perfect tool but it beats nothing at all.
>>> and I think that may also
>>> apply to trace points.
>> It depends on whether distros can be convinced to enable it by  
>> default,
>> and install by default any necessary userspace infrastructure.   The
>> most important thing for field debugging is Just Knowing that you  
>> have
>> all the bits necessary to perform useful debugging without having to
>> find some RPM that matches the kernel that the machine is actually
>> running now, and not the one that was present when the machine was
>> installed.
>
> On the mount case specifically: How far are we from the idea of a  
> mount
> program that can identify most problems itself?  I know its error
> reporting has gotten better....

> I suppose the main feedback mount gets right now is an error code from
> the mount system call, and that may be too narrow an interface to  
> cover
> most problems.  Is there some way we can give mount a real interface  
> it
> can use to find out this stuff instead of just dumping more strings  
> into
> the logs?

A main reason it does this rather than generate error messages on the  
terminal is that mount has to run in "background" environments.   
Mounts done at boot time do not have a controlling terminal.  A bg  
mount can drop into the background, and thus it loses its controlling  
terminal.  Automounter doesn't have a controlling terminal to begin  
with.

My feeling is that, as mount is a system tool, it should report its  
problems in the system log.  If there's a controlling terminal, report  
it there too.  But by and large it is a tool that is run most often  
without direct human intervention or monitoring.

In addition there are a lot of cases it can (and does) handle by  
itself.  Renegotiating mount option settings is one of these things.

It's a narrow interface, but I'm not sure yet it's entirely inadequate.

> My main obstacle to judging a solution is that I don't have in mind a
> good list of (say) the top 10 problems that can cause the first  
> mount to
> fail.  Hm:
>
> 	- dns lookup of the server fails
> 	- server isn't reachable
> 	- server isn't running nfs
> 	- requested path isn't known to server or isn't exported
> 	- export is there, but requires more security
> 	- user doesn't have gss credentials
> 	- file permissions on the export are wrong
> 	...

	- tcp_wrappers or iptables blocking access
	- network routing problems
	- v2/v3 server not running rpcbind or lockd

This is exactly why I want to start with some real world examples.   
Without examples we are much more likely to design something that  
isn't useful to anyone.  History (or e-mail archives) gives us a lot  
of information about what might be common problems.

I think we handle some of these cases reasonably well today, though  
they could probably stand some polish; others, like security  
configuration, are still a little new and kind of a low priority (for  
good or bad reasons) and so it is still a bit confusing.

But really, if mount can report a clear error message and suggest a  
course of corrective action, I don't think a dprintk or trace point or  
SystemTap will be of any greater help.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
