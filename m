From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost servers.
Date: Wed, 24 Nov 2004 03:00:17 +0100
Message-ID: <20041124020017.GH19342@vestdata.no>
References: <41A39D57.8060902@RedHat.com> <20041123232636.GE19342@vestdata.no> <41A3D9CC.7040404@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWmTE-0003Ve-3R
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 18:01:24 -0800
Received: from [217.149.127.10] (helo=stine.vestdata.no)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWmSM-0001Tc-0X
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 18:01:23 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <41A3D9CC.7040404@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Nov 23, 2004 at 07:46:04PM -0500, Steve Dickson wrote:
> Ragnar Kj=F8rstad wrote:
> >1. What happens when you run statd with the "-n" option?
> >  Does this patch override the name the user gave?
> >
> hmm.... this is a problem, since the global SM_stat_chge.mon_name
> that the -n sets is now ignored... I guess I was thinking it would be b=
etter
> for statd to dynamically set the name that sent the notify message.
> But it would probably be a smart to maintain the same functionality.
>=20
> Question: do people actually run multiple statds using the -n to define
> the interface they monitor?  That's a scenario  I guess  I didn't think=
=20
> of but
> it sound a bit awkward....

Let me just explain why -n was added in the first place:

HA NFS-servers typically have a "floating IP" which is an alias on eth0
on the active server. Clients mount by using a hostname that maps to
this floating IP. In case of a failover the secondary server needs to
send out a SM_NOTIFY with the same hostname.

-n allowed us to specify that the same notify-name should be used on
both servers, and what that name should be.

So, in this case one doesn't run multiple statds, only a single one that
should use a different hostname from gethostname().


> >2. Does this really find the correct hostname?
> >  If I'm not mistaken, the nfs client needs to get a SM_NOTIFY message
> >  with the hostname that it actually mounted from, right?
> right....
>=20
> >  This may or may not match the hostname that the server find when
> >  running gethostbyaddr on the interface's IP, so one can easily find
> >  scenarios where this patch will cause statd to stop working.
>
> I don't think this is an issue... as long as the hostname and all of it=
s=20
> aliases
> resolve to the same ip address, things should work since its the ip add=
ress
> the kernel needs to find the lock that has to be reclaimed...=20
OK, so the client maps the name back to the IP?
and compares it to gethostbyname() on the hostname that it used to
mount?

Is this in the specification, or only the linux-implementation?

If that's the case, are we allowed to just send the IP instead of the
name?

> Now the=20
> problem
> arises when the hostname resolves to a different ip address....=20
> something this patch
> is trying to address...

I didn't know the client actually compared IPs - I thought it compared
the actual names.

Then I guess it's less of a problem than I thought.

A couple of cases where I think it would fail though:
- If you have inconsistant name-resolution (/etc/hosts) in
  your system.
- If you have aliases (eth0, eth0:0) with different IPs but on the
  same network. The current patch (if I read it correctly) will then
  use the name from the last alias, which is kind of random.

The second case may be very relevant to the HA-problem which "-n" was
originally added for.
 =20
> >  Now, there new behavious may actually be better, but I'm not sure
> >  it's acceptable to change it anyway?
>
> Is this truly a big thing? to explicitly define the hostname that will=20
> be monitored?

There are two reasons to keep -n:
1. There could still be some use for the functionality.
   Personally I mostly care about the HA-problem, so if that is solved
   through some other means, I won't protest if it is removed.
   Others may use it for other things though.
2. Backwards compability
   Personally I don't have a problem with breaking existing
   installations that use "-n" if it's documented properly (e.g. in
   the manpage, changelog, and maybe you should get a warning if you try
   to use it) and if the same functionality can be achived some other
   say. (see 1). Others may be more concerned though.

> >  Could an alternative be to send out SM_NOTIFY messages for multiple
> >  hostnames?=20
> >
> I believe this is how some of the Unixs out there  do it... but that=20
> always seem a bit
> verbose and non-exact...

Verbosity: yes, but unless we know what IP the client actually used=20
there is no other way to make sure we reach all clients.

Non-exact: I agree, but if we could send out the IPs instead of the
names it would be more exact.


> >Both the one from gethostname() and the ones found by
> >  reverse lookup from the interfaces? Then I guess the meaning of the
> >  "-n" option could be changed to _add_ a hostname to the list of
> >  names to broadcast for?=20
>
> Again I think this is a bit messy especially with hosts that have a ton=
=20
> of interfaces and
> aliases.... but anything is better than how it works today.... imho...

Hmm, the more I think about it the more sure I am that it should be
possible to record what IP the client _actually_ used? Then we would
only have to send one NOTIFY to each client, and we would reach all
clients, independently of aliases and all that stuff.

If we sent the IP rather than the name (not sure we're allowed to?) we
would also eliminate the problem of inconsistent name-resolution
(allthough this is a very minor problem), making the system
bullet-proof.



--=20
Ragnar Kj=F8rstad
Software Engineer
Scali - http://www.scali.com
High Performance Clustering


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
