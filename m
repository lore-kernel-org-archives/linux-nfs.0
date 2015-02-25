Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:56249 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932160AbbBYVxg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 16:53:36 -0500
Received: from tot-qpr-mailcore2.delacy.com ([172.27.56.106] helo=tot-qpr-mailcore2)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YQjtf-0007aw-HJ
	for linux-nfs@vger.kernel.org; Wed, 25 Feb 2015 16:53:35 -0500
Received: from mail-yh0-f52.google.com ([209.85.213.52])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YQjtf-0005gY-Ce
	for linux-nfs@vger.kernel.org; Wed, 25 Feb 2015 16:53:35 -0500
Received: by yhzz6 with SMTP id z6so2473050yhz.13
        for <linux-nfs@vger.kernel.org>; Wed, 25 Feb 2015 13:53:35 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com> <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Wed, 25 Feb 2015 16:53:14 -0500
Message-ID: <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There is nothing to fix. The close-to-open cache consistency model is
> clear that your applications must not access a file that is being
> modified on another client or on the server.

Ok, thanks for helping me understand this a little more clearly.  For
my own edification, is there somewhere I can find the details where
these things are spelled out (or is it just somewhere in rfc1813 that
I haven't seen)?
