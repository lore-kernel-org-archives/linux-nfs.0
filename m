From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/2] decode_cb_op_status fix
Date: Tue, 18 Jan 2011 16:59:17 -0500
Message-ID: <639E1645-DD1A-4D70-88C1-C90E4889EBA6@oracle.com>
References: <4D2EC4AC.9090205@panasas.com> <20110118215744.GD10903@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v1082)
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:50052 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751440Ab1ARV7x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 16:59:53 -0500
In-Reply-To: <20110118215744.GD10903@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I never saw these.  Can you resend?

On Jan 18, 2011, at 4:57 PM, J. Bruce Fields wrote:

> On Thu, Jan 13, 2011 at 11:23:56AM +0200, Benny Halevy wrote:
>> Chuck, it looks like the following patch introduced a couple in
>> handling of the operation status.
>> 
>> 85a5648 NFSD: Update XDR decoders in NFSv4 callback client
>> 
>> The first patch in this series fixes the bugs and the second
>> reintroduces the handling of nfserr into decode_cb_op_status
>> as it used to be in decode_cb_op_hdr, since I think it's simpler
>> with respect to the current usage (vs. theoretical generic use of
>> decode_cb_op_status to decode the status and return it in an output var).
> 
> Looks OK to me, thanks.
> 
> --b.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




