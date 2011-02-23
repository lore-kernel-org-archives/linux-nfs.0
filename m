Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:53463 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751927Ab1BWTaF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Feb 2011 14:30:05 -0500
Message-ID: <4D655FAE.6070105@parallels.com>
Date: Wed, 23 Feb 2011 13:27:42 -0600
From: Rob Landley <rlandley@parallels.com>
To: NeilBrown <neilb@suse.de>
CC: <linux-nfs@vger.kernel.org>
Subject: NFS in containers
References: <4D63BAA0.3090505@parallels.com>	<20110223080731.6c013be2@notabene.brown>	<4D64861F.5000707@parallels.com> <20110223165317.60cf5a3b@notabene.brown>
In-Reply-To: <20110223165317.60cf5a3b@notabene.brown>
Content-Type: multipart/mixed;
	boundary="------------010203050708040706060808"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------010203050708040706060808
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 02/22/2011 11:53 PM, NeilBrown wrote:
> On Tue, 22 Feb 2011 21:59:27 -0600 Rob Landley <rlandley@parallels.com> wrote:
>> (I'm trying to hunt down a specific bug where a cached value of some
>> kind is using the wrong struct net * context, and thus if I mount nfsv3
>> from the host context it works, and from a container it also works, but
>> if I have different (overlapping) network routings in host and container
>> and I mount the same IP from the host from the container it doesn't
>> work, even if I _unmount_ the host's copy before mounting the
>> container's copy (or vice versa).  But that it starts working again when
>> I give it a couple minutes after the umount for the cache data to time
>> out...)
> 
> I'm a little fuzzy about the whole 'struct net * context' thing,

Look at the clone 2 man page for CLONE_NET_NS.

It basically allows a process group to see its own set of network
interfaces, with different routing (and even different iptables rules)
than other groups of processes.

The network namespace pointer is passed as an argument to
__sock_create() so each socket that gets created lives within a given
network namespace, and all operations that happen on it after that are
relative to that network namespace.

There's a global "init_net" context which is what PID 1 gets and which
things inherit by default, but as soon as you unshare(CLONE_NET_NS) you
get your own struct net instance in current->nsproxy->net_ns.

All the networking userspace processes do is automatically relative to
their network namespace, but when the kernel opens its own sockets, the
kernel code has to supply a namespace.  Things like CIFS and NFS were
doing a lot of stuff relative to the PID 1 namespace because &init_net
is a global that you can reach out and grab without having to care about
details (or worry about reference counting on).

> but in
> cache.c, it only seems to be connected with server-side things, while you
> seem to be talking about client-side things so maybe there is a disconnect
> there.  Not sure though.

Nope, it's client side.  The server I'm testing currently against is
entirely userspace (unfs3.sourceforge.net) and running on a different
machine.  (Well, my test environment is in kvm and the server is running
on the host laptop.)

what I'm trying to do is set up a new network namespace ala
unshare(CLONE_NET_NS), set up different network routing for that process
than the host has (current->nsproxy->net_ns != &init_net), and then
mount NFS from within that.  And I made that part work: as long as only
_one_ network context ever mounts an NFS share.  If multiple contexts
their own mounts, the rpc caches mix together and interfere with each
other.  (At least I think that's what's going wrong.)

Here's documentatoin on how I set up my test environment.  I set up a
containers test environment using the LXC package here:

  http://landley.livejournal.com/47024.html

Then I set up network routing for it here:

  http://landley.livejournal.com/47205.html

Here are my blog entries about getting Samba to work:

  http://landley.livejournal.com/47476.html
  http://landley.livejournal.com/47761.html

Which resulted in commit f1d0c998653f1eeec60 which was a patch to make
CIFS mounting work inside a container (although kerberos doesn't yet).

Notice that my test setup intentionally sets up conflicting addresses:
outside the container, packets get routed through eth0 where "10.0.2.2"
as an alias for 127.0.0.1 on the machine running KVM.  But inside the
container, packets get routed through eth1 which is a tap interface and
can talk to a 10.0.2.2 address on the machine running KVM.  So both
contexts see a 10.0.2.2, but they route to different places, meaning I
can demonstrate this _failing_ as well as succeeding.

Of course you can't reach out and dereference current-> unless you know
you're always called from process context (and the RIGHT process context
at that), so you have to cache these values at mount time and refer to
the cached copies later.  (And do a get_net() to incrememt the reference
counter in case the process that called you goes away, and do a
put_net() when you discard your reference.  And don't ask me what's
supposed to happen when you call mount -o remount on a network
filesystem _after_ calling unshare(CLONE_NET_NS).  Keep the old network
context, I guess.  Doing that may be considered pilot error anyway, I'm
not sure.)

My first patch (nfs2.patch, attached) made mounting NFSv3 in the
container work for a fairly restricted test case (mountd and nfsd
explicilty specified by port number, so no portmapper involved), and
only as long as I don't ALSO mount an NFS share on the same IP address
from some other context (such as outside the container).  When I do, the
cache mixes the two 10.0.2.2 instances together somehow.  (Among other
things, I have to teach the idempotent action replay mechanism that
matching addresses isn't enough, you also have to match network
namespaces.  Except my test is just "mount; ls; cat file; umount" and
it's still not working, so that's additional todo items for later.  I
haven't even started on lockd yet.)

The problem persists after I umount, but times out after a couple
minutes and eventually starts working again.  Of the many different
caches, I don't know WHICH ones I need to fix yet, or even what they all
do.  I haven't submitted this patch yet because I'm still making sure
get_sb() is only ever called from the correct process context such via
the mount() system call, so dereferencing current like I'm doing to grab
the network context is ok.  (I think this is the case, but proving a
negative is time consuming and I've got several balls in the air.  If it
is the case, I need to add comments to that effect.)

My second patch (sunrpc1.patch) was an attempt to fix my first guess at
which cache wasn't takeing network namespace into account when matching
addresses.  It compiled and worked but didn't fix the problem I was
seeing, and I'm singificantly less certain my use of
current->nsproxy->net_ns in there is correct, or that I'm not missing an
existing .net buried in a structure somewhere.

I'm working on about three other patches now, but still trying to figure
out where the actual _failure_ is.  (The entire transaction is a dozen
or so packets.  These packets are generated in an elaborate ceremony
during which a chicken is sacrificed to the sunrpc layer.)

>> Mostly I'm assuming you guys know what you're doing and that my
>> understanding of the enormous layers of nested cacheing is incomplete,
>> but there's a lot of complexity to dig through here...
> 
> You are too kind.   "Once thought we knew what we were doing" is about as
> much as I'd own up to :-)

Don't get me wrong, I hate NFS at the design level.

I consider it "the cobol of filesystems", am convinced that at least 2/3
of its code is premature optimization left over from the 80's, hate the
way it reimplements half the VFS, consider a "stateless filesystem
server" to be a contradiction in terms, thought that khttpd and the tux
web server had already shown that having servers in kernel space simply
isn't worth it, can't figure out why ext3 was a separate filesystem from
ext2 but nfsv4/nfsv3 are mixed together, consider the NFSv4 design to be
a massive increase in complexity without necessarily being an
improvement over v3 in cache coherency or things like "my build broke
when it tried to rm -rf a directory a process still had a file open in",
and am rooting for the Plan 9 filesystem (or something) to eventually
replace it.  I'm only working on it because my employer told me to.

That said, a huge amount of development and testing has gone into the
code that's there, and it's been working for a lot of people for a long
time under some serious load.  (But picking apart the layers of strange
asynchronous cacheing and propogating namespace information through them
would not be my first choice of recreational activities.)

> If you are looking at client-side handling of net contexts, you probably want
> to start at rpc_create which does something with args->net.
> Find out where that value came from, and where it is going to.  Maybe that
> will help.  (But if you find any wild geese, let me know!)

I've been reading through this code, and various standards documents,
and conference papers, and so on, for weeks now.  (You are in a maze of
twisty little cache management routines with lifetime rules people have
written multiple conflicting conference papers on.)

I'm now aware of an awful lot more things I really don't understand
about NFS than I was when I started, and although I now know more about
what it does I understand even _less_ about _why_.

Still, third patch is the charm.  I should go get a chicken.

> NeilBrown

Rob

--------------010203050708040706060808
Content-Type: text/x-patch; name="nfs2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="nfs2.patch"

From: Rob Landley <rlandley@parallels.com>

This is not a complete fix, but this lets you mount an NFSv3 server 
via UDP from a container.

So, I set up duplicate 10.0.2.15 addresses, the first is eth0 on the 
KVM system, the second is an alias for loopback on the host.  This 
means that only the container can see the host's 10.0.2.15, the host 
gets its local interface for that address.

On the host I did:

  unfsd -d -s -p -e $(pwd)/export -l 10.0.2.15 -m 9999 -n 9999

In the container I did:

  mkdir nfsdir
  mount -t nfs -o ro,port=9999,mountport=9999,nolock,nfsvers=3,udp \
    10.0.2.15:/home/landley/nfs/unfs3-0.9.22/doc nfsdir
  ls -l nfsdir
  umount nfsdir

And it mounted and listed the directory contents.

Note: if you try to mount from the same server in both the host and the 
container, the darn superblock merging in the cache screws stuff up, I 
still need to fix that.  It gets cached for several minutes before 
timing out.

I'm working to confirm that get_sb() is never called from anything
other than mount's process context (NO OTHER FILESYSTEM EVER USES
THIS HOOK!), but the rpc code is already doing the get_net() and
put_net() reference counting for lifetimes.  (Except for the bits
where I still have to fix the cacheing.)

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

 fs/nfs/client.c     |    3 ++-
 fs/nfs/mount_clnt.c |    7 +++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 192f2f8..4fb94e9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -39,6 +39,7 @@
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/user_namespace.h>
 
 #include <asm/system.h>
 
@@ -619,7 +620,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= current->nsproxy->net_ns,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index d4c2d6b..5564f64 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_fs.h>
+#include <linux/user_namespace.h>
 #include "internal.h"
 
 #ifdef RPC_DEBUG
@@ -140,6 +141,8 @@ struct mnt_fhstatus {
  * @info: pointer to mount request arguments
  *
  * Uses default timeout parameters specified by underlying transport.
+ *
+ * This is always called from process context.
  */
 int nfs_mount(struct nfs_mount_request *info)
 {
@@ -153,7 +156,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.rpc_resp	= &result,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= current->nsproxy->net_ns,
 		.protocol	= info->protocol,
 		.address	= info->sap,
 		.addrsize	= info->salen,
@@ -225,7 +228,7 @@ void nfs_umount(const struct nfs_mount_request *info)
 		.to_retries = 2,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= current->nsproxy->net_ns,
 		.protocol	= IPPROTO_UDP,
 		.address	= info->sap,
 		.addrsize	= info->salen,


--------------010203050708040706060808
Content-Type: text/x-patch; name="sunrpc1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="sunrpc1.patch"

From: Rob Landley <rlandley@parallels.com>

Teach the auth_unix cache to check network namespace when comparing addresses.

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

 net/sunrpc/svcauth_unix.c |   21 ++++++++++++++-------
 1 file changed, 14 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 30916b0..63a2fa7 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -14,6 +14,7 @@
 #include <net/sock.h>
 #include <net/ipv6.h>
 #include <linux/kernel.h>
+#include <linux/user_namespace.h>
 #define RPCDBG_FACILITY	RPCDBG_AUTH
 
 #include <linux/sunrpc/clnt.h>
@@ -94,6 +95,7 @@ struct ip_map {
 	struct cache_head	h;
 	char			m_class[8]; /* e.g. "nfsd" */
 	struct in6_addr		m_addr;
+	struct net		*m_net;
 	struct unix_domain	*m_client;
 #ifdef CONFIG_NFSD_DEPRECATED
 	int			m_add_change;
@@ -134,6 +136,7 @@ static int ip_map_match(struct cache_head *corig, struct cache_head *cnew)
 	struct ip_map *orig = container_of(corig, struct ip_map, h);
 	struct ip_map *new = container_of(cnew, struct ip_map, h);
 	return strcmp(orig->m_class, new->m_class) == 0 &&
+	       orig->m_net == new->m_net &&
 	       ipv6_addr_equal(&orig->m_addr, &new->m_addr);
 }
 static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
@@ -142,6 +145,7 @@ static void ip_map_init(struct cache_head *cnew, struct cache_head *citem)
 	struct ip_map *item = container_of(citem, struct ip_map, h);
 
 	strcpy(new->m_class, item->m_class);
+	new->m_net = item->m_net;
 	ipv6_addr_copy(&new->m_addr, &item->m_addr);
 }
 static void update(struct cache_head *cnew, struct cache_head *citem)
@@ -186,7 +190,7 @@ static int ip_map_upcall(struct cache_detail *cd, struct cache_head *h)
 	return sunrpc_cache_pipe_upcall(cd, h, ip_map_request);
 }
 
-static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class, struct in6_addr *addr);
+static struct ip_map *__ip_map_lookup(struct cache_detail *cd, struct net *net, char *class, struct in6_addr *addr);
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm, struct unix_domain *udom, time_t expiry);
 
 static int ip_map_parse(struct cache_detail *cd,
@@ -256,7 +260,8 @@ static int ip_map_parse(struct cache_detail *cd,
 		dom = NULL;
 
 	/* IPv6 scope IDs are ignored for now */
-	ipmp = __ip_map_lookup(cd, class, &sin6.sin6_addr);
+	ipmp = __ip_map_lookup(cd, current->nsproxy->net_ns, class,
+			       &sin6.sin6_addr);
 	if (ipmp) {
 		err = __ip_map_update(cd, ipmp,
 			     container_of(dom, struct unix_domain, h),
@@ -301,13 +306,14 @@ static int ip_map_show(struct seq_file *m,
 }
 
 
-static struct ip_map *__ip_map_lookup(struct cache_detail *cd, char *class,
-		struct in6_addr *addr)
+static struct ip_map *__ip_map_lookup(struct cache_detail *cd, struct net *net,
+		char *class, struct in6_addr *addr)
 {
 	struct ip_map ip;
 	struct cache_head *ch;
 
 	strcpy(ip.m_class, class);
+	ip.m_net = net;
 	ipv6_addr_copy(&ip.m_addr, addr);
 	ch = sunrpc_cache_lookup(cd, &ip.h,
 				 hash_str(class, IP_HASHBITS) ^
@@ -325,7 +331,7 @@ static inline struct ip_map *ip_map_lookup(struct net *net, char *class,
 	struct sunrpc_net *sn;
 
 	sn = net_generic(net, sunrpc_net_id);
-	return __ip_map_lookup(sn->ip_map_cache, class, addr);
+	return __ip_map_lookup(sn->ip_map_cache, net, class, addr);
 }
 
 static int __ip_map_update(struct cache_detail *cd, struct ip_map *ipm,
@@ -748,8 +754,9 @@ svcauth_unix_set_client(struct svc_rqst *rqstp)
 
 	ipm = ip_map_cached_get(xprt);
 	if (ipm == NULL)
-		ipm = __ip_map_lookup(sn->ip_map_cache, rqstp->rq_server->sv_program->pg_class,
-				    &sin6->sin6_addr);
+		ipm = __ip_map_lookup(sn->ip_map_cache, net,
+				      rqstp->rq_server->sv_program->pg_class,
+				      &sin6->sin6_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;

--------------010203050708040706060808--
