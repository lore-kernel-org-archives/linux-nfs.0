From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <linux-ha@ragnark.vestdata.no>
Subject: Highly Available NFS-server, locking and statd
Date: Sat, 28 Jun 2003 08:56:33 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030628065633.GK24737@vestdata.no>
References: <Pine.LNX.4.44.0306271732330.21414-100000@mazda.sh.intel.com> <3EFC554D.302@unix.sh> <20030627224359.GJ24737@vestdata.no> <3EFD2322.9020209@unix.sh>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19W9e4-000498-00
	for <nfs@lists.sourceforge.net>; Fri, 27 Jun 2003 23:57:13 -0700
To: linux-ha-dev@lists.community.tummy.com,
   Bruce Allan <bruce.allan@us.ibm.com>, paul popelka <paulp@veritas.com>,
   nfs@lists.sourceforge.net
In-Reply-To: <3EFD2322.9020209@unix.sh>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

The question of how to set up a highly available nfs-server is asked
frequently on both nfs- and linux-ha-lists.

I suggest we should write a FAQ entry or a more comprehensive guide to
setting up a HA NFS-server, as there are some additional issues that
are not part of either traditional nfs-documentation or traditional
ha-documentation.

Unfortenately I don't have a good enough overview of what's needed to
write the doc without some help...

For those that are new to the thread, the problem is the notifications=20
sent to nfs-clients by statd. Clients expect a notification-message,
with the same hostname they used when mounting the filesystem whenever
the nfs-server restarts. For a HA-setup, the clients typically mount
from a "servicename", which is different from the primary hostname of
the nfs-servers.

Typically there are three hostnames involved.
One machine with hostname like "server1", another machine with hostname
"server2", and a hostname like "nfs-service" that maps to an IP that is
moved to the server that is active at any time.

The client may mount the filesystem as "nfs-service:/foo" when the
service is active on "server1", and when the service is moved to
"server2" the server send a notification-message to make the client
reclaim it's locks, but the hostname in the message will be "server2",
so the clients don't recognize it.



On Fri, Jun 27, 2003 at 11:09:54PM -0600, Alan Robertson wrote:
> >NFS locks should work fine if you only put the statd-files on shared
> >storage, restart statd on failover and configure the "service-name"
> >correctly.
> >
> >Did you try it?
>=20
> Here's what I've done:
>   put /var/lib/nfs on drbd-replicated storage
>   started	 nfslock as an HA resource
> 			(this starts both statd and lockd)
>=20
> But, I never did successfully configure the "service-name".
>=20
> How do I do that?

It depends on what nfs-util revision you have.

Versions prior to v0.3.3 simpy can't do it.

In version 0.3.3 and newer statd has a new option "-n" to specify the=20
hostname the clients are mounting from. The initscript in redhat/nfslock
allows you to use the -n switch by putting a line like:
STATD_HOSTNAME=3DFOO
in /etc/sysconfig/network.

I belive this script is used when building an RPM from the the source,
but AFAIK neither RedHat or SuSE uses this script in their packages. Not
sure about this. (And I forgot to add the switch to nodist/nfsserver,
which perhaps some distributions are based on).



However, this description is incomplete.

First there is the support for "multi-homed" nfs. There is a patch
posted to the nfs-list by paul popelka <paulp@veritas.com> october 11th
2001 which "contains the changes I made to nfs-utils-0.3.1
to allow statd running on a multihomed host to send SM_NOTIFYs
for each of the hosts known names to each statd client wanting to
be notified of a reboot.". I _think_ this patch would solve the same
problem without the need for configuring the "service-name", as it would
be found automaticly by reverse lookup from the ip-alias. However, I
don't think this patch was ever included in nfs-utils?

Next, there was a patch by Bruce Allan <bruce.allan@us.ibm.com> posted
to the nfs-list May 31 2002 that _also_ added support for "multi-homed"
nfs. Not sure if this patch is related to the previous one? After
reading both the anouncement and the explanation by Bruce I still don't
understand completely what this patch is doing, but I'm pretty sure it
doesn't solve the ha-problem :) And I can't find the patch in CVS, so
I'm gussing it was never included either?


Then there is the "-N" switch recently added to statd. For those without
the recent manpage:
"Causes statd to run in the notify-only mode. When started in this mode,
the statd program will check its state directory, send notifications to=20
any monitored nodes, and exit once the notifications have been sent.=20
This mode is used to enable Highly Available NFS implementations (i.e.=20
HA-NFS)."

How exactly should it be used in a HA-environment?

Last, what I think is an unresolved issue: Running HA-NFS in
active/active configurations. That is, some filesystems may be exported
from "server1" and some from "server2" - but when "server1" fails all
filesystems should be moved to "server2". For locks to work, I think
there need to be an individual statd-instance for each filesystem
exported, binding to the specific interface.=20


--=20
Ragnar Kj=F8rstad
Zet.no


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
