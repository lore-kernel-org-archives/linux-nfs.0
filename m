Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:38120 "EHLO
        mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbeBCPkn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Feb 2018 10:40:43 -0500
Received: by mail-lf0-f68.google.com with SMTP id g72so35795954lfg.5
        for <linux-nfs@vger.kernel.org>; Sat, 03 Feb 2018 07:40:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180202211903.GB6635@fieldses.org>
References: <CAA_-hQKxopVaXHT+m3CpTfjNZjbMaYO-1D2DM1CFKZxJa4050Q@mail.gmail.com>
 <20180202211903.GB6635@fieldses.org>
From: Kenneth Dsouza <kdsouza@redhat.com>
Date: Sat, 3 Feb 2018 21:10:41 +0530
Message-ID: <CAA_-hQJMYG2y4a_6pEusdEy0obV3+dT_9uVe44C0FbdvkcUEPQ@mail.gmail.com>
Subject: Re: [PATCH v2] nfs4_getfacl: Add support to accept more paths
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 3, 2018 at 2:49 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Thanks, one nit:
>
> On Sat, Feb 03, 2018 at 02:03:31AM +0530, Kenneth Dsouza wrote:
>> Update man page with information for multiple file path support.
>>
>> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
>> ---
>>  man/man1/nfs4_getfacl.1     |  7 ++++++-
>>  nfs4_getfacl/nfs4_getfacl.c | 18 +++++++++---------
>>  2 files changed, 15 insertions(+), 10 deletions(-)
>>
>> diff --git a/man/man1/nfs4_getfacl.1 b/man/man1/nfs4_getfacl.1
>> index fc092be..b556e1a 100644
>> --- a/man/man1/nfs4_getfacl.1
>> +++ b/man/man1/nfs4_getfacl.1
>> @@ -9,7 +9,7 @@
>>  nfs4_getfacl \- get NFSv4 file/directory access control lists
>>  .SH SYNOPSIS
>>  .B nfs4_getfacl [-H]
>> -.I file
>> +file ...
>>  .SH DESCRIPTION
>>  .B nfs4_getfacl
>>  will display the NFSv4 Access Control List (ACL) for
>> @@ -28,6 +28,7 @@ The output format for an NFSv4 file ACL, e.g., is:
>>  .RS
>>  .nf
>>
>> +# file: /somedir
>>  A::OWNER@:rwatTnNcCy
>>  A::alice@nfsdomain.org:rxtncy
>>  A::bob@nfsdomain.org:rwadtTnNcCy
>> @@ -42,6 +43,10 @@ In the example output above, the user
>> `alice@nfsdomain.org' has the equivalent
>>  of "read" and "execute" permissions, `bob@nfsdomain.org' has "read" and
>>  "write", and both `GROUP@' and `EVERYONE@' have "read".
>>
>> +.B nfs4_getfacl
>> +reads a list of files from standard input. The ACL listings of
>> +multiple files are separated by blank lines.
>> +
>
> The list of files comes from the command line arguments, not standard
> input, right?
   Yes

> I've modified the man page slightly but otherwise taken your patch
> unchanged; result is pushed out to git now, let me know if it looks OK
> to you.
>
> --b.

 It looks good. Thank you for fixing it.
