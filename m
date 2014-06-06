Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([59.151.112.132]:8436 "EHLO
	heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751975AbaFFDJ3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 23:09:29 -0400
Message-ID: <539130DA.20804@cn.fujitsu.com>
Date: Fri, 6 Jun 2014 11:09:14 +0800
From: Ditang Chen <chendt.fnst@cn.fujitsu.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "yaoxp@cn.fujitsu.com" <yaoxp@cn.fujitsu.com>
Subject: Re: [PATCH]statd: create statdpath dir if specify the "--with-statdpath=xx"
 parameter in configure nfs-utils source code
References: <539026DB.30502@cn.fujitsu.com> <CAHQdGtRzw-Aizqd1Q8Y9FAXZgp2jefn115F-ogcPA8VSuqA1Dw@mail.gmail.com> <53907B9A.3090802@RedHat.com> <CAHQdGtSF0662w=p96qxYFqx1snM8RrAE1Qr8b02ajj6iU6Z3Kg@mail.gmail.com>
In-Reply-To: <CAHQdGtSF0662w=p96qxYFqx1snM8RrAE1Qr8b02ajj6iU6Z3Kg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2014 10:20 PM, Trond Myklebust wrote:
> On Thu, Jun 5, 2014 at 10:15 AM, Steve Dickson <SteveD@redhat.com> wrote:
>> Hey,
>>
>> On 06/05/2014 08:38 AM, Trond Myklebust wrote:
>>> On Thu, Jun 5, 2014 at 4:14 AM, Ditang Chen <chendt.fnst@cn.fujitsu.com> wrote:
>>>> When configure the nfs-utils source code with "--with-statdpath=/foo" parameter，
>>>> #define NSM_DEFAULT_STATEDIR "/foo" will be generated in support/include/config.h file,
>>>> but Makefile will not create "/foo" dir.
>>>>
>>>> Signed-off-by: chendt.fnst@cn.fujitsu.com
>>>> ---
>>>>  Makefile.am | 6 +++---
>>>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>>>
>>>> diff --git a/Makefile.am b/Makefile.am
>>>> index ae7cd16..5c9ef44 100644
>>>> --- a/Makefile.am
>>>> +++ b/Makefile.am
>>>> @@ -54,10 +54,10 @@ install-data-hook:
>>>>         touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
>>>>         touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
>>>>         touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
>>>> -       mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
>>>>         touch $(DESTDIR)$(statedir)/state
>>>> -       chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
>>>> -       -chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
>>>> +       mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
>>>> +       chmod go-rwx $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
>>>> +       -chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
>>>>
>>>
>>> The file 'state' is owned by rpc.statd. Isn't it therefore also
>>> subject to the --with-statdpath modifier?
>> --with-statedir and --with-statdpath are basically the same thing.
>> When --with-statdpath is not specified, its set to the --with-statedir
>> value, that's why this these mkdir,chmod and chown were not needed.
>> But I guess if you do want split out the statdpath from the statedir
>> those mkdir,chmod and chown need to happen.
>>
>>
>>>
>>> At one point, the Fedora RPM packager even used to put it in
>>> /var/lib/nfs/statd (as the manpage says it should) although that seems
>>> to be broken now.
>>>
>> It still does... So does RHEL... We have being going that for years...
>> How is that broken?
>>
> 
> My nfs-utils rpms on Fedora seem to be creating /var/lib/nfs/state
> instead of putting it in the statd subdirectory.
> 
I tested it on RHEL, the file 'state' subject to the --with-statdpath modifier.

nfs-utils rpms on Fedora/RHEL split out the statdpath from the statedir,configure 
with '--with-statdpath=/var/lib/nfs/statd', and creating /var/lib/nfs/state file,
but '/var/lib/nfs/state' seems not to be used, the really be used file is 
/var/lib/nfs/statd/state.

I‘ll send another patch to fix it.
> 
> 

