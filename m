From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] 3-word attributes encoding
Date: Tue, 31 Mar 2009 21:36:08 +0300
Message-ID: <49D26298.6070507@panasas.com>
References: <49D0D931.2060808@panasas.com> <20090331014439.GA7273@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:12163 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753882AbZCaSgO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 14:36:14 -0400
In-Reply-To: <20090331014439.GA7273@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 31, 2009, 4:44 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Mar 30, 2009 at 05:37:37PM +0300, Benny Halevy wrote:
>> Bruce,
>>
>> As I mentioned in a reply to Trond,
>> "nfsd41: support for 3-word long attribute bitmask"
>> changes the server fattr encoding logic so it may send
>> back a bitmap of length 1, even if the client sent a
>> bitmap of length 2, if the second word of the bitmap
>> is zero.  Although I think this a valid implementation
>> and other servers may do the same, it seems sub-optimal
>> for the client's decoding of acl of fs_locations.
> 
> "suboptimal" means it does some extra memcpy'ing?

Yes, I believe so.

> 
>> It's pretty easy to revert to the old behavior on the server
>> by always returning at least two bitmap words, or, if we
>> keep the bitmap length, not just the val, in nfsd4_decode_bitmap
>> we can return a bitmap of the same length in the reply.
> 
> Odd thing to have to do, but OK. --b.  

What would you prefer to do?
Revert to old behavior by returning at least two bitmap words
or use the args bitmap length for encoding the res?

Benny

> 
>> Let me know what you think...
>>
>> Other than that,
>> git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30
>> holds version 3 of the nfsd41 patchset, rebased onto your
>> update for-2.6.30 branch, and with these cleanup patches squashed-in:
>>
>> [PATCH 1/3] SQUASHME: get callback minorversion from fore channel's
>> [PATCH 2/3] SQUASHME: nfsd41: use nfsd4_cb_sequence for callback minorversion
>> [PATCH 3/3] SQUASHME: Revert "sunrpc: add cl_private field to struct rpc_clnt"
>>
>> Benny
>> _______________________________________________
>> pNFS mailing list
>> pNFS@linux-nfs.org
>> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
