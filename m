From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: nfs-utils patch to statd for multi-homed hosts
Date: Sat, 1 Jun 2002 12:27:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020601122723.F3799@vestdata.no>
References: <OFE81A6846.D2A070A1-ON88256BCA.006D5F8B@boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from stine.vestdata.no ([195.204.68.10])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17E66h-0000vL-00
	for <nfs@lists.sourceforge.net>; Sat, 01 Jun 2002 03:27:35 -0700
To: Bruce Allan <bruce.allan@us.ibm.com>
In-Reply-To: <OFE81A6846.D2A070A1-ON88256BCA.006D5F8B@boulder.ibm.com>; from bruce.allan@us.ibm.com on Fri, May 31, 2002 at 01:18:27PM -0700
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

On Fri, May 31, 2002 at 01:18:27PM -0700, Bruce Allan wrote:
> The attached patch provides the capability for statd to work with
> multi-homed hosts (i.e. NFS servers and clients with more than one IP
> interface each) as until now listed as a "FIXME" comment in
> utils/statd/rmtcall.c
Great! :-)

> The theory is when a server or client crashes, reboots, and attempts to
> notify the other of it's status change, if either host's interface on w=
hich
> the connection was originally made is no longer functional, statd will
> attempt to use alternate interfaces if they exist.  This is made possib=
le
> by changing the addr member of the notify_list structure to a list of
> addresses equivalent to that returned by a gethostbyname() call.  Faile=
d
> attempts at notifying an address removes that address from the list.

Are you saying notifications used to be sent out on the interface where
the connection happened? I thought it only happened on the primary
interface....

Does the new code work with aliases as well as physical interfaces?

How does this interact with the "--name" switch?

I believe --name originally replaced the gethostbyname() name with the
user-supplied one. Now that there are multiple interfaces to worry about
the old approach no longer works well.
I see a few different alternatives of fixing that:
1. Remove "--name". It was mostly written to fix the exact same problem
   that your patch fixes in a bettery way. Unfortenately this will not
   solve the problem with multiple names mapping to the same ip.
2. Change "--name" so that it _adds_ the hostname to the list of
   names to use in the notification-message, rather than replacing
   the existing one(s). I suppose it should also be changed to accept
   mulitple hostnames.
3. Could we possible send the IP to the clients rather than the
   hostnames? That would eliminate the problem of mulitple names
   matching the same hostname.


I suppose I should go read the spec and find out how this really work
before making comments, but I don't have the time just now, so take the
comments with a grain of salt..



--=20
Ragnar Kj=F8rstad
Big Storage

_______________________________________________________________

Don't miss the 2002 Sprint PCS Application Developer's Conference
August 25-28 in Las Vegas -- http://devcon.sprintpcs.com/adp/index.cfm

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
