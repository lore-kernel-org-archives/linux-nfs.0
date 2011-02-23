Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54793 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186Ab1BWSHT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 13:07:19 -0500
Message-ID: <4D654CD7.3020000@panasas.com>
Date: Wed, 23 Feb 2011 10:07:19 -0800
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: fix decode_cb_sequence4resok
References: <1298414602-17029-1-git-send-email-bhalevy@panasas.com> <EEB9D74B-D547-4C43-AC8B-B8B58EBD9A54@oracle.com> <4D653F12.8090101@panasas.com> <20110223172957.GA6238@pad.home.fieldses.org>
In-Reply-To: <20110223172957.GA6238@pad.home.fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-23 09:29, J. Bruce Fields wrote:
> On Wed, Feb 23, 2011 at 09:08:34AM -0800, Benny Halevy wrote:
>> On 2011-02-23 08:48, Chuck Lever wrote:
>>>
>>> On Feb 22, 2011, at 2:43 PM, Benny Halevy wrote:
>>>
>>>> Fix bug introduced in patch
>>>> 85a56480 NFSD: Update XDR decoders in NFSv4 callback client
>>>>
>>>> Although decode_cb_sequence4resok ignores highest slotid and target highest slotid
>>>> it must account for their space in their xdr stream when calling xdr_inline_decode
>>>
>>> The real problem is that decoding for the next operation in the compound will start too early in the buffer, because we didn't account for the ignored 8 bytes here, yes?
>>
>> Right on the spot.
> 
> So actually I guess there is another bug here, which is a subset of
> 
> 	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues#Callback_error_handling
> 
> The server should be setting the appropriate sequence flag when it
> (rightly or wrongly) things that a cb reply is garbage (not sure which
> flag off the top of my head), and pynfs should be insisting that the
> flag be set on any further sequence flags.
> 
> --b.

   SEQ4_STATUS_BACKCHANNEL_FAULT
      The server has encountered an unrecoverable fault with the
      backchannel (e.g., it has lost track of the sequence ID for a slot
      in the backchannel).  The client MUST stop sending more requests
      on the session's fore channel, wait for all outstanding requests
      to complete on the fore and back channel, and then destroy the
      session.

Right?
