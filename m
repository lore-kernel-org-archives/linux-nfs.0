Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753886Ab3IZV1w (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Sep 2013 17:27:52 -0400
Message-ID: <5244A68F.906@redhat.com>
Date: Thu, 26 Sep 2013 17:26:39 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: Zach Brown <zab@redhat.com>
CC: Miklos Szeredi <miklos@szeredi.hu>,
        "J. Bruce Fields" <bfields@fieldses.org>,
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
References: <1378919210-10372-1-git-send-email-zab@redhat.com> <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com> <20130925183828.GA30372@lenny.home.zabbo.net> <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com> <20130925190620.GB30372@lenny.home.zabbo.net> <20130925195526.GA18971@fieldses.org> <20130925210742.GG30372@lenny.home.zabbo.net> <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com> <20130926185508.GO30372@lenny.home.zabbo.net>
In-Reply-To: <20130926185508.GO30372@lenny.home.zabbo.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/26/2013 02:55 PM, Zach Brown wrote:
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
>> pair to a single splice syscall using the same buffer size.  And then
>> the user would only notice that things got faster in case of server
>> side copy.  No problems with long blocking times (at least not much
>> worse than it was).
> Hmm, yes, that would be a nice outcome.
>
>> However "cp" doesn't do reflinking by default, it has a switch for
>> that.  If we just want "cp" and the like to use splice without fearing
>> side effects then by default we should try to be as close to
>> read+write behavior as possible.  No?
> I guess?  I don't find requiring --reflink hugely compelling.  But there
> it is.
>
>> That's what I'm really
>> worrying about when you want to wire up splice to reflink by default.
>> I do think there should be a flag for that.  And if on the block level
>> some magic happens, so be it.  It's not the fs deverloper's worry any
>> more ;)
> Sure.  So we'd have:
>
> - no flag default that forbids knowingly copying with shared references
>    so that it will be used by default by people who feel strongly about
>    their assumptions about independent write durability.
>
> - a flag that allows shared references for people who would otherwise
>    use the file system shared reference ioctls (ocfs2 reflink, btrfs
>    clone) but would like it to also do server-side read/write copies
>    over nfs without additional intervention.
>
> - a flag that requires shared references for callers who don't want
>    giant copies to take forever if they aren't instant.  (The qemu guys
>    asked for this at Plumbers.)
>
> I think I can live with that.
>
> - z

This last flag should not prevent a remote target device (NFS or SCSI array) 
copy from working though since they often do reflink like operations inside of 
the remote target device....

ric


