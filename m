From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Sat, 28 Mar 2009 20:29:17 +0300
Message-ID: <49CE5E6D.7080806@panasas.com>
References: <49CC40E5.2080506@panasas.com>	 <1238122908-6967-1-git-send-email-bhalevy@panasas.com>	 <20090328000552.GJ18222@fieldses.org>	 <E166DD1F-96CC-4F61-B215-7CE5FCEF20C4@netapp.com>	 <49CDDDBB.9060706@panasas.com> <1238261035.6679.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:11118 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753024AbZC1R30 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 13:29:26 -0400
In-Reply-To: <1238261035.6679.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 28, 2009, 20:23 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Sat, 2009-03-28 at 11:20 +0300, Benny Halevy wrote:
>> On Mar. 28, 2009, 3:39 +0300, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>> On Mar 27, 2009, at 8:06 PM, "J. Bruce Fields" <bfields@fieldses.org>  
>>> wrote:
>>>
>>>> On Fri, Mar 27, 2009 at 06:01:48AM +0300, Benny Halevy wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>
>>>>> Note: the NFSv4.1 client also uses (and declares) this pointer.
>>>> OK.  Ack from trond?
>>>
>>> First, someone would need to remind me why it is necessary, and add  
>>> that justification to the changelog.
>> First time this is used in this patchset is here:
>> [PATCH 35/47] nfsd: minorversion support for the back channel
>>
>> The client uses cl_private to determine the minorversion
>> (via a struct nfs_client *) to be set in the compound header,
>> and to know when to generate a SEQUENCE op.
>> Similarly, the server puts a struct nfs4_callback * in
>> there for callback compounds' CB_COMPOUND and CB_SEQUENCE.
> 
> Why would the rpc_client need to know and track minor versions? That is
> an NFS protocol specific thing.

Agreed.  the rpc_client doesn't know anything about the minor version.
This is why we store it in a void *cl_private.

> 
> Besides, the caller should always know what minor version it is using.
> It shouldn't need a back-pointer in the rpc_client...
> 

The back pointer is used in the xdr layer like this:
 	struct xdr_stream xdr;
+	struct nfs_client *clp =
+		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.nops = 0,
+		.minorversion = clp->cl_minorversion,
 	};

Benny
