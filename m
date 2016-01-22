Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35418 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753117AbcAVQGM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jan 2016 11:06:12 -0500
Received: by mail-oi0-f50.google.com with SMTP id p187so49907330oia.2
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jan 2016 08:06:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160122152429.GA9082@fieldses.org>
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
	<1453147702-42961-4-git-send-email-aweits@rit.edu>
	<20160121190134.GB1793@fieldses.org>
	<m237tqpw65.fsf@discipline.rit.edu>
	<20160121195003.GD1793@fieldses.org>
	<m2si1qmqhw.fsf@discipline.rit.edu>
	<20160122152429.GA9082@fieldses.org>
Date: Fri, 22 Jan 2016 11:06:11 -0500
Message-ID: <CAHQdGtRXTJX0uL7PPTtSZyhwvKdPAEJ3jXv4Cb-6GC_FXKzU=w@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for
 some operations
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andrew W Elble <aweits@rit.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Weston Andros Adamson <dros@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 22, 2016 at 10:24 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Thu, Jan 21, 2016 at 07:01:31PM -0500, Andrew W Elble wrote:
>>
>> > Ugh.  So the client actually needs to allow random other ops in any
>> > compound containing an spo_must_allow'd operation?  That doesn't seem
>> > right to me.
>>
>> Well, that's most certainly my fault. Seems like I should
>> submit a patch to have the client ask for GETATTR if it's going to send
>> it as a tag-along to DELEGRETURN. Is WRONGSEC really the correct way
>> to enforce appropriate use of spo_must_allow here?
>>
>> For instance, the client could ask for just DELEGRETURN:
>>
>> PUTFH
>> GETATTR
>> DELEGRETURN
>>
>> ...would be successful as long as the export was done with krb5i/krb5p.
>
> I don't know what the right thing to do is here.
>
> I wonder what the GETATTR's for?

Close to open cache consistency.

Cheers
  Trond
