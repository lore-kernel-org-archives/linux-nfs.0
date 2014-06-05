Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703AbaFEOP7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2014 10:15:59 -0400
Message-ID: <53907B9A.3090802@RedHat.com>
Date: Thu, 05 Jun 2014 10:15:54 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Ditang Chen <chendt.fnst@cn.fujitsu.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH]statd: create statdpath dir if specify the "--with-statdpath=xx"
 parameter in configure nfs-utils source code
References: <539026DB.30502@cn.fujitsu.com> <CAHQdGtRzw-Aizqd1Q8Y9FAXZgp2jefn115F-ogcPA8VSuqA1Dw@mail.gmail.com>
In-Reply-To: <CAHQdGtRzw-Aizqd1Q8Y9FAXZgp2jefn115F-ogcPA8VSuqA1Dw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 06/05/2014 08:38 AM, Trond Myklebust wrote:
> On Thu, Jun 5, 2014 at 4:14 AM, Ditang Chen <chendt.fnst@cn.fujitsu.com> wrote:
>> When configure the nfs-utils source code with "--with-statdpath=/foo" parameter，
>> #define NSM_DEFAULT_STATEDIR "/foo" will be generated in support/include/config.h file,
>> but Makefile will not create "/foo" dir.
>>
>> Signed-off-by: chendt.fnst@cn.fujitsu.com
>> ---
>>  Makefile.am | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/Makefile.am b/Makefile.am
>> index ae7cd16..5c9ef44 100644
>> --- a/Makefile.am
>> +++ b/Makefile.am
>> @@ -54,10 +54,10 @@ install-data-hook:
>>         touch $(DESTDIR)$(statedir)/xtab; chmod 644 $(DESTDIR)$(statedir)/xtab
>>         touch $(DESTDIR)$(statedir)/etab; chmod 644 $(DESTDIR)$(statedir)/etab
>>         touch $(DESTDIR)$(statedir)/rmtab; chmod 644 $(DESTDIR)$(statedir)/rmtab
>> -       mkdir -p $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak
>>         touch $(DESTDIR)$(statedir)/state
>> -       chmod go-rwx $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
>> -       -chown $(statduser) $(DESTDIR)$(statedir)/sm $(DESTDIR)$(statedir)/sm.bak $(DESTDIR)$(statedir)/state
>> +       mkdir -p $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak
>> +       chmod go-rwx $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
>> +       -chown $(statduser) $(DESTDIR)$(statdpath)/sm $(DESTDIR)$(statdpath)/sm.bak $(DESTDIR)$(statedir)/state
>>
> 
> The file 'state' is owned by rpc.statd. Isn't it therefore also
> subject to the --with-statdpath modifier?
--with-statedir and --with-statdpath are basically the same thing.
When --with-statdpath is not specified, its set to the --with-statedir
value, that's why this these mkdir,chmod and chown were not needed.
But I guess if you do want split out the statdpath from the statedir
those mkdir,chmod and chown need to happen. 


> 
> At one point, the Fedora RPM packager even used to put it in
> /var/lib/nfs/statd (as the manpage says it should) although that seems
> to be broken now.
> 
It still does... So does RHEL... We have being going that for years...
How is that broken?

steved. 
