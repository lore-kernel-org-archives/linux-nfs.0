From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: Clustered NFS?
Date: Sat, 25 May 2002 03:28:39 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020525032839.X12125@vestdata.no>
References: <OF9BD0A326.21A8F516-ON88256BC3.008259B0@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17BQMW-0005ii-00
	for <nfs@lists.sourceforge.net>; Fri, 24 May 2002 18:28:52 -0700
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OF9BD0A326.21A8F516-ON88256BC3.008259B0@boulder.ibm.com>; from juang@us.ibm.com on Fri, May 24, 2002 at 04:46:22PM -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Fri, May 24, 2002 at 04:46:22PM -0700, Juan Gomez wrote:
> Is there any software project/patch attempting to create a clustered
> version of NFS? What I mean is a version of NFS where lockd/statd state can
> be migrated from server to server? Any standard for this?

There are really two seperate questions here:

1. Generic failover software
2. Code to make NFS failover work


For generic failover software I would recommend heartbeat (linux-ha.org)
(main developer is Alan Robertson, IBM, btw) or failsafe. Heartbeat is a
very minimalistic and simple system, wheres failsafe (beeing based on
Irix failsafe) is bigger. This makes heartbeat easier to understand and
build from (thus my favourite), but if you want everything in a package
failsafe may come closer. There are also commercial alternatives, but I
don't think they have any significant advantages over the free ones.

Now, NFS will mostly work like any other ha-service, but there are some
important exceptions, regarding lockd/statd. First of all,
device-numbers must match (or you must specify a device-id manually to
override the use of the device-id of the block-device). Second,
/var/lib/nfs must be shared between the servers. This way the
backup-host will know what clients had the filesystem mounted. This is
actually _almoust_ enough for locks to work as well. Locks are not
stored on disk, but on reboot the nfs-server will notify all clients
that had the fs mounted that they must relock their files. Only one
hatch: the nfs-servers use their hostname in the message to the client,
and unless you handle this specificly the clients will not reckognize
the server as the hostname is changed (thus not relock their files). The
solution is to manually set the hostname for the nfs-server, so it
matches the shared-ip rather than the real hostname of the nfs-server.

I wrote a small patch for nfs-utils to fix the above problem. With the
most recent nfs-utils package you should be able to put a "SERVICENAME"
in /etc/sysconfig/network (if you use RH init-scripts) for this.

Mission Critical Linux often claim they're the only software that
handles this, but the truth is that they produced some linux-patches to
fix nfs-bugs related to reboot/failover, and the fixes are available to
anyone. They're work was important and you may choose to buy their
software to support them (but I guess it's a little bit late...), but
it's not a requirement for this functionality.

Failsafe has a built-in script for nfs-servers, but unfortenately the
linux-version (unlike the irix-version) does not work for a shared
/var/lib/nfs (at least it didn't earlier). So, you will have to do some
modifications for this to work. It's not impossible, and SGI/SuSE would
probably like the fixes in the main distribution so you will get help.

However, as heartbeat doesn't require own init-scripts at all, but just
use the regular sysv scripts, it's the easiest solution of them all. It
has been done, and it works fine :)

BigStorage have a NAS based on linux+heartbeat for those that want the
functionality without the hassle.



-- 
Ragnar Kjorstad
Big Storage

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
