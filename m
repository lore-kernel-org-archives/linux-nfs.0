From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC Patch 08/09] NFS/RDMA client - rpcrdma protocol
 handling
Date: Fri, 24 Aug 2007 15:38:24 -0400
Message-ID: <EXNANE01MWuLn5U9T3T0000008a@exnane01.hq.netapp.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
	<EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
	<4697B233.8040205@oracle.com>
	<EXNANE01tXsL1c00goZ00000067@exnane01.hq.netapp.com>
	<46CF2721.4010403@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOezA-00023d-QX
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 12:38:26 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOezD-0004Eo-Tc
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 12:38:29 -0700
In-Reply-To: <46CF2721.4010403@oracle.com>
References: <EXNANE01jOuF1Qp4hZD00000c67@exnane01.hq.netapp.com>
	<4697A9DE.50703@oracle.com>
	<EXNANE01D8z9tTx7e4V00000c83@exnane01.hq.netapp.com>
	<4697B233.8040205@oracle.com>
	<EXNANE01tXsL1c00goZ00000067@exnane01.hq.netapp.com>
	<46CF2721.4010403@oracle.com>
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

At 02:44 PM 8/24/2007, Chuck Lever wrote:
>The name "page_is_bulk" however implies that you are marking the pages, 
>where really, you are marking the buffer.  Marking the whole buffer is 
>probably correct, but then you should probably rename the flag for clarity.

Roger. The intent is actually to just mark the "pages" array though.
The head and tail are used for headers and dribble/roundup, so can't
be bulk. For instance, they're not well-aligned nor do they have round
sizes. Maybe... page_data_is_bulk? Should it be a bit flag perhaps?

One other comment while I have the floor. The comment in xdr.h says
"array of contiguous pages". The pages themselves aren't actually
contiguous, though when used for bulk data they do represent a
set of contiguous file blocks. Should that comment be tweaked do
you think?

Tom.

>> Index: linux-2.6.22/include/linux/sunrpc/xdr.h
>> ===================================================================
>> --- linux-2.6.22.orig/include/linux/sunrpc/xdr.h
>> +++ linux-2.6.22/include/linux/sunrpc/xdr.h
>> @@ -70,7 +70,8 @@ struct xdr_buf {
>>  
>>  	struct page **	pages;		/* Array of contiguous pages */
>>  	unsigned int	page_base,	/* Start of page data */
>> -			page_len;	/* Length of page data */
>> +			page_len,	/* Length of page data */
>> +			page_is_bulk;	/* Page(s) hold bulk data only */
>>  
>>  	unsigned int	buflen,		/* Total length of storage buffer */
>>  			len;		/* Length of XDR encoded message */

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
