Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp01.online.nl ([194.134.41.31]:58661 "EHLO smtp01.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752661Ab1DOHP6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Apr 2011 03:15:58 -0400
Message-ID: <20110415091555.15611t1y2vd6b3jf@vovan.nl>
Date: Fri, 15 Apr 2011 09:15:55 +0200
From: Vladimir Elisseev <vovan@vovan.nl>
To: "Finney, Sean" <Sean.Finney@sonyericsson.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client
 side
References: <20110415010913@it-loops.com>
 <1302840158.2447.5.camel@vovan.net.home>
 <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
In-Reply-To: <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
Content-Type: text/plain;
 charset=ISO-8859-1;
 DelSp="Yes";
 format="flowed"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sean,

I'm pretty sure this is not the case for my environment, as we have  
less then 100 groups in total.

Regards,
Vladimir.

Quoting "Finney, Sean" <Sean.Finney@sonyericsson.com>:

> Hi guys,
>
> On Fri, 2011-04-15 at 06:02 +0200, Vladimir Elisseev wrote:
>> Michael,
>>
>> I've posted an email with the same question here a few weeks ago, but I
>> haven't been able to investigate what the problem is. The only
>> difference in my setup, that servers have kernel 2.6.36 the rest is
>> exactly the same and exactly the same error. See thread with the subject
>> "rpc.svcgssd problem after updating client 1.2.2->1.2.3".
>
> I think the problem here is the same one we were experiencing, with
> large group memberships causing invalid writes to the procfs rpc channel
> files.  If you strace rpc.svcgssd (or rpc.mountd, you should see it
> there too I think), you should see the write() calls being split into
> multiple 1024-byte sized writes, each of which get EINVAL (or -EINVAL, I
> forget) returned.
>
> I've submitted a patch for that last week, which is waiting on
> inclusion.  If you want to verify, please look back in the archive and
> try the patch submitted in the mail with subject:
>
> [PATCH v2] nfs-utils: Increase the stdio file buffer size for procfs
> files
>
> It seems to work here, I'd appreciate if you could try it out and let me
> know if it works for you too :)
>
>
> BR
> 	Sean
>




