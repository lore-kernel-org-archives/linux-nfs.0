From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] nfsd: permit unauthenticated stat of export root
Date: Mon, 11 Aug 2008 17:29:41 -0400
Message-ID: <48A0AF45.8050306@redhat.com>
References: <20080807181148.GK18904@fieldses.org> <489B3DAC.5060004@redhat.com> <20080807191656.GL18904@fieldses.org> <489B4F81.8000204@redhat.com> <20080807204154.GR18904@fieldses.org> <20080808202106.GR15265@fieldses.org> <48A0A64E.1080508@redhat.com> <20080811212640.GB7550@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751052AbYHKVki (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Aug 2008 17:40:38 -0400
In-Reply-To: <20080811212640.GB7550@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Mon, Aug 11, 2008 at 04:51:26PM -0400, Peter Staubach wrote:
>   
>> The Solaris client behaves plus or minus like the Linux client.
>> It generates a GETATTR unless it receives the attributes via
>> one of the previous calls.  In the Solaris case, it is an FSINFO
>> call.
>>
>> The current Linux NFS server does not return attributes for the
>> PATHCONF, FSINFO, or FSSTAT calls.
>>     
>
> Hm.  I don't know why that is.
>
>   
>> Unless these calls are modified, then the NFSv3 GETATTR will need
>> to be allowed for the same reason that the NFSv2 GETATTR is
>> allowed.  The NFS client needs, at the very least, the file type
>> of the node that it is mounting.
>>
>> I am confused as to how the testing could have been successful.
>>     
>
> Well, you can try exporting a filesystem with sec=krb5:krb5i:krb5p (no
> sys) and try mounting v2 or v3, and you'll see that if fails without the
> patch, and succeeds with it.
>
> But testing again (linux client and server), and taking a network trace
> this time: I mount with -overs=3,sec=krb5, and the client behavior is
> odd:
>
> 	FSINFO call with auth_sys
> 	GETATTR call with krb5
> 	FSINFO call with krb5
>
> Note that this client actually *does* have access to kerberos
> credentials--it's just not using them on the initial FSINFO call.
>
>   

What happens if you perform this mount using autofs?

    Thanx...

       ps

> That could make some sense if it was trying to ensure the mount will
> succeed in the absence of kerberos credentials, and doesn't want to
> bother first trying to get a credentials and then falling back on
> auth_sys if it doesn't find them.
>
> But currently it fails if the server requests auth_sys on the initial
> FSINFO *or* if it fails to get kerberos credentials for those second two
> rpc calls.  Something similar seems to be true for v2.  Huh.
>
> Anyway, so in the Solaris v3 case I take it that what you're seeing is
> FSINFO, GETATTR, both done with auth_sys, and a failure of the mount
> command if both aren't permitted?
>
> OK, so I agree the server should either permit v3 GETATTR (trivial, if
> arguably contrary to rfc 2623) or add attributes to FSINFO (which I
> assume is also easy, but I don't know why it was left out before).
> Seems the client needs some looking at too.
>
> --b.
>   

