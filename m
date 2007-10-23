From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 1/4] svc: Fix skip computation in svc_defer and svc_revisit
Date: Mon, 22 Oct 2007 22:11:44 -0500
Message-ID: <471D6670.5050704@opengridcomputing.com>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
	<20071019214523.31422.28978.stgit@dell3.ogc.int>
	<20071023024530.GB6354@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkABN-00060x-Tl
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 20:12:01 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IkABT-0001lM-4x
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 20:11:59 -0700
In-Reply-To: <20071023024530.GB6354@sgi.com>
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

Greg Banks wrote:
> On Fri, Oct 19, 2007 at 04:45:23PM -0500, Tom Tucker wrote:
>   
>> The rq_arg.len includes the size of the transport header. The computations
>> assumed that it did not.
>>     
>
> ok, assuming that your latest svc_rdma_xdr_decode_req(), which I
> haven't read yet, doesn't change rq_arg.len as it parses the RDMA
> chunking header.
>
> The reason I mention that is that one set of patches I was working
> with some time ago had different semantics for rq_arg.len; when
> parsing the chunking header, rq_arg.len was adjusted downward as
> rq_head[0].iov_base was adjusted forward.  This kept rq_arg.len equal
> to the sum of rq_{head[0],pages[...],tail[0]}.iov_len, which seemed
> like a good idea.
>
> But your way seems valid too.
>
>   
Well to be honest, I'm somewhat conflicted. The TCP transport driver 
doesn't include the transport header in rq_arg.len. For the RDMA 
transport, however, there was a lot more parsing involved with the 
transport header and I wanted to keep rq_arg.len inclusive in order to 
enable more robust error checking for short messages, etc...

So right now, it's mixed, but since TCP doesn't save it's transport 
header, it doesn't matter. So to cut to the chase here, the design 
decision being made is that any transport that needs to save it's 
transport header _must_ include the transport header in the rq_arg.len

Tom
> Greg.
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
