Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:44080 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbaIEVXw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 17:23:52 -0400
Received: by mail-ie0-f174.google.com with SMTP id at20so14947417iec.33
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 14:23:51 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: nfs-utils - TCP ephemeral port exhaustion results in mount failures
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <CA+Tkd6UjfJmjG0WE1F2bsB068rXkEUHhOq6S+F5e=OVA_wxeMw@mail.gmail.com>
Date: Fri, 5 Sep 2014 17:23:49 -0400
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeffrey Layton <jeff.layton@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <44C76FD6-5333-402B-9DA4-D38065AAA15F@primarydata.com>
References: <CA+Tkd6URVCziomwWMFYtxmQyybpC7=r_BTjnwVuduDaOa4cuvg@mail.gmail.com> <20140903070048.56201d1d@tlielax.poochiereds.net> <70D58138-CB00-433C-8BF8-01584E6460F0@oracle.com> <CA+Tkd6WV9K4oZPVGkqL_y6OcD9Pmj6x0roo9n839QD8RXDsCwA@mail.gmail.com> <CA+Tkd6WYkkVbY2YsmRNHB4+9AFg5UjC1xoycLTZQOYrtFCT_2w@mail.gmail.com> <CAHQdGtRpD03KHJyu1MtxA=21pu4z_YAG4XA-8Bu+t4xeUefaNQ@mail.gmail.com> <CA+Tkd6WBuMkCmsjUpjrAR38Ri6QK_B4BhgNr0gzHBTG1ytjO6Q@mail.gmail.com> <CA+Tkd6UjfJmjG0WE1F2bsB068rXkEUHhOq6S+F5e=OVA_wxeMw@mail.gmail.com>
To: Chris Perl <chris.perl@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Do these patches require one another?

What happens if I have a patched nfs-utils, but not a patched kernel or the other way around?

-dros


On Sep 5, 2014, at 4:20 PM, Chris Perl <chris.perl@gmail.com> wrote:

> It looks like they may have come through after all, unfortunately I
> already sent them again.  Apologies for the spam.
> 
> On Fri, Sep 5, 2014 at 4:04 PM, Chris Perl <chris.perl@gmail.com> wrote:
>> I tried to send them to the list, but I guess they didn't come through
>> because my sender was set to chris.perl@gmail.com, but I ran `git
>> send-email' from work, so the smtp sender ip wouldn't authorized.
>> 
>> I'll figure out a way to send them now.
>> 
>> On Fri, Sep 5, 2014 at 4:03 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> On Fri, Sep 5, 2014 at 3:40 PM, Chris Perl <chris.perl@gmail.com> wrote:
>>>> I just submitted two patches, one for nfs-utils and one for linux-nfs.
>>>> 
>>>> As I said in my previous email, the patch to nfs-utils was enough to
>>>> get us farther along, but we failed inside mount(2) with EIO (with a
>>>> decidedly more confusing error message).
>>>> 
>>>> So, I've also submitted a patch for the rpc code in the kernel that
>>>> also avoids bind when asking for a random ephemeral port.  I've tested
>>>> the combination of these two patches with my system while in the
>>>> situation I originally outlined.  I can continue to successfully mount
>>>> NFS filesystems using both of these patches.
>>>> 
>>>> I don't particularly love the kernel patch, as it makes `xs_bind' not
>>>> actually bind in all circumstances, which seems confusing.  However, I
>>>> thought trying to rework things in a larger way would cause more
>>>> issues given that I'm not very familiar with this code.  If everyone
>>>> hates it, I can try something else.
>>> 
>>> To whom did you submit these patches? I don't see anything in the
>>> linux-nfs mailing list.
>>> 
>>> --
>>> Trond Myklebust
>>> 
>>> Linux NFS client maintainer, PrimaryData
>>> 
>>> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

