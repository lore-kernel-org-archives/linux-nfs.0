From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC,
	PATCH 04/35] svc: Add a max payload value to the transport
Date: Wed, 3 Oct 2007 11:18:25 -0400
Message-ID: <BD4C317A-01F3-4D2F-B486-1D280AE3EBFA@oracle.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192738.3250.6971.stgit@dell3.ogc.int>
	<8E01CAF1-5D8D-4AE5-B15D-C04983079F76@oracle.com>
	<1191342488.1565.8.camel@trinity.ogc.int>
	<20071003110932.GN21388@sgi.com>
	<1191421613.1565.100.camel@trinity.ogc.int>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
To: tom@opengridcomputing.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id62G-0004PN-4L
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:21:16 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id62I-0006ng-Ql
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:21:21 -0700
In-Reply-To: <1191421613.1565.100.camel@trinity.ogc.int>
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

On Oct 3, 2007, at 10:26 AM, Tom Tucker wrote:
> On Wed, 2007-10-03 at 21:09 +1000, Greg Banks wrote:
>> On Tue, Oct 02, 2007 at 11:28:08AM -0500, Tom Tucker wrote:
>
> [...snip...]
>
>>>
>>> The premise was that I didn't want a given thread peeking into some
>>> other processors memory, so anything needed from the class is copied
>>> into the svc_xprt structure when the transport instance is created.
>>
>> If I understand the code correctly, the only field in svc_xprt_class
>> that ever changes is the list_head used to add it to the global list,
>> which changes once when the transport module is loaded.  After that
>> all the svc_xprt_class cachelines will remain in shared state in all
>> CPUs' caches; it's effectively read-only.  Given that, there's little
>> to be concerned about.
>>
>>>
>>> Greg, help me here ;-)
>>
>> Sorry, I agree with Chuck :-/
>
> np, let's get it right. So the max_payload should remain in the
> svc_xprt_class structure.
>
> I see only one possible benefit of copying the svc_xprt_ops structure
> and that is that it saves one ptr de-reference when calling ops.  
> What's
> the consensus? Copy it, or keep a ptr?

My preference is not to copy it.

I'm not aware of any place in the kernel that copies the ops vector  
into each instance of an object, and I don't see that we have a  
strong motivation to implement something unique in this case.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
