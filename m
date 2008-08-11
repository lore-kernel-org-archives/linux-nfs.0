From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Mon, 11 Aug 2008 18:11:49 -0400
Message-ID: <20080811221149.GD7550@fieldses.org>
References: <20080807181148.GK18904@fieldses.org> <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org> <489B4F81.8000204@redhat.com> <20080807204154.GR18904@fieldses.org> <20080808202106.GR15265@fieldses.org> <48A0A64E.1080508@redhat.com> <20080811212640.GB7550@fieldses.org> <48A0AF45.8050306@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:32984 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452AbYHKWLu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 18:11:50 -0400
In-Reply-To: <48A0AF45.8050306@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 11, 2008 at 05:29:41PM -0400, Peter Staubach wrote:
> J. Bruce Fields wrote:
>> On Mon, Aug 11, 2008 at 04:51:26PM -0400, Peter Staubach wrote:
>>   
>>> The Solaris client behaves plus or minus like the Linux client.
>>> It generates a GETATTR unless it receives the attributes via
>>> one of the previous calls.  In the Solaris case, it is an FSINFO
>>> call.
>>>
>>> The current Linux NFS server does not return attributes for the
>>> PATHCONF, FSINFO, or FSSTAT calls.
>>>     
>>
>> Hm.  I don't know why that is.
>>
>>   
>>> Unless these calls are modified, then the NFSv3 GETATTR will need
>>> to be allowed for the same reason that the NFSv2 GETATTR is
>>> allowed.  The NFS client needs, at the very least, the file type
>>> of the node that it is mounting.
>>>
>>> I am confused as to how the testing could have been successful.
>>>     
>>
>> Well, you can try exporting a filesystem with sec=krb5:krb5i:krb5p (no
>> sys) and try mounting v2 or v3, and you'll see that if fails without the
>> patch, and succeeds with it.
>>
>> But testing again (linux client and server), and taking a network trace
>> this time: I mount with -overs=3,sec=krb5, and the client behavior is
>> odd:
>>
>> 	FSINFO call with auth_sys
>> 	GETATTR call with krb5
>> 	FSINFO call with krb5
>>
>> Note that this client actually *does* have access to kerberos
>> credentials--it's just not using them on the initial FSINFO call.
>>
>>   
>
> What happens if you perform this mount using autofs?

I haven't tried yet.

--b.
