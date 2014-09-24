Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:62854 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbaIXRSd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 13:18:33 -0400
Received: by mail-vc0-f177.google.com with SMTP id im17so6827851vcb.8
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 10:18:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140924170421.GA7365@fieldses.org>
References: <20140923070733.25555.18292.stgit@unused-4-157.brq.redhat.com>
	<CAHQdGtRZA89spXkGWxoDyd8dRt-f9wfnfuz=rACsMe3bSa_meA@mail.gmail.com>
	<5422E18E.2080905@RedHat.com>
	<20140924170421.GA7365@fieldses.org>
Date: Wed, 24 Sep 2014 13:18:31 -0400
Message-ID: <CAHQdGtTYr4ErY=MUy73nN6oWcZgO+h-k8zStEwEdbbwPznOu1g@mail.gmail.com>
Subject: Re: [PATCH] mountd.man: mountd tcp wrappers support only NFS v2/v3
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steve Dickson <SteveD@redhat.com>, Jan Chaloupka <jchaloup@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 24, 2014 at 1:04 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Sep 24, 2014 at 11:21:50AM -0400, Steve Dickson wrote:
>>
>>
>> On 09/23/2014 04:41 PM, Trond Myklebust wrote:
>> > On Tue, Sep 23, 2014 at 3:07 AM, Jan Chaloupka <jchaloup@redhat.com> wrote:
>> >> mountd tcp wrappers support only NFSv2 and NFSv3, not NFSv4.
>> >>
>> >> https://bugzilla.redhat.com/show_bug.cgi?id=1116283
>> >>
>> >> This patch updates the man page
>> >>
>> >> Signed-off-by: Jan Chaloupka <jchaloup@redhat.com>
>> >> ---
>> >>  utils/mountd/mountd.man |    2 ++
>> >>  1 file changed, 2 insertions(+)
>> >>
>> >> diff --git a/utils/mountd/mountd.man b/utils/mountd/mountd.man
>> >> index a8828ae..1aae75b 100644
>> >> --- a/utils/mountd/mountd.man
>> >> +++ b/utils/mountd/mountd.man
>> >> @@ -217,6 +217,8 @@ listeners using the
>> >>  .B tcp_wrapper
>> >>  library or
>> >>  .BR iptables (8).
>> >> +Tcp wrappers are only in effect with NFS version 2 and 3 mounts.
>> >> +They do not work with NFS version 4.
>> >>  .PP
>> >>  Note that the
>> >>  .B tcp_wrapper
>> >>
>> >
>> > Is there any point to compiling mountd with the tcp wrappers in this
>> > day and age?
>> >From an upstream point of view... Sure... But I don't think
>> we can remove them from the man pages...
>>
>>
>> > tcp wrappers isn't enforced by knfsd, so as the above
>> > manpage change indicates it really is only blocking NFSv2/v3 _mount_
>> > attempts.
>> >
>> > If you can use NFSv4, or sniff the NFSv2/v3 traffic or even just guess
>> > NFSv2/v3 filehandles, then tcp wrappers can be 100% circumvented.
>> >
>> You would be surprised on the amount of people that still use
>> them...
>
> I'd also be surprised if any of them really understand how little they
> do in this case.
>

Hence my point about whether or not it is a good idea to pretend that
we have the support.

If people are configuring tcp wrappers for rpc.mount because they
don't know any better, then it should be removed. If, however, there
are still genuine use cases where the tcp wrappers provide genuine
value (as opposed to security theatre) then it would be nice to
document _that_ in the manpage instead of providing a non-exhaustive
list of alternatives where they don't help.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
