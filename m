From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Sun, 21 Sep 2008 09:53:14 -0400
Message-ID: <76bd70e30809210653o304d6634k9e1f11263db6452a@mail.gmail.com>
References: <968192.84087.qm@web32607.mail.mud.yahoo.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Greg Banks" <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	"linux-nfs list" <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	"Peter zijlstra" <a.p.zijlstra@chello.nl>
To: "Martin Knoblauch" <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:3486 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbYIUNxQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Sep 2008 09:53:16 -0400
Received: by fk-out-0910.google.com with SMTP id 18so1132217fkq.5
        for <linux-nfs@vger.kernel.org>; Sun, 21 Sep 2008 06:53:15 -0700 (PDT)
In-Reply-To: <968192.84087.qm-f6uctMgKLEavuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 21, 2008 at 8:50 AM, Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org> wrote:
> ----- Original Message ----
>
>> From: Chuck Lever <chucklever@gmail.com>
>> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
>> Cc: Andrew Morton <akpm@linux-foundation.org>; Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org; Peter zijlstra <a.p.zijlstra@chello.nl>
>> Sent: Thursday, September 18, 2008 8:24:42 PM
>> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
>>
>> On Thu, Sep 18, 2008 at 6:53 AM, Martin Knoblauch wrote:
>> > ----- Original Message ----
>> >
>> >> From: Andrew Morton
>> >> To: Martin Knoblauch
>> >> Cc: Greg Banks ; linux-nfs list
>> ; linux-kernel@vger.kernel.org; Peter zijlstra
>>
>> >> Sent: Thursday, September 18, 2008 10:47:33 AM
>> >> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
>> >>
>> >> On Thu, 18 Sep 2008 01:38:57 -0700 (PDT) Martin Knoblauch
>> >> wrote:
>> >>
>> >> > > No.  mount(8) will pass unrecognised options straight down into the
>> >> > > filesystem driver.
>> >> > >
>> >> >
>> >> >  Has that always been the case, or is it a recent change? I have to support
>> >> RHEL4 userland, which is not really new.
>> >>
>> >> It's been that way for ever and ever.  It's how all these guys:
>> >>
>> >> y:/usr/src/25> grep Opt_ fs/*/super.c|wc
>> >>     781    2626   33703
>> >>
>> >> get handled.
>> >
>> >  while that seems to be not to complicated, I seem to have a problem passing
>> the mount options to the kernel. They come down as mount data version "6".
>> Apparently mount(8) or mount.nfs(8) are doing the parsing and send down the
>> legacy data block. So, what is the minimum version of mount or mount.nfs that
>> pass the options down unaltered?
>>
>> The mount command has passed a string of options to the kernel for
>> particular file systems for a while, but the facility for the NFS
>> client to parse a string of mount options in the kernel was added only
>> recently -- at least 2.6.23 or 2.6.24 is required to support this.
>> Before this, the mount command parsed these options.
>>
>
>  I understand that. Question remains, which version of the mount(8) or nfs.mount(8) command do I need to pass the options to the kernel.

You can use the latest version of nfs-utils, which is 1.1.3 to get a
version of mount.nfs that passes a string of mount options.

You should probably also replace the mount command with the latest
version from the util-linux package to get a version that starts the
mount.nfs subcommand instead of trying to do an NFS mount itself.

This is not needed for experimentation, though.  You can issue
mount.nfs directly.

--
Chuck Lever
