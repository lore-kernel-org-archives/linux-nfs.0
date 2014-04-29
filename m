Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f51.google.com ([209.85.216.51]:47105 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933004AbaD2LP5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 07:15:57 -0400
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <20140429071153.176c7404@tlielax.poochiereds.net>
References: <535F651E.6090204@gmail.com> <535F670B.4060704@gmail.com> <20140429071153.176c7404@tlielax.poochiereds.net>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Tue, 29 Apr 2014 13:15:37 +0200
Message-ID: <CAKgNAkgUbdKFaZrXGsWimEA214GDA94=gkAGDBUEdTX=mudM6w@mail.gmail.com>
Subject: Re: OFD ("file private") locks and NFS
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        lkml <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        samba-technical@lists.samba.org, linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On Tue, Apr 29, 2014 at 1:11 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
> On Tue, 29 Apr 2014 10:47:07 +0200
> "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com> wrote:
>
>> [CC+= linux-nfs@]
>>
>> On 04/29/2014 10:38 AM, Michael Kerrisk (man-pages) wrote:
>> > Hi Jeff,
>> >
>> > I've been looking a bit at the fcntl() documentation of traditional
>> > (F_SETLK) record locking, and a question just jumped out at me. Is
>> > it worth considering some future-proofing in the design of OFD locks
>> > ("open file description locks", formerly known as "file-private locks")?
>> >
>> > What I am thinking of here is that on some systems, the traditional
>> > 'struct flock' has a nonstandard field, l_sysid, that is used on F_GETLK
>> > to identify the remote system on which a lock is held. Should the design
>> > of OFD locks allow for such a field (now, or in the future), which might
>> > be useful in the context of locking on network file systems such as NFS.
>> >
>> > Put more simply, should the new OFD locking system be using a new
>> > structure for describing locks, rather than the traditional 'struct
>> > flock'? Defining a new structure, might be useful to allow for
>> > future extensions to the API.
>>
>> Just add one further detail here. What I'm thinking is, maybe instead there
>> should be something like:
>>
>> struct flockx {
>>     int flags;
>>     /* Other fields like 'struct flock' */
>>     char reserved[32];        /* Or some suitable value */
>> }
>>
>> That flags field might always be zero for now, but in the future it
>> could be used on the setlk and getlk operations to indicate the presence
>> of additional fields in the structure.
>>
>> Cheers,
>>
>> Michael
>>
>
> I considered that early on when I did this, but I don't think it's
> really helpful. I'm just not a fan of padding out structs when it's not
> clear what would eventually go in there.

Okay.

> The problem is that once actually go to try to convert those from
> "reserved" to something usable, it becomes a nightmare for userland to
> figure that out. How do I know whether my kernel supports the stuff I
> put in those fields or will just ignore them?

(That was my purpose with the "flags" field.)

> If we really find later that we need to do something like this, I think
> we'd be better off adding a new set of cmd values along with the
> "extended" struct, or possibly a new syscall. Some of the samba folks
> were interested in an async locking mechanism too, so something like
> that could be added in conjunction with such an interface.

Sounds reasonable. I just thought it worth checking. Thanks for the
quick response.

Cheers,

Michael

-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
