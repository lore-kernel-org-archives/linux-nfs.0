Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:45230 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752553AbeADN7X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Jan 2018 08:59:23 -0500
Message-ID: <1515074361.20282.23.camel@kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-2.3.1 released.
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neilb@suse.com>,
        Andreas Radke <andreas.radke@mailbox.org>,
        Steve Dickson <SteveD@RedHat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Date: Thu, 04 Jan 2018 08:59:21 -0500
In-Reply-To: <87a7xudx8o.fsf@notabene.neil.brown.name>
References: <1a56bb72-cc10-ba74-2b04-4df588804ef5@RedHat.com>
         <20171221212516.031618d8@laptop64.home>
         <87a7xudx8o.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2018-01-04 at 16:11 +1100, NeilBrown wrote:
> On Thu, Dec 21 2017, Andreas Radke wrote:
> 
> > This new version fails make check here now:
> > 
> > nsm_client.c:147:12: warning: this statement may fall through [-Wimplicit-fallthrough=]
> >     my_prog = atoi(optarg);
> >     ~~~~~~~~^~~~~~~~~~~~~~
> > nsm_client.c:148:3: note: here
> >    case 'v':
> >    ^~~~
> 
> What do you think Jeff, you introduced this code 8 years ago and this
> switch statement has always been broken.

Ouch!

> Does anyone use this code?  Should we fix it, it just remove it?
> 
> 
> 
> > make[4]: *** No rule to make target '../../support/nfs/libnfs.a',
> > needed by 'nsm_client'.
> 
> This looks like a bug in automake???  ../../support/nfs/libnfs.a is
> listed as _LDADD
> 
> https://www.gnu.org/software/automake/manual/html_node/Program-and-Library-Variables.html#index-maude_005fAR
> 
> which should add it to the 'ld' command, but I don't see that it should
> be added as a dependency.
> 
> > make[4]: Target 'nsm_client' not remade because of errors.
> > make[3]: *** [Makefile:565: check-am] Error 2
> > make[2]: *** [Makefile:567: check] Error 2
> > statdb_dump.c: In function ‘dump_host’:
> > statdb_dump.c:38:17: warning: unused parameter ‘timestamp’ [-Wunused-parameter]
> >     const time_t timestamp)
> >                  ^~~~~~~~~
> 
> This arg has to be there because it is part of an external API.
> As the function is passed as an arg to an extern function, gcc could
> deduce that the signature cannot be changed just because the arg isn't
> needed.
> 
> 
> > statdb_dump.c: In function ‘main’:
> > statdb_dump.c:91:10: warning: unused parameter ‘argc’ [-Wunused-parameter]
> >  main(int argc, char **argv)
> >           ^~~~
> 
> This arg doesn't need to be used (obviously) but cannot be removed.
> So this is a dumb warning too.
> 
> Maybe we should add __attribute__((unused)) ??
> 
> > make[3]: *** No rule to make target '../support/nfs/libnfs.a', needed by 'statdb_dump'.
> > make[3]: Target 'statdb_dump' not remade because of errors.
> > make[2]: *** [Makefile:1028: check-am] Error 2
> > make[1]: *** [Makefile:717: check-recursive] Error 1
> > make[1]: Target 'check' not remade because of errors.
> > 
> 
> I assume you get these errors by running "make check" without first
> running "make"??
> If you run "make" first, the errors go away, and you are left with the
> warnings.
> 
> Maybe they are worth fixing .... let's see what Jeff thinks.
> 
> NeilBrown

I don't have any particular attachment to this code these days. statd is
legacy code at this point. I'm fine with removing it.

If we do intend to keep it though, then we should definitely fix that
switch statement.

Thanks,
-- 
Jeff Layton <jlayton@kernel.org>
