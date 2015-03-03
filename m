Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f45.google.com ([74.125.82.45]:40578 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752901AbbCCJJW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2015 04:09:22 -0500
Received: by wghl18 with SMTP id l18so38584182wgh.7
        for <linux-nfs@vger.kernel.org>; Tue, 03 Mar 2015 01:09:21 -0800 (PST)
Message-ID: <54F57A3E.9070202@gmail.com>
Date: Tue, 03 Mar 2015 11:09:18 +0200
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
To: didier <did447@gmail.com>, "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, Chris Perl <cperl@janestreet.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
References: <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>	<CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>	<CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>	<CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>	<CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com>	<CAHQdGtQyTfTVjHpW3DT6mu0Xk_BwGaFo9xFTbA6ZzeKVe6_HYQ@mail.gmail.com>	<20150227224029.GA8750@fieldses.org>	<0836BFA3-1F2D-4CD0-AB25-3DBA916D941C@oracle.com>	<CAAih9mgZd=-L0Yj=4G4UmqW3fsGKiJtXsK8S8Steme4niguptQ@mail.gmail.com>	<DCF31069-FEF7-4DD8-9FD0-575262181A43@oracle.com>	<20150302205850.GG8033@fieldses.org> <CAJRYxuJt_1_NFW5Hsed3GhS75y2D7aHnPS5srkPV+KJzWi90MA@mail.gmail.com>
In-Reply-To: <CAJRYxuJt_1_NFW5Hsed3GhS75y2D7aHnPS5srkPV+KJzWi90MA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/02/2015 11:33 PM, didier wrote:
<>
> Yes, writing something like;
> tail -f foo
> doesn't work if readers and writer aren't on the same client
> 

s/doesn't/might not/

There are some implementations ie server/client combination that this works
just perfectly fine.

> IMO it's the most surprising for someone with a posix background on local fs.

Cheers
Boaz

