Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f42.google.com ([74.125.82.42]:62376 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab1LIHsw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Dec 2011 02:48:52 -0500
Received: by wgbds13 with SMTP id ds13so2833979wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2011 23:48:51 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <813790898.1157715.1323399200260.JavaMail.root@erie.cs.uoguelph.ca>
References: <op.v565vhhjrwwil4@sfaibish1.corp.emc.com>
	<813790898.1157715.1323399200260.JavaMail.root@erie.cs.uoguelph.ca>
Date: Fri, 9 Dec 2011 08:48:51 +0100
Message-ID: <CAGue13q3_eN-u--ajbS5FJzbn5GN6VwhVhd4p5fRPYenQegGog@mail.gmail.com>
Subject: Re: [nfsv4] Slides from the pNFS BoF we delivered at LISA 11 - with
 attachment this time
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Sorin Faibish <sfaibish@emc.com>, linux-nfs@vger.kernel.org,
        honey@citi.umich.edu, nfsv4@ietf.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 9, 2011 at 3:53 AM, Rick Macklem <rmacklem@uoguelph.ca> wrote:
> Thanks for the slides, Sorin.
>
> Just fyi, it was correct to not mention a FreeBSD client, since the
> 4.1 client code hasn't made it into any release yet. It is available
> as a patch against the FreeBSD9.0 kernel, in case anyone is interested:
>   http://people.freebsd.org/~rmacklem/nfsv4.1-client/nfsv41.patch
>
> I am just starting to work on the logistics of getting this into the
> FreeBSD source tree, so it may be in a FreeBSD9.n release, where n > 0.
>
> Also, the above does not include any pNFS support. I am about ready to
> start coding pNFS client stuff, which brings me to...
> - It will be difficult for me to make much progress without any
>  pNFS servers to test against. (The only NFSv4.1 server I have to
>  test against is Fedora15 and I don't think it knows how to do pNFS?
>  If there is a way to make Fedora15/16 (or any other freebie Linux
>  distro) do pNFS, please let me know.
>
> If others have suggestions on how I might gain access to pNFS servers
> for testing, I would appreciate hearing.

Hi Rick,

we have user space pNFS server written in java. It's part of dCache
project but can be used stand alone for testing. Requires JVM and disk
space to store data blocks:

1. checkout and build

$ hg clone http://www.dcache.org/~tigran/cgi-bin/hgwebdir.cgi/jpnfs dcache-nfs
$ cd dcache-nfs
$ mvn clean package

2. tweak nfs.properties:
put you host ip instead of 192.168.2.108

current setup will start mds and ds on the same host on ports 2049 and 2052.
File system is re-initialized on restart.

3. start it:
$ java -jar target/jpNFS-0.0.4-SNAPSHOT-jar-with-dependencies.jar oncrpcsvc.xml

4. test your client

Regards,
   Tigran.

 (However, I am not funded to
> do any of this, so the suggestions can't include my spending $$$. I can
> make it to a Bakeathon when it happens to be close to where I am, so I
> can show up "on the cheap", like I did last June in Ann Arbor.)
>
> rick
>
> ----- Original Message -----
>> On Thu, 08 Dec 2011 19:40:19 -0500, Sorin Faibish <sfaibish@emc.com>
>> wrote:
>>
>> > Attached please find the slides that we presented yesterday at
>> > USENIX
>> > LISA 11
>> > conference in Boston. We would like to get more detailed input on
>> > other
>> > OS
>> > that will support pNFS server/client (this is for Rick as well) that
>> > were
>> > not mentioned in this slide set.
>> >
>> > /Sorin
>> >
>>
>>
>>
>> --
>> Best Regards
>> Sorin Faibish
>> Corporate Distinguished Engineer
>> Unified Storage Division
>>
>> EMC²
>> where information lives
>>
>> Phone: 508-435-1000 x 48545
>> Cellphone: 617-510-0422
>> Email : sfaibish@emc.com
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
