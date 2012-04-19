Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:62088 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab2DSL1H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Apr 2012 07:27:07 -0400
Received: by wibhr17 with SMTP id hr17so1427644wib.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Apr 2012 04:27:06 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: "bfields\@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel\@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [REGRESSION] NFSv4: open(O_TRUNC) hangs
References: <87d37osrx2.fsf@tucsk.pomaz.szeredi.hu>
	<1333647115.4573.3.camel@lade.trondhjem.org>
	<8762ddb3ge.fsf@tucsk.pomaz.szeredi.hu>
	<1334786606.12880.14.camel@lade.trondhjem.org>
Date: Thu, 19 Apr 2012 13:27:19 +0200
In-Reply-To: <1334786606.12880.14.camel@lade.trondhjem.org> (Trond Myklebust's
	message of "Wed, 18 Apr 2012 22:03:26 +0000")
Message-ID: <87aa287yi0.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Myklebust, Trond" <Trond.Myklebust@netapp.com> writes:

> Hi Miklos
>
> On Fri, 2012-04-06 at 11:43 +0200, Miklos Szeredi wrote:
>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> writes:
>> 
>> > The following client patch fixes the regression for me.
>> 
>> It fixes the hang, but it still doesn't work 100% correctly.  Try the
>> following test program.
>> 
>> BTW, do you run any fs test suits?  All these were caught with one I use
>> to quick test fuse (it's in the fuse git tree(*) under the "test"
>> directory).  But I guess others like LTP would catch these as well.
>
> Thanks! I'll look into that. Bryan has been helping me to set up a test
> rig for the NFS client, but for now we don't have much coverage of basic
> POSIX tests.
>
>> Thanks,
>> Miklos
>> 
>> (*)  git://fuse.git.sourceforge.net/gitroot/fuse/fuse
>> ---
>> 
>> #include <stdio.h>
>> #include <unistd.h>
>> #include <fcntl.h>
>> #include <errno.h>
>> 
>> int main(int argc, char *argv[])
>> {
>> 	int res;
>> 	char *name = argv[1];
>> 
>> 	unlink(name);
>> 	close(creat(name, 0400));
>> 	res = open(name, O_RDONLY | O_TRUNC);
>> 	if (res != -1 && errno != EPERM)
>> 		fprintf(stderr, "should have failed!\n");
>
> Shouldn't that be EACCES? As far as I know, POSIX doesn't list EPERM as
> an allowed return value for open().

Yes it should be EACCESS.  That test is broken, it should be:

	if (res != -1 || errno != EACCES)

The one in the fuse tree is correct though...

Thanks,
Miklos
