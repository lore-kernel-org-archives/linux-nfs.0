From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Sat, 28 Mar 2009 11:20:11 +0300
Message-ID: <49CDDDBB.9060706@panasas.com>
References: <49CC40E5.2080506@panasas.com> <1238122908-6967-1-git-send-email-bhalevy@panasas.com> <20090328000552.GJ18222@fieldses.org> <E166DD1F-96CC-4F61-B215-7CE5FCEF20C4@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Trond Myklebust <trond@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19869 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752317AbZC1IVN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:21:13 -0400
In-Reply-To: <E166DD1F-96CC-4F61-B215-7CE5FCEF20C4@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 28, 2009, 3:39 +0300, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> On Mar 27, 2009, at 8:06 PM, "J. Bruce Fields" <bfields@fieldses.org>  
> wrote:
> 
>> On Fri, Mar 27, 2009 at 06:01:48AM +0300, Benny Halevy wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>>
>>> Note: the NFSv4.1 client also uses (and declares) this pointer.
>> OK.  Ack from trond?
> 
> 
> First, someone would need to remind me why it is necessary, and add  
> that justification to the changelog.

First time this is used in this patchset is here:
[PATCH 35/47] nfsd: minorversion support for the back channel

The client uses cl_private to determine the minorversion
(via a struct nfs_client *) to be set in the compound header,
and to know when to generate a SEQUENCE op.
Similarly, the server puts a struct nfs4_callback * in
there for callback compounds' CB_COMPOUND and CB_SEQUENCE.

Benny

> 
>      Trond
>>
>> --b.
>>
>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> include/linux/sunrpc/clnt.h |    1 +
>>> 1 files changed, 1 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/ 
>>> clnt.h
>>> index c39a210..928c547 100644
>>> --- a/include/linux/sunrpc/clnt.h
>>> +++ b/include/linux/sunrpc/clnt.h
>>> @@ -53,6 +53,7 @@ struct rpc_clnt {
>>>    char            cl_pathname[30];/* Path in rpc_pipe_fs */
>>>    struct vfsmount *    cl_vfsmnt;
>>>    struct dentry *        cl_dentry;    /* inode */
>>> +    void            *cl_private;    /* private data */
>>>    struct rpc_clnt *    cl_parent;    /* Points to parent of clones  
>>> */
>>>    struct rpc_rtt        cl_rtt_default;
>>>    struct rpc_timeout    cl_timeout_default;
>>> -- 
>>> 1.6.2.1
>>>
