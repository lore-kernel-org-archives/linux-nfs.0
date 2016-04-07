Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.wiktel.com ([69.89.207.152]:35930 "EHLO smtp2.wiktel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751346AbcDGJp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Apr 2016 05:45:59 -0400
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
To: NeilBrown <nfbrown@novell.com>, trond.myklebust@primarydata.com,
        Anna Schumaker <anna.schumaker@netapp.com>
References: <56BFE55D.1010509@wiktel.com>
 <87twjjpcl8.fsf@notabene.neil.brown.name>
From: Richard Laager <rlaager@wiktel.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <57062C53.9080102@wiktel.com>
Date: Thu, 7 Apr 2016 04:45:55 -0500
MIME-Version: 1.0
In-Reply-To: <87twjjpcl8.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/02/2016 10:58 PM, NeilBrown wrote:
> On Sun, Feb 14 2016, Richard Laager wrote:
> 
>> [1.] One line summary of the problem:
>>
>> NFS Client Ignores TCP Resets
>>
>> [2.] Full description of the problem/report:
>>
>> Steps to reproduce:
>> 1) Mount NFS share from HA cluster with TCP.
>> 2) Failover the HA cluster. (The NFS server's IP address moves from one
>>      machine to the other.)
>> 3) Access the mounted NFS share from the client (an `ls` is sufficient).
>>
>> Expected results:
>> Accessing the NFS mount works fine immediately.
>>
>> Actual results:
>> Accessing the NFS mount hangs for 5 minutes. Then the TCP connection
>> times out, a new connection is established, and it works fine again.
>>
>> After the IP moves, the new server responds to the client with TCP RST
>> packets, just as I would expect. I would expect the client to tear down
>> its TCP connection immediately and re-establish a new one. But it
>> doesn't. Am I confused, or is this a bug?
>>
>> For the duration of this test, all iptables firewalling was disabled on
>> the client machine.
>>
>> I have a packet capture of a minimized test (just a simple ls):
>> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1542826/+attachment/4571304/+files/dovecot-test.upstream-kernel.pcap
> 
> I notice that the server sends packets from a different MAC address to
> the one it advertises in ARP replies (and the one the client sends to).
> This is probably normal - maybe you have two interfaces bonded together?
> 
> Maybe it would help to be explicit about the network configuration
> between client and server - are there switches?  soft or hard?
> 
> Where is tcpdump being run?  On the (virtual) client, or on the
> (physical) host or elsewhere?

Yes, there is link bonding happening on both sides. Details below.

This test was run from a VM (for testing purposes), but the problem is
equally reproducible on just the host, with or without this VLAN
attached to a bridge. That is, whether we put the NFS client IP on
bond0 (with no br9 existing) or put it on br9, we get the same behavior
using NFS from the host.

I believe I was running the packet capture from inside the VM.

+------------------------------+
|             Host             |
|                              |
|            +------+          |
|            |  VM  |          |
|            |      |          |
|            | eth0 |          |
|            +------+          |
|               |  VM's eth0   |
|               |  is e.g.     |
|               |  vnet0 on    |
|               |  the host    |
|               |              |
| TCP/IP -------+ br9          |
| Stack         |              |
|               |              |
|               |              |
|               | bond0        |
|       +-------+------+       |
|  p5p1 |              | p6p1  |
|       |              |       |
+-------|              |-------+
        |              |
  10GbE |              | 10GbE
        |              |
  +----------+    +----------+
  | Switch 1 |20Gb| Switch 2 |
  |          |====|          |
  +----------+    +----------+
        |              |
  10GbE |              | 10GbE
        |              |
+-------|              |-------+
|       |              |       |
|  oce0 |              | oce1  |
|       +-------+------+       |
|               | ipmp0        |
|               |              |
| TCP/IP -------+              |
| Stack                        |
|                              |
|         Storage Head         |
+------------------------------+

The switches behave like a single, larger virtual switch.

The VM host is doing actual 802.3ad LAG, whereas the storage heads are
doing Solaris's link-based IPMP.

There are two storage heads, each with two physical interfaces:

krls1:
  oce0: 00:90:fa:34:f3:be
  oce1: 00:90:fa:34:f3:c2
krls2:
  oce0: 00:90:fa:34:f3:3e
  oce1: 00:90:fa:34:f3:42

The failover event in the original packet capture was failing over from
krls1 to krls2.

...
> If you were up to building your own kernel, I would suggest putting some
> printks in tcp_validate_incoming() (in net/ipv4/tcp_input.c).
> 
> Print a message if th->rst is ever set, and another if the
> tcp_sequence() test causes it to be discarded.  It shouldn't but
> something seems to be discarding it somewhere...

I added the changes you suggested:

--- tcp_input.c.orig	2016-04-07 04:11:07.907669997 -0500
+++ tcp_input.c	2016-04-04 19:41:09.661590000 -0500
@@ -5133,6 +5133,11 @@
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	if (th->rst)
+	{
+		printk(KERN_WARNING "Received RST segment.");
+	}
+
 	/* RFC1323: H1. Apply PAWS check first. */
 	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
 	    tcp_paws_discard(sk, skb)) {
@@ -5163,6 +5168,20 @@
 						  &tp->last_oow_ack_time))
 				tcp_send_dupack(sk, skb);
 		}
+		if (th->rst)
+		{
+			printk(KERN_WARNING "Discarding RST segment due to tcp_sequence()");
+			if (before(TCP_SKB_CB(skb)->end_seq, tp->rcv_wup))
+			{
+				printk(KERN_WARNING "RST segment failed before test: %d %d",
+					TCP_SKB_CB(skb)->end_seq, tp->rcv_wup);
+			}
+			if (after(TCP_SKB_CB(skb)->seq, tp->rcv_nxt + tcp_receive_window(tp)))
+			{
+				printk(KERN_WARNING "RST segment failed after test: %d %d %d",
+					TCP_SKB_CB(skb)->seq, tp->rcv_nxt, tcp_receive_window(tp));
+			}
+		}
 		goto discard;
 	}
 
@@ -5174,10 +5193,13 @@
 		 * else
 		 *     Send a challenge ACK
 		 */
-		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt)
+		if (TCP_SKB_CB(skb)->seq == tp->rcv_nxt) {
+			printk(KERN_WARNING "Accepted RST segment");
 			tcp_reset(sk);
-		else
+		} else {
+			printk(KERN_WARNING "Sending challenge ACK for RST segment");
 			tcp_send_challenge_ack(sk, skb);
+		}
 		goto discard;
 	}

...reordered quoted text...
> Can you create a TCP connection to some other port on the server
> (telnet? ssh? http?) and see what happens to it on fail-over?
> You would need some protocol that the server won't quickly close.
> Maybe just "telnet SERVER 2049" and don't type anything until after the
> failover.
> 
> If that closes quickly, then maybe it is an NFS bug.  If that persists
> for a long timeout before closing, then it must be a network bug -
> either in the network code or the network hardware.
> In that case, netdev@vger.kernel.org might be the best place to ask.

I tried "telnet 10.20.0.30 22". I got the SSH header. I sent no input,
forced a storage cluster failover, and then hit enter after the
failover was complete. The ssh connection immediately terminated. My
tcp_validate_incoming() debugging code, as expected, showed "Received
RST segment." and "Accepted RST segment". These correspond to the one
RST packet I received on the SSH connection.

In a separate failover event, I tested accessing NFS over TCP. I do
*not* get "Received RST segment.". So I conclude that
tcp_validate_incoming() is not being called.

Any thoughts on what that means or where to go from here?

-- 
Richard
