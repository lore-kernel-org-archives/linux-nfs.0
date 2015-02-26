Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:33058 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752483AbbBZPqH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Feb 2015 10:46:07 -0500
Received: from tot-qpr-mailcore1.delacy.com ([172.27.56.68] helo=tot-qpr-mailcore1)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YR0da-0007ur-M1
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 10:46:06 -0500
Received: from mail-yk0-f169.google.com ([209.85.160.169])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YR0da-0001AS-Gh
	for linux-nfs@vger.kernel.org; Thu, 26 Feb 2015 10:46:06 -0500
Received: by ykq19 with SMTP id 19so4419184ykq.4
        for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2015 07:46:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1424964994.640.0.camel@willson.usersys.redhat.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
 <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
 <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
 <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
 <CAAih9mgbDhde-hoD0aCF2ZwSXZZvi53GOmbnWy-r0tJqjgamEQ@mail.gmail.com>
 <CAAih9mgBqLyNCPmjnXcYKXZGNfx0oZkyGZ3trNg6xmOV_+V1Dw@mail.gmail.com>
 <1424964150.13431.57.camel@willson.usersys.redhat.com> <1424964871.10136.6.camel@primarydata.com>
 <1424964994.640.0.camel@willson.usersys.redhat.com>
From: Chris Perl <cperl@janestreet.com>
Date: Thu, 26 Feb 2015 10:45:45 -0500
Message-ID: <CAAih9mgZ5OwWr6Vw1UTGD=Fd6ASyhoifSOVjd7cDjwXxWbftTQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Simo Sorce <simo@redhat.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Ok, I assume proper use of locking will address the situation and allow
> readers to get consistent data and not null bytes ?

Yes, trond said this explicitly in one of his earlier replies.
