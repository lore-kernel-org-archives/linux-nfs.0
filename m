From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 03/27] SUNRPC: Check a return result
Date: Tue, 30 Oct 2007 12:59:18 -0400
Message-ID: <EXNANE01R6mJB526tr500000845@exnane01.hq.netapp.com>
References: <20071026173054.31475.61789.stgit@manray.1015granger.net>
	<Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
	<472760AA.2010901@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImuRE-0003Lz-5H
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:59:36 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImuRH-0006NU-La
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:59:41 -0700
In-Reply-To: <472760AA.2010901@oracle.com>
References: <20071026173054.31475.61789.stgit@manray.1015granger.net>
	<Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
	<472760AA.2010901@oracle.com>
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

At 12:49 PM 10/30/2007, Chuck Lever wrote:
>I added "err" because it appeared that the intention of the original 
>logic was to ignore the return code from ib_destroy_cq() completely. 
>Thus re-using "rc" would have made rpcrdma_ep_create() return an 
>unnecessary error in cases where it hadn't before.

Which would be bad, mounts would fail for no reason. Your fix is
correct - though really all the code needs is (void). Unfortunately
when I coded that, some tool whined, I forget which. Anyway,
dprintk'ing the message is better.

Tom.

>
>> Signed-off-by: James Lentini <jlentini@netapp.com>
>> 
>>  verbs.c |    6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>> 
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep,
>>  	return 0;
>>  
>>  out2:
>> -	if (ib_destroy_cq(ep->rep_cq))
>> -		;
>> +	rc = ib_destroy_cq(ep->rep_cq);
>> +	if (rc)
>> +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
>> +			__func__, rc);
>>  out1:
>>  	return rc;
>>  }
>
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
