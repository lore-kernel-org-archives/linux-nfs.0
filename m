From: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 15:18:32 -0500
Message-ID: <4A8F0118.60705@sun.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org>
 <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com>
 <20090821182418.GE21043@fieldses.org>
 <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
 <20090821200403.GA23529@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-4.Sun.COM ([192.18.98.36]:57971 "EHLO
	brmea-mail-4.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932390AbZHUUTJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Aug 2009 16:19:09 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-4.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7LKJAG1010427
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2009 20:19:11 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOQ00800TCKUJ00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Fri,
 21 Aug 2009 14:19:10 -0600 (MDT)
In-reply-to: <20090821200403.GA23529@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
>
>> Right now, we use AUTH_SYS if the mount command didn't specify a flavor, 
>> but the flavor we're going to use is always checked against the server's 
>> returned list.  You seem to be suggesting we should ignore the server's 
>> list entirely if sec= was specified...?
>>     
>
> Yes.  I can't see what practical problems that would cause.
>
> Also, while I hope this is the last bug in the mountd's flavor list
> return, it isn't the first--only recently did we even start using real
> information from the export instead of just faking something up.  So I
> think it's safest to preserve the historical sec= behavior and give
> users a way to override the negotiation, to cut down on bug reports of
> mount failures on upgrade.
>
> --b.
>   


While this Linux behavior occasionally bites the OpenSolaris behavior, it
really means we just have to guard against the client ignoring what we sent.
I.e., if I say we only support krb5 and you try with AUTH_SYS, I should
reject it.

Historical inertia is hard to overcome, but perhaps you could gradually
ease your way into using the real data. :->
