Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f171.google.com ([209.85.220.171]:32916 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742AbbBYWP3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 17:15:29 -0500
Received: by mail-vc0-f171.google.com with SMTP id kv19so2565841vcb.2
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 14:15:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
	<CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
	<CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
	<CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
	<CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
	<CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
	<CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
Date: Wed, 25 Feb 2015 17:15:28 -0500
Message-ID: <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 25, 2015 at 4:53 PM, Chris Perl <cperl@janestreet.com> wrote:
>> There is nothing to fix. The close-to-open cache consistency model is
>> clear that your applications must not access a file that is being
>> modified on another client or on the server.
>
> Ok, thanks for helping me understand this a little more clearly.  For
> my own edification, is there somewhere I can find the details where
> these things are spelled out (or is it just somewhere in rfc1813 that
> I haven't seen)?

There is a short description here:
    http://nfs.sourceforge.net/#faq_a8

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
