From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/27] SUNRPC: Check a return result
Date: Tue, 30 Oct 2007 12:49:46 -0400
Message-ID: <472760AA.2010901@oracle.com>
References: <20071026173054.31475.61789.stgit@manray.1015granger.net>
	<Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070608010200010003060003"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: James Lentini <jlentini@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImuIU-0002Nb-8B
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:50:34 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1ImuIX-0002H8-JI
	for nfs@lists.sourceforge.net; Tue, 30 Oct 2007 09:50:40 -0700
In-Reply-To: <Pine.LNX.4.64.0710301232070.32008@jlentini-linux.nane.netapp.com>
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

This is a multi-part message in MIME format.
--------------070608010200010003060003
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit

James Lentini wrote:
> On Fri, 26 Oct 2007, Chuck Lever wrote:
> 
>> Minor: Replace an empty if statement with a debugging dprintk.
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Cc: Thomas Talpey <Thomas.Talpey@netapp.com>
>> ---
>>
>>  net/sunrpc/xprtrdma/verbs.c |    8 +++++---
>>  1 files changed, 5 insertions(+), 3 deletions(-)
>>
>> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
>> index 44b0fb9..ffbf22a 100644
>> --- a/net/sunrpc/xprtrdma/verbs.c
>> +++ b/net/sunrpc/xprtrdma/verbs.c
>> @@ -522,7 +522,7 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>>  				struct rpcrdma_create_data_internal *cdata)
>>  {
>>  	struct ib_device_attr devattr;
>> -	int rc;
>> +	int rc, err;
>>  
>>  	rc = ib_query_device(ia->ri_id->device, &devattr);
>>  	if (rc) {
>> @@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
>>  	return 0;
>>  
>>  out2:
>> -	if (ib_destroy_cq(ep->rep_cq))
>> -		;
>> +	err = ib_destroy_cq(ep->rep_cq);
>> +	if (err)
>> +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
>> +			__func__, err);
>>  out1:
>>  	return rc;
>>  }
> 
> Good eyes, Chuck. One minor suggestion: instead of adding "err", how 
> about reusing "rc"? Here's a patch against Trond's nfs-2.6 tree.

I added "err" because it appeared that the intention of the original 
logic was to ignore the return code from ib_destroy_cq() completely. 
Thus re-using "rc" would have made rpcrdma_ep_create() return an 
unnecessary error in cases where it hadn't before.

> Signed-off-by: James Lentini <jlentini@netapp.com>
> 
>  verbs.c |    6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -648,8 +648,10 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep,
>  	return 0;
>  
>  out2:
> -	if (ib_destroy_cq(ep->rep_cq))
> -		;
> +	rc = ib_destroy_cq(ep->rep_cq);
> +	if (rc)
> +		dprintk("RPC:       %s: ib_destroy_cq returned %i\n",
> +			__func__, rc);
>  out1:
>  	return rc;
>  }

--------------070608010200010003060003
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070608010200010003060003
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------070608010200010003060003
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------070608010200010003060003--
