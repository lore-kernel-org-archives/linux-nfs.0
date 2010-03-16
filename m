From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: [PATCH 01/22] gss_krb5: introduce encryption type framework
Date: Tue, 16 Mar 2010 16:45:36 -0500
Message-ID: <4d569c331003161445v675f8d51v3f588d2f9f0d7e75@mail.gmail.com>
References: <1268655627-18712-1-git-send-email-steved@redhat.com>
	 <1268655627-18712-2-git-send-email-steved@redhat.com>
	 <1268668733.2993.90.camel@localhost.localdomain>
	 <4B9FEEE0.8040306@RedHat.com>
	 <1268774075.3098.56.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:63587 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102Ab0CPVvJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Mar 2010 17:51:09 -0400
Received: by bwz3 with SMTP id 3so503447bwz.29
        for <linux-nfs@vger.kernel.org>; Tue, 16 Mar 2010 14:51:07 -0700 (PDT)
In-Reply-To: <1268774075.3098.56.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 16, 2010 at 4:14 PM, Trond Myklebust
<trond.myklebust@fys.uio.no> wrote:
> On Tue, 2010-03-16 at 16:49 -0400, Steve Dickson wrote:
>>
>> On 03/15/2010 11:58 AM, Trond Myklebust wrote:
>> > On Mon, 2010-03-15 at 08:20 -0400, steved@redhat.com wrote:

>> >> +
>> >> + =A0GSS_KRB5_SLACK_CHECK;
>> > =A0 =A0 =A0 =A0 =A0 ^^^^^^^^^^^^^^^^^^^^^
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 Why is this a macro?
>> To hide the ugliness of the BUILD_BUG_ON() macro which I think
>> is a good thing... I would rather see that one line verse the 10
>> or so lines it hiding...
>
> I wouldn't.
>
> I can accept putting that _sum_ into a macro, but expanding the
> BUILD_BUG_ON.
>
> IOW:
>
> #define GSS_KRB5_MAX_SLACK_NEEDED \
> =A0 =A0 =A0 =A0GSS_KRB5_TOK_HDR_LEN =A0 =A0 =A0/* gss token header */=
 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0+ GSS_KRB5_MAX_CKSUM_LEN =A0/* gss token checksum */ =A0=
 =A0 =A0 \
> =A0 =A0 =A0 =A0+ GSS_KRB5_MAX_BLOCKSIZE =A0/* confounder */ =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0.... \
> =A0 =A0 =A0 =A0)
>
> and then inserting the following line above
>
> BUILD_BUG_ON(GSS_KRB5_MAX_SLACK_NEEDED > RPC_MAX_AUTH_SIZE);
>
> That makes it obvious what is being checked and why.

fwiw, I agree!

> Speaking of obvious. Exactly why is GSS_KRB5_TOK_HDR_LEN and
> GSS_KRB5_MAX_CKSUM_LEN being included twice in that calculation? The
> second two instances have no comments explaining their presence...

I'll look back and see if there is a reason, or if this is just wrong.
 I believe there is another checksum, so I think it is correct.  But
supporting comments do seem necessary.

I'll be travelling with limited network access until Monday, so I
might not give a prompt reply.

K.C.
