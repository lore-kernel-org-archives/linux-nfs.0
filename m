From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] STATD - SM_NOTIFY have wrong ID_NAME on multihost
 servers.
Date: Wed, 24 Nov 2004 07:00:08 -0500
Message-ID: <41A477C8.4060405@RedHat.com>
References: <41A39D57.8060902@RedHat.com> <20041123232636.GE19342@vestdata.no> <41A3D9CC.7040404@RedHat.com> <20041124020017.GH19342@vestdata.no>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010307030800020808050402"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWvmR-0001mL-3P
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 03:57:51 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWvmP-00082U-FS
	for nfs@lists.sourceforge.net; Wed, 24 Nov 2004 03:57:50 -0800
To: =?ISO-8859-15?Q?Ragnar_Kj=F8rstad?= <nfs@ragnark.vestdata.no>
In-Reply-To: <20041124020017.GH19342@vestdata.no>
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

This is a multi-part message in MIME format.
--------------010307030800020808050402
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by mx1.redhat.com id iAOBvkeA021234

Ragnar Kj=F8rstad wrote:

>On Tue, Nov 23, 2004 at 07:46:04PM -0500, Steve Dickson wrote:
> =20
>
>>Ragnar Kj=F8rstad wrote:
>>   =20
>>
>>>1. What happens when you run statd with the "-n" option?
>>> Does this patch override the name the user gave?
>>>
>>>     =20
>>>
>>hmm.... this is a problem, since the global SM_stat_chge.mon_name
>>that the -n sets is now ignored... I guess I was thinking it would be b=
etter
>>for statd to dynamically set the name that sent the notify message.
>>But it would probably be a smart to maintain the same functionality.
>>
>>Question: do people actually run multiple statds using the -n to define
>>the interface they monitor?  That's a scenario  I guess  I didn't think=
=20
>>of but
>>it sound a bit awkward....
>>   =20
>>
>
>Let me just explain why -n was added in the first place:
> =20
>
thanks... that gave me a bit more insight on how the -n is used....=20

>>> This may or may not match the hostname that the server find when
>>> running gethostbyaddr on the interface's IP, so one can easily find
>>> scenarios where this patch will cause statd to stop working.
>>>     =20
>>>
>>I don't think this is an issue... as long as the hostname and all of it=
s=20
>>aliases
>>resolve to the same ip address, things should work since its the ip add=
ress
>>the kernel needs to find the lock that has to be reclaimed...=20
>>   =20
>>
>OK, so the client maps the name back to the IP?
>and compares it to gethostbyname() on the hostname that it used to
>mount?
> =20
>
close, the client statd does the gethostbyname() and send the ip address
to the kernel via loopback... The kernel then uses that ip address along
with protocol and version to locate the lock.

>Is this in the specification, or only the linux-implementation?
>
>If that's the case, are we allowed to just send the IP instead of the
>name?
> =20
>
No, since the spec says a the id_mon needs to be character string....

> =20
>
>>Now the=20
>>problem
>>arises when the hostname resolves to a different ip address....=20
>>something this patch
>>is trying to address...
>>   =20
>>
>
>I didn't know the client actually compared IPs - I thought it compared
>the actual names.
> =20
>
The kernel searches the list of nlm_hosts look for the correct=20
ipaddr,proto,vers
threesome...

>Then I guess it's less of a problem than I thought.
>
>A couple of cases where I think it would fail though:
>- If you have inconsistant name-resolution (/etc/hosts) in
>  your system.
> =20
>
Well I don't think it possible to program for a screwy DNS servers,
or should we try.... imho...

>- If you have aliases (eth0, eth0:0) with different IPs but on the
>  same network. The current patch (if I read it correctly) will then
>  use the name from the last alias, which is kind of random.
> =20
>
Well it would not be random, it would be the first interface....

>The second case may be very relevant to the HA-problem which "-n" was
>originally added for.
> =20
>
Yes... the -n flag wold be the answer here...

> <>
>
>There are two reasons to keep -n:
>
I see your point.... especially since all the HA code is now in
the updated FC3 nfs-utils... Believe me the last thing I want to do
is break  that code....  ;-) so attached is an updated patch that should
not affect the HA code at all....

SteveD.

--------------010307030800020808050402
Content-Type: text/plain;
 name="nfs-utils-1.0.6-statd-notify-hostname2.patch"
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-statd-notify-hostname2.patch"
Content-Transfer-Encoding: 7bit

--- nfs-utils-1.0.6/utils/statd/rmtcall.c.orig	2004-11-24 05:42:13.494353000 -0500
+++ nfs-utils-1.0.6/utils/statd/rmtcall.c	2004-11-24 06:02:37.935145000 -0500
@@ -26,6 +26,7 @@
 #include <sys/socket.h>
 #include <sys/time.h>
 #include <netinet/in.h>
+#include <net/if.h>
 #include <arpa/inet.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
@@ -34,6 +35,7 @@
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>
+#include <ifaddrs.h>
 #include "sm_inter.h"
 #include "statd.h"
 #include "notlist.h"
@@ -73,7 +75,44 @@ statd_get_socket(int port)
 
 	return sockfd;
 }
-
+/*
+ * Using the NL_ADDR(lp), reset (if needed) the hostname
+ * that will be put in the SM_NOTIFY to the hostname
+ * that is associated with the network interface 
+ * that was monitored
+ */
+static void
+reset_my_name(notify_list *lp)
+{
+	struct ifaddrs *ifa = NULL, *ifap;
+	struct in_addr netaddr, tmp;
+	struct sockaddr_in *sin, *nsin;
+	struct hostent *hp;
+
+	netaddr.s_addr = inet_netof(NL_ADDR(lp));
+	if (getifaddrs(&ifa) >= 0) {
+		for (ifap = ifa; ifap != NULL; ifap = ifap->ifa_next) {
+			if (ifap->ifa_addr->sa_family != AF_INET)
+				continue;
+			if (!(ifap->ifa_flags & IFF_UP))
+				continue;
+			sin = (struct sockaddr_in *)ifap->ifa_addr;
+			nsin = (struct sockaddr_in *)ifap->ifa_netmask;
+			tmp.s_addr = sin->sin_addr.s_addr & nsin->sin_addr.s_addr;
+			if (memcmp(&tmp.s_addr, &netaddr.s_addr, sizeof(netaddr.s_addr)))
+				continue;
+			hp = gethostbyaddr((char *)&sin->sin_addr, 
+				sizeof(sin->sin_addr), AF_INET);
+			if (hp == NULL)
+				continue;
+			if (strcmp(NL_MY_NAME(lp), hp->h_name)) {
+				free(NL_MY_NAME(lp));
+				NL_MY_NAME(lp)= strdup(hp->h_name);
+			}
+		}
+	}
+	return;
+}
 /*
  * Try to resolve host name for notify/callback request
  *
@@ -283,6 +322,7 @@ process_entry(int sockfd, notify_list *l
 {
 	struct sockaddr_in	sin;
 	struct status		new_status;
+	stat_chge           new_stat;
 	xdrproc_t		func;
 	void			*objp;
 	u_int32_t		proc, vers, prog;
@@ -309,9 +349,19 @@ process_entry(int sockfd, notify_list *l
 
 		/* Use source address for notify replies */
 		sin.sin_addr   = lp->addr;
+		/* 
+		 * Unless a static hostname has been defined
+		 * set the NL_MY_NAME(lp) hostname to the 
+		 * one associated with the network interface
+		 */
+		if (!(run_mode & STATIC_HOSTNAME))
+			reset_my_name(lp);
 
 		func = (xdrproc_t) xdr_stat_chge;
-		objp = &SM_stat_chge;
+		new_stat.state = MY_STATE;
+		new_stat.mon_name = NL_MY_NAME(lp);
+
+		objp = &new_stat;
 		break;
 	case NOTIFY_CALLBACK:
 		prog = NL_MY_PROG(lp);
--- nfs-utils-1.0.6/utils/statd/statd.c.orig	2004-11-24 05:42:15.099369000 -0500
+++ nfs-utils-1.0.6/utils/statd/statd.c	2004-11-24 05:52:27.570265000 -0500
@@ -288,6 +288,7 @@ int main (int argc, char **argv)
 			}
 			break;
 		case 'n':	/* Specify local hostname */
+			run_mode |= STATIC_HOSTNAME;
 			MY_NAME = xstrdup(optarg);
 			break;
 		case 'P':
--- nfs-utils-1.0.6/utils/statd/statd.h.orig	2004-11-24 05:42:14.899371000 -0500
+++ nfs-utils-1.0.6/utils/statd/statd.h	2004-11-24 05:53:50.516929000 -0500
@@ -79,6 +79,7 @@ extern int run_mode;
 /* LH - notify_only mode would be for notifying hosts on an IP alias
  * that just came back up, for ex, when failing over a HA service to
  * another host.... */
+#define STATIC_HOSTNAME 8	/* Always use the hostname set by -n */
 
 /*
  * Program name and version pointers -- See statd.c for the reasoning

--------------010307030800020808050402--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
