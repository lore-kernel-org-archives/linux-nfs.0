Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f172.google.com ([209.85.216.172]:35501 "EHLO
        mail-qt0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752700AbeDKOJo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Apr 2018 10:09:44 -0400
Received: by mail-qt0-f172.google.com with SMTP id s2so2023153qti.2
        for <linux-nfs@vger.kernel.org>; Wed, 11 Apr 2018 07:09:44 -0700 (PDT)
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [Libtirpc-devel] [PATCH 1/2] Restore using reserve ports for
 client connections
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <f6415818-a74f-b496-49aa-16243c23f806@RedHat.com>
Date: Wed, 11 Apr 2018 08:09:41 -0600
Cc: Thorsten Kukuk <kukuk@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Message-Id: <8BB30868-457E-4929-976D-E7587A46573C@gmail.com>
References: <20180410213043.5545-1-steved@redhat.com>
 <1E130010-3BB3-4BB8-9521-1B6096BC615B@oracle.com>
 <44316a1b-82ff-261c-b691-31b5621fb4e7@RedHat.com>
 <20180411125903.GA28242@suse.de>
 <f6415818-a74f-b496-49aa-16243c23f806@RedHat.com>
To: Steve Dickson <SteveD@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 11, 2018, at 8:07 AM, Steve Dickson <SteveD@RedHat.com> wrote:
>=20
>=20
>=20
> On 04/11/2018 08:59 AM, Thorsten Kukuk wrote:
>> On Wed, Apr 11, Steve Dickson wrote:
>>=20
>>>=20
>>> Hey,
>>>=20
>>> On 04/10/2018 06:17 PM, Chuck Lever wrote:
>>>>=20
>>>>=20
>>>>> On Apr 10, 2018, at 3:30 PM, Steve Dickson <steved@redhat.com> =
wrote:
>>>>>=20
>>>>> Commit 46e04a73 changed both clnt_com_create()
>>>>> and clnt_tli_create() to avoid using reserve ports when
>>>>> creating connection to the server.
>>>>>=20
>>>>> For certain legacy apps, the client has to used
>>>>> reserve port to be able to communicate with its
>>>>> server so using of reserve ports is restored.
>>>>=20
>>>> Hi Steve-
>>>>=20
>>>> Which legacy apps use clnt_tli_create and require this behavior?
>>> yphelper, yppush and ypxfr via the clnt_create() call. At least
>>> that's all I have found so far.
>>=20
> Add rpcinfo to this list... Its used in the remote call code.

clnt_create(3) is used there, but does it require a reserved port?


> steved.
>=20
>> Yes, and I need to change that like Solaris is doing it, only a
>> question of time on my side :(
>>=20
>>  Thorsten
>>=20
>=20
> =
--------------------------------------------------------------------------=
----
> Check out the vibrant tech community on one of the world's most
> engaging tech sites, Slashdot.org! http://sdm.link/slashdot
> _______________________________________________
> Libtirpc-devel mailing list
> Libtirpc-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/libtirpc-devel

--
Chuck Lever
chucklever@gmail.com



