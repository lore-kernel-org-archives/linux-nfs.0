Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006Ab3IZQr4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 12:47:56 -0400
Message-ID: <524464E6.2060006@redhat.com>
Date: Thu, 26 Sep 2013 12:46:30 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Miklos Szeredi <miklos@szeredi.hu>, Zach Brown <zab@redhat.com>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
References: <1378919210-10372-1-git-send-email-zab@redhat.com> <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com> <20130925183828.GA30372@lenny.home.zabbo.net> <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com> <20130925190620.GB30372@lenny.home.zabbo.net> <20130925195526.GA18971@fieldses.org> <20130925210742.GG30372@lenny.home.zabbo.net> <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com> <20130926153359.GE704@fieldses.org>
In-Reply-To: <20130926153359.GE704@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/26/2013 11:34 AM, J. Bruce Fields wrote:
> On Thu, Sep 26, 2013 at 10:58:05AM +0200, Miklos Szeredi wrote:
>> On Wed, Sep 25, 2013 at 11:07 PM, Zach Brown <zab@redhat.com> wrote:
>>>> A client-side copy will be slower, but I guess it does have the
>>>> advantage that the application can track progress to some degree, and
>>>> abort it fairly quickly without leaving the file in a totally undefined
>>>> state--and both might be useful if the copy's not a simple constant-time
>>>> operation.
>>> I suppose, but can't the app achieve a nice middle ground by copying the
>>> file in smaller syscalls?  Avoid bulk data motion back to the client,
>>> but still get notification every, I dunno, few hundred meg?
>> Yes.  And if "cp"  could just be switched from a read+write syscall
>> pair to a single splice syscall using the same buffer size.
> Will the various magic fs-specific copy operations become inefficient
> when the range copied is too small?
>
> (Totally naive question, as I have no idea how they really work.)
>
> --b.

I think that is not really possible to tell when we invoke it. It is very much 
target device (or file system, etc) dependent on how long it takes. It could be 
as simple as a reflink copying in a smallish amount of metadata or fall back to 
a full byte-by-byte copy.  Also note that speed is not the only impact here, 
some of the mechanisms actually do not consume more space (just increment shared 
data references).

It would probably make more sense to send it off to the target device and have 
it return an error when not appropriate (then the app can fall back to the old 
fashion copy).

ric

>
>> And then
>> the user would only notice that things got faster in case of server
>> side copy.  No problems with long blocking times (at least not much
>> worse than it was).
>>
>> However "cp" doesn't do reflinking by default, it has a switch for
>> that.  If we just want "cp" and the like to use splice without fearing
>> side effects then by default we should try to be as close to
>> read+write behavior as possible.  No?   That's what I'm really
>> worrying about when you want to wire up splice to reflink by default.
>> I do think there should be a flag for that.  And if on the block level
>> some magic happens, so be it.  It's not the fs deverloper's worry any
>> more ;)
>>
>> Thanks,
>> Miklos
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

