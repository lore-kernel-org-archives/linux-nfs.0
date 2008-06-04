From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Wed, 4 Jun 2008 14:10:01 +0200
Message-ID: <9e8c52a20806040510t6e76f33ar38090aaa927ed200@mail.gmail.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	 <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
	 <RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
	 <9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
	 <20080526074054.141945a7@tleilax.poochiereds.net>
	 <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7@mail.gmail.com>
	 <RTPCLUEXC1-PRDqYW8B0000016d@RTPMVEXC1-PRD.hq.netapp.com>
	 <9e8c52a20805270837i73d51bdbwa66aead92ee5d3e3@mail.gmail.com>
	 <9e8c52a20806020605u736e758bsfe24dac02c8acdfe@mail.gmail.com>
	 <20080602094322.79a40c29@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:29136 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760652AbYFDMKF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2008 08:10:05 -0400
Received: by nf-out-0910.google.com with SMTP id d3so24235nfc.21
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2008 05:10:01 -0700 (PDT)
In-Reply-To: <20080602094322.79a40c29-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 2, 2008 at 3:43 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Mon, 2 Jun 2008 15:05:17 +0200
> "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com> wrote:
>
>> Nobody? Anyone care to tell me how to interpret the strace stat cur output?
>>
>
>> lstat64("cur", 0xbfb81cb4)              = -1 ENOENT (No such file or directory)
>
> File doesn't exist...
>
> If this is from "ls -l" or something like that, that means that the
> client did a READDIR or READDIRPLUS and saw a "cur" entry in the
> directory with a particular filehandle. It then went back and did a
> stat() against that filehandle and it was gone. The two possibilities
> are that something removed that directory in the interim (possibly
> replacing it with a new "cur" directory), or that the filehandle was
> bad for some reason. I'm not aware of any bugs causing the latter, so
> the former is the most likely.

 So it's possible that kmail in syncing accesses the cur directory,
reads it, and then removes and replaces the directory before all of
the read operation's actions are executed due to the difference in
time granularity between nfs and ext3? If so, should I file this as a
bug report to the kdepim people? I've looked a bit into the kmail
code, and I traced the error message to an access (from unistd.h) call
on the directories path which fails, but that probably just notices
the problem instead of causing it. I haven't  really figured out how
their syncing process works.


-- 
Alex Borghgraef
