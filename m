Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f178.google.com ([209.85.128.178]:58655 "EHLO
	mail-ve0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755453AbaEHUQp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 16:16:45 -0400
Received: by mail-ve0-f178.google.com with SMTP id sa20so3975954veb.37
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 13:16:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140507202932.GD9710@fieldses.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
	<20140419205815.GA1094@fieldses.org>
	<20140507202932.GD9710@fieldses.org>
Date: Thu, 8 May 2014 16:16:44 -0400
Message-ID: <CAHQdGtRcr51PcRKDpfCdotwSD6FguWrmq0a=U+cv40gJWwrtBA@mail.gmail.com>
Subject: Re: [PATCH 00/70] NFSd lock scalability patches
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 7, 2014 at 4:29 PM, Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Apr 19, 2014 at 04:58:15PM -0400, Bruce Fields wrote:
>> On Fri, Apr 18, 2014 at 02:43:54PM -0400, Trond Myklebust wrote:
>> > In accordance with the traditional Good Friday theme of "suffering", here
>> > is the first draft of the NFSd lock scalability patches for your perusal.
>> > I've only done light testing so far, but since there is a total of 70
>> > patches to review, I figured you might want to start sooner rather than
>> > waiting for the QA folks to finish testing.
>>
>> Thanks!
>>
>> Yeah, this sounds like too much suffering for vacation time, but I'll at
>> least make a stab at merging the initial bug fixes next week, then try
>> to plow through these (or any revised version (thanks, Christoph, for
>> help reviewing!)) after I get back in a couple more weeks.

Yes. Thanks very much Christoph! I was worried that I would not get
enough reviewers for these patches.

> I've at least skimmed through them all, and that's all the suffering I
> can handle for now.  I'm assuming you'll send a new version soon.

In addition to the issues that you and Christoph have raised, I've
also had to rethink some of the open() call. I'm not seeing how to
avoid moving the open share/deny locks into do_nfsd_create() without
getting into weird races, for instance.

> I'm applying a few of these to my for-3.16 branch, could you rebase
> future versions to that to avoid resending already-reviewed patches?

OK.

> How are you testing?

Mainly through plenty of runs of Connectathon tests for now. I want to
pass the code on to our QA folks for more extensive testing when it is
ready.

> Thanks again for taking on this difficult and long-overdue project....
>
> --b.



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
