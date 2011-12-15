Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758556Ab1LOBpV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 20:45:21 -0500
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pBF1jKh7020094
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Dec 2011 20:45:20 -0500
Date: Wed, 14 Dec 2011 20:46:58 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] clstated: add a daemon to track NFSv4 client names
 on stable storage (RFC)
Message-ID: <20111214204658.56063a5e@corrin.poochiereds.net>
In-Reply-To: <4EE922EA.1010408@RedHat.com>
References: <1323871032-3191-1-git-send-email-jlayton@redhat.com>
	<4EE8BF63.6080906@RedHat.com>
	<20111214103247.3a67515f@tlielax.poochiereds.net>
	<4EE8C45B.30207@RedHat.com>
	<20111214110538.2adaf048@tlielax.poochiereds.net>
	<4EE8CE18.2040306@RedHat.com>
	<20111214113432.786ffbf7@tlielax.poochiereds.net>
	<4EE9079D.2000607@RedHat.com>
	<20111214160654.7c36fdc0@tlielax.poochiereds.net>
	<4EE922EA.1010408@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 14 Dec 2011 17:27:54 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> 
> 
> On 12/14/2011 04:06 PM, Jeff Layton wrote:
> > On Wed, 14 Dec 2011 15:31:25 -0500
> > Steve Dickson <SteveD@redhat.com> wrote:
> > 
> >>
> >>
> >> On 12/14/2011 11:34 AM, Jeff Layton wrote:
> >>> On Wed, 14 Dec 2011 11:26:00 -0500
> >>>>>>>>> The data is stored using a sqlite database. The main reason for this is
> >>>>>>>>> that it takes care of most of the fussy details and atomicity concerns
> >>>>>>>>> of tracking the information on stable storage.
> >>>>>>>> This will make nfs-utils dependent on the sqlite database... Any idea
> >>>>>>>> what kinda of extra baggage this brings? 
> >>>>>>>>
> >>>>>>>
> >>>>>>> Depends on what you mean by "baggage". What is your concern?
> >>>>>> In Fedora doing a 'yum install sqlite' which would require
> >>>>>> a ton of other package needing to be install... The Required
> >>>>>> for nfs-utils is getting pretty long at this point... 
> >>>>>>  
> >>>>>
> >>>>> I don't think it pulls in that much. This is pretty minimal for dependencies:
> >>>>>
> >>>>> $ ldd /usr/lib/libsqlite3.so.0.8.6 
> >>>>> 	linux-gate.so.1 =>  (0x00e05000)
> >>>>> 	libdl.so.2 => /lib/libdl.so.2 (0x001bd000)
> >>>>> 	libpthread.so.0 => /lib/libpthread.so.0 (0x00769000)
> >>>>> 	libc.so.6 => /lib/libc.so.6 (0x00e27000)
> >>>>> 	/lib/ld-linux.so.2 (0x4e572000)
> >>>>>
> >>>>> I think the command-line tools have some dependency on ncurses and
> >>>>> readline and such, but I don't think it's that much really...
> >>>>>
> >>>>> In any case, perhaps it's time to split the nfs-utils packaging for
> >>>>> fedora into client and server pieces? Clients really only need
> >>>>> a few of the tools, but they can't install that on fedora without
> >>>>> getting all of the server pieces too.
> >>>> Yeah I thinking this is quickly becoming slippery slope... In the end I'm
> >>>> all for looking into using dbs instead of flat files but I'm just
> >>>> worrying about the size of nfs-utils footprint... Maybe unnecessarily 
> >>>>
> >>>> Question, how would admin look at the list of client? Will that
> >>>> even be needed? 
> >>>>
> >>>
> >>> Generally shouldn't be needed unless you're debugging. Today, we just
> >>> have a bunch of directories in the v4recoverydir with md5 hash names,
> >>> so I think moving to a DB is a step forward in this sense.
> >> Or possible an overkill?? How large do you expect these lists
> >> to grow? 
> >>
> > 
> > At least one record per client. So probably on the order of a few
> > thousand per cluster node. Multiply that times the number of cluster
> > nodes.
> > 
> >> Also, from what the Nfsd4_server_recovery wiki says all that is
> >> really need is "stable storage". What makes sqlite more stable
> >> than a simple write() followed by an fsync()?
> > 
> > Eventually we need to share this DB in a cluster too. With that, we'll
> > have to coordinate these writes and fsyncs across cluster nodes to
> > ensure that they don't clobber each other. Now we have a simple
> > write/fsync plus fcntl locking. Things get less simple...
> True... but file locking is a well established tried and true way of 
> keeping files in sync... Do we have that type of confidence with 
> the file locking in sqlite? 
>  

Yes, it uses the same fcntl locking under the hood (whole files only).

> > 
> > There are also atomicity concerns too. What happens if we try to write
> > out a record and only part of it gets written out before the node dies?
> > 
> > sqlite3 databases are journalled so that's not a problem there. The
> > transaction just didn't happen.
> hmm... this seems like a lot of overhead... but interesting.... 
> Those journaled writes... any idea what type of latency they introduces?
> Probably not... It just seems there is a lot of technology there just to
> keep list of clients... 
> > 
> > With flat files, you have to be able to deal with those cases on your
> > own. Witness the growth in code that we had to maintain when Chuck
> > moved from sqlite for new-statd to using the legacy statd flat file
> > format.
> But you dance with the one you brung! ;-) Meaning we know those cases,
> sqlite is a black box.. 
> 

I'm not sure how to respond to this. The use of sqlite here is very
simple. I really don't anticipate any problems with what I'm doing with
it. It's used every day for far heavier fashions.

I'm fairly sure that if we find bugs in sqlite, then the maintainers
will be happy to fix them.

> > 
> >>>
> >>> There's a sqlite3 tool that you can use to attach to the DB file(s).
> >>> Then you can run sql commands against the tables in it. The DB layout
> >>> at this point is very simple, so this shouldn't be too hard.
> >>>
> >>> Note that I'm not dead-set on using sqlite for this if there's
> >>> something more suitable. What I really don't want to do though is to
> >>> reinvent the wheel. Storing info safely on stable storage is a solved
> >>> problem, IMO...
> >>>
> >> I took a look there does not appear to be any dependencies at all...
> >> So that worry was unfounded... Whats another dependency?? ;-) Lets just
> >> make sure using db is not overkill... then I'm good to go...
> >>
> > 
> > Again, I'm not set on sqlite. Maybe something else would be better?
> > There's bdb for instance, and samba has the tdb stuff. I haven't
> > looked at them in great detail but they might also work here too.
> > 
> > I really don't have any desire to write yet another flat file storage
> > engine for this however.
> > 
> I agree... lets have this conversation and see where it leads... 
> 
> Just thinking out loud... Would it make sense to build an plug
> and play API where it would not matter what the back-end db is
> that every daemon in nfs-utils could migrate to?
> 

That's possible. I wrote the daemon such that it wouldn't be too hard
to do that, at least at build time. The question is: who thinks its
worth the trouble to write other storage backends? If we write this
well enough to begin with, there's really no need for another one.

Not to put too fine a point on it, but so far most of what I'm hearing
is fear, uncertainty and doubt about using sqlite for this. Does anyone
have a real technical reason as to why it's not suitable for this
purpose?

-- 
Jeff Layton <jlayton@redhat.com>
