Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:40716 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752490AbbCCN32 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 08:29:28 -0500
Received: from tot-qpr-mailcore1.delacy.com ([172.27.56.68] helo=tot-qpr-mailcore1)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YSmt6-0004Sr-AN
	for linux-nfs@vger.kernel.org; Tue, 03 Mar 2015 08:29:28 -0500
Received: from mail-yk0-f177.google.com ([209.85.160.177])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YSmsz-0000FC-W5
	for linux-nfs@vger.kernel.org; Tue, 03 Mar 2015 08:29:22 -0500
Received: by ykp9 with SMTP id 9so16596013ykp.10
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 05:29:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3E668056-0C9D-440D-86E5-CCB5AF74D7A7@oracle.com>
References: <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
 <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
 <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>
 <CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>
 <20150227224029.GA8750@fieldses.org> <0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com>
 <CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com>
 <DCF31069-FEF7-4DD8-9FD0-575262181A43@oracle.com> <20150302205850.GG8033@fieldses.org>
 <3E668056-0C9D-440D-86E5-CCB5AF74D7A7@oracle.com>
From: Chris Perl <cperl@janestreet.com>
Date: Tue, 3 Mar 2015 08:29:00 -0500
Message-ID: <CAAih9mieawzDqPU=6YEJAM=MbS-f3RdOckL_bSKG7fXDm2CSKQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just to quickly answer the earlier question about whether I have
received a good answer from this list:  Yes, I have, and I appreciate
all the time and discussion spent helping me understand what I've been
seeing.

> I read Chris’s e-mail as a request for more detail in the answer
> I proposed before. Maybe I’m wrong.
>
> Is this not sufficient:
>
> “Because NFS is not a cluster or “single system image” filesystem,
> applications must provide proper serialization of reads and writes
> among multiple clients to ensure correct application behavior and
> prevent corruption of file data. The close-to-open mechanism is not
> adequate in the presence of concurrent opens for write when multiple
> clients are involved.”
>
> Perhaps the “presence of concurrent opens for write” should be
> replaced with “presence of concurrent writes.” But what else needs
> to be said?

I'm trying to decide if, having read the above in the FAQ, it would
have been obvious to me that what I was seeing was expected.  I don't
know that it would have been.  That paragraph seems to impart to me
the idea that if you don't synchronize your readers and writers you
might get weird results, much like a local file system.  However, I
thought the way in which my updates were happening made this ok, as I
was only ever appending data to a given file.

I guess I was hoping for something more along the lines of (this would
be meant to be inserted after paragraph 6 of A8 in the FAQ):

Furthermore, in the presence of multiple clients, at least one of
which is writing to a given file, close-to-open cache consistency
makes no guarantee's about the data that might be returned from the
cache on a client issuing reads concurrent with those writes.  It may
return stale data or it may return incorrect data.
