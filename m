From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:39:53 -0400
Message-ID: <4A8F0619.60305@redhat.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com> <20090821200403.GA23529@fieldses.org> <4A8F0118.60705@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65154 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932602AbZHUUkD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 16:40:03 -0400
In-Reply-To: <4A8F0118.60705-xsfywfwIY+M@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Haynes wrote:
> J. Bruce Fields wrote:
>>
>>> Right now, we use AUTH_SYS if the mount command didn't specify a
>>> flavor, but the flavor we're going to use is always checked against
>>> the server's returned list.  You seem to be suggesting we should
>>> ignore the server's list entirely if sec= was specified...?
>>>     
>>
>> Yes.  I can't see what practical problems that would cause.
>>

Here, I am going to disagree.  The client should compare the
flavor specified with the list of authentication flavors
returned by the server and if the specific flavor isn't on
the list, then the mount attempt should be failed.

>> Also, while I hope this is the last bug in the mountd's flavor list
>> return, it isn't the first--only recently did we even start using real
>> information from the export instead of just faking something up.  So I
>> think it's safest to preserve the historical sec= behavior and give
>> users a way to override the negotiation, to cut down on bug reports of
>> mount failures on upgrade.
>>
>> --b.
>>   
> 
> 
> While this Linux behavior occasionally bites the OpenSolaris behavior, it
> really means we just have to guard against the client ignoring what we
> sent.
> I.e., if I say we only support krb5 and you try with AUTH_SYS, I should
> reject it.
> 

Which should happen correctly, right?

		ps

> Historical inertia is hard to overcome, but perhaps you could gradually
> ease your way into using the real data. :->
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

