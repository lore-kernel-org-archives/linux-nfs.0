From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC][PATCH 0/5] NFS: trace points added to mounting path
Date: Wed, 21 Jan 2009 11:39:56 -0500
Message-ID: <49774FDC.5090307@RedHat.com>
References: <49711BDF.3010605@melbourne.sgi.com>
	<x49ab9ntlpp.fsf@segfault.boston.devel.redhat.com>
	<20090121101329.GA4876@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	SystemTAP <systemtap@sources.redhat.com>
To: prasad@linux.vnet.ibm.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090121101329.GA4876@in.ibm.com>
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

K.Prasad wrote:
> On Mon, Jan 19, 2009 at 09:27:30AM -0500, Jeff Moyer wrote:
>> Greg Banks <gnb@melbourne.sgi.com> writes:
>>
>>> Steve Dickson wrote:
>>>> So the ultimate goal would be to replace all the dprintks with trace points
>>>> but still be able to enable them through the rpcdebug command
>>> I have a patch which changes the definition of the dprintk() macro (but
>>> *not* dprintk() callsites) to allow enabling and disabling individual
>>> dprintk() statements through a /proc/ interface.  Would you be
>>> interested in that?
>> That sounds like duplicated work.  How does it differ from Jason Baron's
>> dynamic printk patches (which I believe are now upstream)?
>>
>> Cheers,
>> Jeff
> 
> Introducing/converting one of the accepted methods of static
> instrumentation - like tracepoints would help more users (whether
> in-kernel or otherwise) harness them.
> 
> Steve,
> 	Would it help convert the systemtap script (nfs_mount.stp) in
> Patch - 5 into a kernel module (perhaps in samples/ directory) to bring
> an in-kernel user of these tracepoints?
Well nfs_mount.stp was just an example of how to pull the information
from the kernel.. I just wanted to complete the loop... but as 
Christoph pointed out it probably shouldn't been included in the posting.

I'm not sure moving the nfs_mount.stp script into kernel 
would make sense. One of the advantages of trace point and system
scripts (depending on what is passed up) it allows users to define
exactly what they need to see.. 

For example, a kernel guy might be interested in a particular bit in a flag 
field which would be meaningless to an IT guy. On the other hand, the IT guy 
would be interested in the error code. One trace point could supply all the
information but different systemtap scripts would be need to show the 
desired information.

My point being, if we move things down into the kernel, I think we would
lose this type of flexibly...

steved.
