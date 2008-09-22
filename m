From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 22 Sep 2008 13:26:27 -0400
Message-ID: <76bd70e30809221026g7bde774pbffa35881682ea4b@mail.gmail.com>
References: <20080905191939.GG22796@merfinllc.com>
	 <56258A29-95D5-4A8C-A097-014B8FEDFB8F@oracle.com>
	 <20080911184951.GB19054@merfinllc.com>
	 <200809221805.48463.hpj@urpla.net> <1222101322.7615.6.camel@localhost>
	 <20080922170414.GC12483@merfinllc.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Hans-Peter Jansen" <hpj-2x7n3sizJbFeoWH0uzbU5w@public.gmane.org>, linux-kernel@vger.kernel.org,
	"Neil Brown" <neilb@suse.de>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
To: "Aaron Straus" <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:61144 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbYIVR03 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 13:26:29 -0400
Received: by nf-out-0910.google.com with SMTP id d3so544213nfc.21
        for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2008 10:26:28 -0700 (PDT)
In-Reply-To: <20080922170414.GC12483-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 22, 2008 at 1:04 PM, Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org> wrote:
> Hi,
>
> On Sep 22 12:35 PM, Trond Myklebust wrote:
>> Revert _what_ exactly?
>
> Yep.  I narrowed the problem down to an offending hunk in a particular
> patch.  Removing that hunk did eliminate the problem.   However,
> reverting that hunk is likely wrong and the code has changed _a lot_
> since that commit.
>
>> My understanding was that this is a consequence of unordered writes
>> causing the file to be extended while some other task is reading.
>
> Yes.  I added some debugging statements to look at the writeout path.
>
> I think the following happens:
>
>  - page 0 gets partially written to by app
>  - VM writes out partial dirty page 0
>  - page 0 gets fully written by app
>  - page 1 gets partially written by app
>  - VM writes out dirty page 1
>
>  At this point there is a hole in the file.  The tail end of page 0 is
> still not written to server.
>
>  - VM writes out dirty page 0
>  ...
>
>> AFAICS, this sort of behaviour has _always_ been possible. I can't see
>> how reverting anything will fix it.
>
> Here is the crux.  It was possible previously but unlikely e.g. our app
> never saw this behavior.  The new writeout semantics causes visible
> holes in files often.
>
> Anyway, I agree the new writeout semantics are allowed and possibly
> saner than the previous writeout path.  The problem is that it is
> __annoying__ for this use case (log files).
>
> I'm not sure if there is an easy solution.  We want the VM to writeout
> the address space in order.   Maybe we can start the scan for dirty
> pages at the last page we wrote out i.e. page 0 in the example above?

Why can't you use O_SYNC | O_APPEND ?

--
Chuck Lever
