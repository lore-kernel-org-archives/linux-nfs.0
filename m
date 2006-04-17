From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bridge] Re: No UDP NFS over bridges in Linux 2.6.16.x?
Date: Mon, 17 Apr 2006 20:24:52 +0200
Message-ID: <4443DD74.80101@trash.net>
References: <20060417181727.43038.qmail@web52902.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090605020808040005070004"
Cc: Stephen Hemminger <shemminger@osdl.org>,
	nfs@lists.sourceforge.net, bridge@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVYPB-0000mv-88
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 11:24:57 -0700
Received: from stinky.trash.net ([213.144.137.162])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FVYP9-0003YQ-KP
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 11:24:57 -0700
To: Chris Rankin <rankincj@yahoo.com>
In-Reply-To: <20060417181727.43038.qmail@web52902.mail.yahoo.com>
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
--------------090605020808040005070004
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Chris Rankin wrote:
> --- Patrick McHardy <kaber@trash.net> wrote:
> 
>>I only saw half of this thread (Chris' mails haven't made it to the list
>>yet), but in case you're using bridge-netfilter and conntrack, its most
>>likely because of conntrack fragmentation changes in 2.6.16. Conntrack
>>defragments packets, but relies on the IP layer to do the
>>refragmentation now. With purely bridged traffic, the packets don't go
>>through the IP layer, so they exceed the MTU of the outgoing bridge
>>port. 2.6.16.6 will include a fix for this problem:
>>
>>[patch 06/22] NETFILTER: Fix fragmentation issues with bridge netfilter
> 
> 
> I emailed the packet dumps to Stephen privately, but what was happening was that the server was
> receiving the request and was fragmenting the reply.  However, the client was never receiving the
> reply packets for some reason.

I guess the request is small enough so it doesn't have to be fragmented.

> Yes, I am using connection tracking and netfilter, and the br0 interface is referenced in my
> iptables rules. I am not using / have not loaded the ebtables modules, although I did compile
> them.

Its enough to have CONFIG_BRIDGE_NETFILTER enabled for this error
to occur, it passes bridged packets to IP netfilter by default.

Attached is the patch queued for -stable, please try if it helps.

--------------090605020808040005070004
Content-Type: text/plain;
 name="netfilter-fix-fragmentation-issues-with-bridge-netfilter.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netfilter-fix-fragmentation-issues-with-bridge-netfilter.patch"

-stable review patch.  If anyone has any objections, please let us know.

------------------
[NETFILTER]: Fix fragmentation issues with bridge netfilter

The conntrack code doesn't do re-fragmentation of defragmented packets
anymore but relies on fragmentation in the IP layer. Purely bridged
packets don't pass through the IP layer, so the bridge netfilter code
needs to take care of fragmentation itself.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 include/net/ip.h          |    1 +
 net/bridge/br_netfilter.c |   13 +++++++++++--
 net/ipv4/ip_output.c      |    6 +++---
 3 files changed, 15 insertions(+), 5 deletions(-)

--- linux-2.6.16.5.orig/include/net/ip.h
+++ linux-2.6.16.5/include/net/ip.h
@@ -95,6 +95,7 @@ extern int		ip_local_deliver(struct sk_b
 extern int		ip_mr_input(struct sk_buff *skb);
 extern int		ip_output(struct sk_buff *skb);
 extern int		ip_mc_output(struct sk_buff *skb);
+extern int		ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 extern int		ip_do_nat(struct sk_buff *skb);
 extern void		ip_send_check(struct iphdr *ip);
 extern int		ip_queue_xmit(struct sk_buff *skb, int ipfragok);
--- linux-2.6.16.5.orig/net/bridge/br_netfilter.c
+++ linux-2.6.16.5/net/bridge/br_netfilter.c
@@ -739,6 +739,15 @@ out:
 	return NF_STOLEN;
 }
 
+static int br_nf_dev_queue_xmit(struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_IP) &&
+	    skb->len > skb->dev->mtu &&
+	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
+		return ip_fragment(skb, br_dev_queue_push_xmit);
+	else
+		return br_dev_queue_push_xmit(skb);
+}
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
 static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff **pskb,
@@ -798,7 +807,7 @@ static unsigned int br_nf_post_routing(u
 		realoutdev = nf_bridge->netoutdev;
 #endif
 	NF_HOOK(pf, NF_IP_POST_ROUTING, skb, NULL, realoutdev,
-	        br_dev_queue_push_xmit);
+	        br_nf_dev_queue_xmit);
 
 	return NF_STOLEN;
 
@@ -843,7 +852,7 @@ static unsigned int ip_sabotage_out(unsi
 	if ((out->hard_start_xmit == br_dev_xmit &&
 	    okfn != br_nf_forward_finish &&
 	    okfn != br_nf_local_out_finish &&
-	    okfn != br_dev_queue_push_xmit)
+	    okfn != br_nf_dev_queue_xmit)
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	    || ((out->priv_flags & IFF_802_1Q_VLAN) &&
 	    VLAN_DEV_INFO(out)->real_dev->hard_start_xmit == br_dev_xmit)
--- linux-2.6.16.5.orig/net/ipv4/ip_output.c
+++ linux-2.6.16.5/net/ipv4/ip_output.c
@@ -86,8 +86,6 @@
 
 int sysctl_ip_default_ttl = IPDEFTTL;
 
-static int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*));
-
 /* Generate a checksum for an outgoing IP datagram. */
 __inline__ void ip_send_check(struct iphdr *iph)
 {
@@ -421,7 +419,7 @@ static void ip_copy_metadata(struct sk_b
  *	single device frame, and queue such a frame for sending.
  */
 
-static int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
+int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff*))
 {
 	struct iphdr *iph;
 	int raw = 0;
@@ -673,6 +671,8 @@ fail:
 	return err;
 }
 
+EXPORT_SYMBOL(ip_fragment);
+
 int
 ip_generic_getfrag(void *from, char *to, int offset, int len, int odd, struct sk_buff *skb)
 {

--


--------------090605020808040005070004--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
