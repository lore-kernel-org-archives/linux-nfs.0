Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:52852 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab0DUNc5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 09:32:57 -0400
Received: by iwn35 with SMTP id 35so3853677iwn.21
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 06:32:56 -0700 (PDT)
In-Reply-To: <t2v4d569c331004202002jb25ef307va23f55beb16c2989@mail.gmail.com>
References: <y2n3b6787961004170051qfce975c0tdbc14b7ea237504d@mail.gmail.com>
	 <j2m3b6787961004170054o64f3cb47l38864ca402eb231b@mail.gmail.com>
	 <20100417111001.255ad1f4@tlielax.poochiereds.net>
	 <x2l3b6787961004191737p1fb222uc6a5b03d77414826@mail.gmail.com>
	 <t2q4d569c331004200619le2dc3a2em52f27a830d4e7d95@mail.gmail.com>
	 <j2y3b6787961004201719h6d3a7a6nea8f9d6e664a1cbc@mail.gmail.com>
	 <t2v4d569c331004202002jb25ef307va23f55beb16c2989@mail.gmail.com>
Date: Wed, 21 Apr 2010 06:32:56 -0700
Message-ID: <w2v3b6787961004210632mca9e60bbn9f68dcc2e475cfa1@mail.gmail.com>
Subject: Re: cannot mount nfsv4/krb5 with krb51.7, 1.8 and 1.8.1
From: Di Pe <dipeit@gmail.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

correction: I did not have this in my earlier testing:
permitted_enctypes = des-cbc-crc

it worked without permitted_enctypes on suse with krb5 1.6.3 but it
needed that setting with krb 1.7, 1.8 and 1.8.1

I also tried ubuntu 10 with krb5 1.8.1 and the strange thing is that
is does not need any of the enctypes. It just works.

The opentext NFS server does not seem to offer any logging capability.

Thanks


On Tue, Apr 20, 2010 at 8:02 PM, Kevin Coffman <kwc@citi.umich.edu> wrote:
> On Tue, Apr 20, 2010 at 8:19 PM, Di Pe <dipeit@gmail.com> wrote:
>> On Tue, Apr 20, 2010 at 6:19 AM, Kevin Coffman <kwc@citi.umich.edu> wrote:
>>> Hi,
>>>
>>> If I read this right, you replaced krb5-1.8.1 with krb5-1.6.3 and it
>>> fixed the problem?
>>>
>>> As I noted in your original message, you had "allow_weak_crypto =
>>> true" in your krb5.conf.  For NFS, this is required with krb5-1.8
>>> where DES is disabled by default.  Are you certain you have this
>>> specified in your krb5-1.8.1 /etc/krb5.conf?
>>
>>
>> Yes, I'm positive. 1.8.1 does not work 1.6.3 does!  This is my current setting
>>
>> [libdefaults]
>>        default_realm = FHCRC.ORG
>>        clockskew = 300
>>        default_tkt_enctypes = des-cbc-crc
>>        default_tgs_enctypes = des-cbc-crc
>>        permitted_enctypes = des-cbc-crc
>>        allow_weak_crypto = true
>>        forwardable = true
>>
>> I should add one more thing: I was using 2 different NFS servers, a
>> NetApp 7.3.1.1 and Opentext NFS Maestro Server 2008 (formerly
>> Hummingbird) on Windows 2008 R2 (AD is still 2003 R2). I found out
>> today that the NetApp had a corrupted keytab and after repairing that
>> it works fine with 1.8.1. NFS Maestro still only works with 1.6.3.
>> Since I can use the 1.6.3 rpm package onto newer distros I can live
>> with it for the moment if i block the rpm from getting updated but
>> it's still kind of a hack.
>
> Do you have access to logs on the server that still doesn't work with
> 1.8.1?  It seems odd that only this combination would fail.
>
> K.C.
>
