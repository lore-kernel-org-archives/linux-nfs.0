Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51721 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751829AbeADUfD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Jan 2018 15:35:03 -0500
Subject: Re: ANNOUNCE: nfs-utils-2.3.1 released.
To: NeilBrown <neilb@suse.com>,
        Andreas Radke <andreas.radke@mailbox.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <1a56bb72-cc10-ba74-2b04-4df588804ef5@RedHat.com>
 <20171221212516.031618d8@laptop64.home>
 <87a7xudx8o.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <6b5c8fb2-26eb-70bb-0320-24d243e40cd7@RedHat.com>
Date: Thu, 4 Jan 2018 15:35:02 -0500
MIME-Version: 1.0
In-Reply-To: <87a7xudx8o.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/04/2018 12:11 AM, NeilBrown wrote:
> On Thu, Dec 21 2017, Andreas Radke wrote:
> 
>> This new version fails make check here now:
>>
>> nsm_client.c:147:12: warning: this statement may fall through [-Wimplicit-fallthrough=]
>>     my_prog = atoi(optarg);
>>     ~~~~~~~~^~~~~~~~~~~~~~
>> nsm_client.c:148:3: note: here
>>    case 'v':
>>    ^~~~
> 
> What do you think Jeff, you introduced this code 8 years ago and this
> switch statement has always been broken.
> Does anyone use this code?  Should we fix it, it just remove it?
I had the same thought... I just didn't get around to asking it... 

Does anybody used this v3 testing code??? 
If it disappeared would anybody miss it???

Neil, thanks for bring this up! 

steved.

> 
> 
> 
>> make[4]: *** No rule to make target '../../support/nfs/libnfs.a',
>> needed by 'nsm_client'.
> 
> This looks like a bug in automake???  ../../support/nfs/libnfs.a is
> listed as _LDADD
> 
> https://www.gnu.org/software/automake/manual/html_node/Program-and-Library-Variables.html#index-maude_005fAR
> 
> which should add it to the 'ld' command, but I don't see that it should
> be added as a dependency.
> 
>> make[4]: Target 'nsm_client' not remade because of errors.
>> make[3]: *** [Makefile:565: check-am] Error 2
>> make[2]: *** [Makefile:567: check] Error 2
>> statdb_dump.c: In function ‘dump_host’:
>> statdb_dump.c:38:17: warning: unused parameter ‘timestamp’ [-Wunused-parameter]
>>     const time_t timestamp)
>>                  ^~~~~~~~~
> 
> This arg has to be there because it is part of an external API.
> As the function is passed as an arg to an extern function, gcc could
> deduce that the signature cannot be changed just because the arg isn't
> needed.
> 
> 
>> statdb_dump.c: In function ‘main’:
>> statdb_dump.c:91:10: warning: unused parameter ‘argc’ [-Wunused-parameter]
>>  main(int argc, char **argv)
>>           ^~~~
> 
> This arg doesn't need to be used (obviously) but cannot be removed.
> So this is a dumb warning too.
> 
> Maybe we should add __attribute__((unused)) ??
> 
>> make[3]: *** No rule to make target '../support/nfs/libnfs.a', needed by 'statdb_dump'.
>> make[3]: Target 'statdb_dump' not remade because of errors.
>> make[2]: *** [Makefile:1028: check-am] Error 2
>> make[1]: *** [Makefile:717: check-recursive] Error 1
>> make[1]: Target 'check' not remade because of errors.
>>
> 
> I assume you get these errors by running "make check" without first
> running "make"??
> If you run "make" first, the errors go away, and you are left with the
> warnings.
> 
> Maybe they are worth fixing .... let's see what Jeff thinks.
> 
> NeilBrown
> 
