Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([209.198.142.2]:56586 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751729Ab1JZElo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Oct 2011 00:41:44 -0400
Message-ID: <4EA78F87.2050109@ogc.us>
Date: Tue, 25 Oct 2011 23:41:43 -0500
From: Tom Tucker <tom@ogc.us>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfsd (and lock) changes for 3.2
References: <20111025121924.GA15662@fieldses.org> <20111025123449.GB15662@fieldses.org>
In-Reply-To: <20111025123449.GB15662@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

What does RDMA Non Support mean exactly? Maybe I could help if it's a 
resource issue?

Thanks,
Tom

On 10/25/11 7:34 AM, J. Bruce Fields wrote:
> On Tue, Oct 25, 2011 at 08:19:24AM -0400, bfields wrote:
>> 	- Progress on the basic 4.1 todo's.  Thanks in particular to Mi
>> 	  Jinlong for (among other things) implementing the somewhat
>> 	  tricky DRC limit checking.
>>
>> 	  The 4.1 code is getting closer--it *might* be possible to
>> 	  finish basic 4.1 early as 3.3, at which point we could start
>> 	  on optional features (like pNFS).  But that will depend on
>> 	  people sending patches (and pynfs tests) for the remaining 4.1
>> 	  todo's.
> I've been keeping the todo list up to date here:
>
> 	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues
>
> Some of them I think are relatively straightforward--probably anyone
> with a little time could dive into them:
>
> 	- SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>
> 	- backchannel attribute negotiation
>
> 	- ACL retention bits
>
> 	- Clarify RDMA non-support
>
> Slightly trickier or open-ended; we may need to talk over design first
> before diving in:
>
> 	- Make DESTROY_SESSION wait on in-progress requests
>
> 	- current stateid
>
> 	- Check 4.0/4.1 interactions
>
> 	- Callback failure handling
>
> 	- GSS
>
> The GSS piece is probably the one I'm most worried about.  What we have
> seems sufficient for current clients, but I know it's incomplete, and
> I'm not entirely clear how much work it is to implement the minimum
> required to ensure that future kerberos-using clients won't break
> unexpectedly on upgrade to 4.1.
>
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

