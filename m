From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom to	svc_xprt_class
Date: Tue, 2 Oct 2007 16:29:24 -0400
Message-ID: <35565992-BEA8-41BA-A25E-723CC18FF628@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
	<4A775179-9659-41B6-999F-8316BA181152@oracle.com>
	<1191349462.1565.46.camel@trinity.ogc.int>
	<1191349842.1565.54.camel@trinity.ogc.int>
	<7FF82697-AB93-4339-AD46-CAE93E967242@oracle.com>
	<1191354906.1565.65.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: tom@opengridcomputing.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcoNV-0005QU-VW
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 13:30:05 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcoNZ-00054M-OO
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 13:30:07 -0700
In-Reply-To: <1191354906.1565.65.camel@trinity.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Oct 2, 2007, at 3:55 PM, Tom Tucker wrote:
> On Tue, 2007-10-02 at 14:47 -0400, Chuck Lever wrote:
>> On Oct 2, 2007, at 2:30 PM, Tom Tucker wrote:
>>
>>> On Tue, 2007-10-02 at 13:24 -0500, Tom Tucker wrote:
>>>> On Tue, 2007-10-02 at 12:57 -0400, Chuck Lever wrote:
>>>>> On Oct 2, 2007, at 12:29 PM, Tom Tucker wrote:
>>>>
>>>> [...snip...]
>
> [...snip...]
>
>>>
>>> Actually, I'm having second thoughts. Since the svc_xprt  
>>> structure is
>>> allocated on the rqstp thread in which the transport is going to be
>>> used, won't the memory be local to the allocating processor on a  
>>> NUMA
>>> system?
>>
>> The ops vector isn't in the svc_xprt.  It's a constant, so it's in
>> memory allocated by the kernel loader at boot time.
>>
>
> I think one of us missing something. Here's how I think it works...
>
> The svc_xprt_ops structure is a constant in kernel memory. The
> svc_xprt_class is also a constant and points to the svc_xprt_ops
> structure. The svc_xprt structure, however, is allocated via  
> kmalloc and
> contains a _copy_ of the constant svc_xprt_ops structure and a copy of
> the xcl_max_payload value. See the svc_xprt_init function.

Hence this:

+	xpt->xpt_ops = *xcl->xcl_ops;

I've never seen this kind of thing anywhere else in the kernel.  At  
the very least it deserves a special comment to explain why each  
svc_xprt keeps its own copy of the transport class methods.

> My original thinking (flawed I think) was that since the svc_xprt was
> allocated in the context of the current rqstp thread, that it would be
> allocated from processor local memory. While I think this is true,
> subsequent assignment of a rqstp thread to service a transport has no
> affinity to a particular transport. So as you say, it will likely  
> be in
> some other processors memory, so what does it matter?

I agree, I don't think currently there's any affinity between the  
svc_xprt and any requests that may be created.  If it really matters,  
you can create a rqst creation method.

> So the question in my mind, is "is it worth it to create rqstp to
> transport affinity when assigning a thread to service a transport. If
> not, then I should remove all this copy nonsense and access the  
> constant
> in svc_xprt_class directly.

If we're not already assigning socket or thread affinity to requests,  
then I don't see that it needs to be enforced via the transport  
switch interface.

>> In other words, on each request, you will need to get the address of
>> the vector from dynamically allocated memory, but the vector itself
>> (and therefore the addresses of the transport methods) will be fixed
>> and in the boot CPU's memory pool.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
