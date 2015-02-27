Return-Path: linux-nfs-owner@vger.kernel.org
Received: from [38.105.200.112] ([38.105.200.112]:48779 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752303AbbB0NRw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 08:17:52 -0500
Received: from tot-qpr-mailcore1.delacy.com ([172.27.56.68] helo=tot-qpr-mailcore1)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YRKnM-0003IX-7V
	for linux-nfs@vger.kernel.org; Fri, 27 Feb 2015 08:17:32 -0500
Received: from mail-yk0-f175.google.com ([209.85.160.175])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YRKnM-0002BK-2O
	for linux-nfs@vger.kernel.org; Fri, 27 Feb 2015 08:17:32 -0500
Received: by ykp131 with SMTP id 131so7140685ykp.3
        for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2015 05:17:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1425001738.21632.45.camel@redhat.com>
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
 <1424964994.640.0.camel@willson.usersys.redhat.com> <CAAih9mgZ5OwWr6Vw1UTGD=Fd6ASyhoifSOVjd7cDjwXxWbftTQ@mail.gmail.com>
 <1425001738.21632.45.camel@redhat.com>
From: Chris Perl <cperl@janestreet.com>
Date: Fri, 27 Feb 2015 08:17:11 -0500
Message-ID: <CAAih9mhHGmWrufZadQZEZZ3Aw40N8r2Sb32z4R+f076ZYWLy=g@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Harshula <harshula@redhat.com>
Cc: Simo Sorce <simo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>, juzou@redhat.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Just want to clarify that your example is of a writer appending to a
> file while a reader keeps trying to read upto the EOF.

Yes, the reader keeps issuing fixed size reads and eventually hits
EOF.  It then stat's the file over and over and when it sees more data
available to read, it does the same thing.  If I modify the reproducer
to calculate the available bytes left in the file (as reported by the
stat) and then make sure to never hit EOF, it is no longer
reproducible.

> If so, what's
> happening is that the metadata (file size) becomes out of sync with
> actual file data requested from the NFS server due to post-op attr
> attached to the READ reply containing an updated (increased) file size.
> Then NULLs are introduced between the actual file data received and the
> new increased file size. This is then presented to user space.

This is exactly what I believe is happening (as I kind of mentioned in
earlier messages, although I haven't confirmed that its post-op attrs
updating the size).

Are you saying that even with locking you think this might still be
possible?  I had assumed that would synchronize the appender and the
reader enough that it seemed unlikely, but I can try it.
