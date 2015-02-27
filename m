Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752001AbbB0BtM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 20:49:12 -0500
Message-ID: <1425001738.21632.45.camel@redhat.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Harshula <harshula@redhat.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Simo Sorce <simo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>, juzou@redhat.com
Date: Fri, 27 Feb 2015 12:48:58 +1100
In-Reply-To: <CAAih9mgZ5OwWr6Vw1UTGD=Fd6ASyhoifSOVjd7cDjwXxWbftTQ@mail.gmail.com>
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
	 <1424964150.13431.57.camel@willson.usersys.redhat.com>
	 <1424964871.10136.6.camel@primarydata.com>
	 <1424964994.640.0.camel@willson.usersys.redhat.com>
	 <CAAih9mgZ5OwWr6Vw1UTGD=Fd6ASyhoifSOVjd7cDjwXxWbftTQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chris,

On Thu, 2015-02-26 at 10:45 -0500, Chris Perl wrote:
> > Ok, I assume proper use of locking will address the situation and allow
> > readers to get consistent data and not null bytes ?
> 
> Yes, trond said this explicitly in one of his earlier replies.

You may want to double check by modifying your reproducer to use
locking.

Just want to clarify that your example is of a writer appending to a
file while a reader keeps trying to read upto the EOF. If so, what's
happening is that the metadata (file size) becomes out of sync with
actual file data requested from the NFS server due to post-op attr
attached to the READ reply containing an updated (increased) file size.
Then NULLs are introduced between the actual file data received and the
new increased file size. This is then presented to user space.

Before the synchronous READ path was removed from the NFS client code,
this issue could be avoided by using the "sync" NFS mount option.

cya,
#

