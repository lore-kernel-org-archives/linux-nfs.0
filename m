Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:41612 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdLHNws (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Dec 2017 08:52:48 -0500
Message-ID: <1512741164.25033.28.camel@gmail.com>
Subject: Re: NFS corruption, fixed by echo 1 > /proc/sys/vm/drop_caches --
 next debugging steps?
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
        Matt Turner <mattst88@gmail.com>
Cc: "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        linux-nfs@vger.kernel.org, Paolo Abeni <pabeni@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "Peter Zijlstra (Intel)" <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>,
        Manuel Lauss <manuel.lauss@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
Date: Fri, 08 Dec 2017 05:52:44 -0800
In-Reply-To: <CANn89iJKGRLVNAE99JWiyXcOXveytkjbQAiZ9XPiJc6fyEdFVA@mail.gmail.com>
References: <CAEdQ38HcOgAT6wJWWKY3P0hzYwkBGSQkRSQ2a=eaGmD6c6rwXA@mail.gmail.com>
         <CAEdQ38G4VTXDGOarmmTac=hP92VJbQHRFxQTaSWQ3j4d63pogg@mail.gmail.com>
         <CAEdQ38HcPswBk3pUHzQerFZ=4KjPc5nVYTqNnGQNMk7QbPXuOQ@mail.gmail.com>
         <CANn89iJKGRLVNAE99JWiyXcOXveytkjbQAiZ9XPiJc6fyEdFVA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-12-08 at 05:42 -0800, Eric Dumazet wrote:
> On Thu, Dec 7, 2017 at 11:54 PM, Matt Turner <mattst88@gmail.com>
> wrote:
> > On Thu, Dec 7, 2017 at 11:00 PM, Matt Turner <mattst88@gmail.com>
> > wrote:
> > > On Sun, Mar 12, 2017 at 6:43 PM, Matt Turner <mattst88@gmail.com>
> > > wrote:
> > > > On a Broadcom BCM91250a MIPS system I can reliably trigger NFS
> > > > corruption on the first file read.
> > > > 
> > > > To demonstrate, I downloaded five identical copies of the gcc-
> > > > 5.4.0
> > > > source tarball. On the NFS server, they hash to the same value:
> > > > 
> > > > server distfiles # md5sum gcc-5.4.0.tar.bz2*
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
> > > > 
> > > > On the MIPS system (the NFS client):
> > > > 
> > > > bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2.2
> > > > 35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
> > > > bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
> > > > 35346975989954df8a8db2b034da610d  gcc-5.4.0.tar.bz2.2
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
> > > > 
> > > > The first file read will contain some corruption, and it is
> > > > persistent until...
> > > > 
> > > > bcm91250a-le distfiles # echo 1 > /proc/sys/vm/drop_caches
> > > > bcm91250a-le distfiles # md5sum gcc-5.4.0.tar.bz2*
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.1
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.2
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.3
> > > > 4c626ac2a83ef30dfb9260e6f59c2b30  gcc-5.4.0.tar.bz2.4
> > > > 
> > > > the caches are dropped, at which point it reads back properly.
> > > > 
> > > > Note that the corruption is different across reboots, both in
> > > > the size
> > > > of the corruption and the location. I saw 1900~ and 1400~ byte
> > > > sequences corrupted on separate occasions, which don't
> > > > correspond to
> > > > the system's 16kB page size.
> > > > 
> > > > I've tested kernels from v3.19 to 4.11-rc1+ (master branch from
> > > > today). All exhibit this behavior with differing frequencies.
> > > > Earlier
> > > > kernels seem to reproduce the issue less often, while more
> > > > recent
> > > > kernels reliably exhibit the problem every boot.
> > > > 
> > > > How can I further debug this?
> > > 
> > > I think I was wrong about the statement about kernels v3.19 to
> > > 4.11-rc1+. I found out I couldn't reproduce with 4.7-rc1 and then
> > > bisected to 4cd13c21b207e80ddb1144c576500098f2d5f882 ("softirq:
> > > Let
> > > ksoftirqd do its job"). Still reproduces with current tip of
> > > Linus'
> > > tree.
> > > 
> > > Any ideas? The board's ethernet is an uncommon device supported
> > > by
> > > CONFIG_SB1250_MAC. Something about the ethernet driver maybe?
> > 
> > With the patch reverted on master (reverts cleanly), NFS corruption
> > no
> > longer happens.
> 
> Hi Matt.
> 
> Thanks for bisecting.
> 
> Patch simply exposes an existing bug more often by changing the way
> driver functions are scheduled.
> 
> Which is probably a good thing.
> 
> sbmac_intr() looks extremely suspicious to me.
> 
> A NAPI driver hard interrupt should simply schedule NAPI.
> 
> Apparently, if sbmac_intr() can not grab NAPIF_STATE_SCHED bit, it
> directly calls sbdma_rx_process() from
> hard interrupt context.
> 
> Insane really.

Please try this fix (not compiled on my x86 laptop, and I had no coffee
yet, so it might have some trivial errors)

diff --git a/drivers/net/ethernet/broadcom/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
index ecdef42f0ae63641419a603f0b4eec2fc213c334..3ddd9ca469b280e70509b22fd7d3f449c81fbedc 100644
--- a/drivers/net/ethernet/broadcom/sb1250-mac.c
+++ b/drivers/net/ethernet/broadcom/sb1250-mac.c
@@ -287,8 +287,6 @@ static int sbdma_add_rcvbuffer(struct sbmac_softc *sc, struct sbmacdma *d,
 static int sbdma_add_txbuffer(struct sbmacdma *d, struct sk_buff *m);
 static void sbdma_emptyring(struct sbmacdma *d);
 static void sbdma_fillring(struct sbmac_softc *sc, struct sbmacdma *d);
-static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
-			    int work_to_do, int poll);
 static void sbdma_tx_process(struct sbmac_softc *sc, struct sbmacdma *d,
 			     int poll);
 static int sbmac_initctx(struct sbmac_softc *s);
@@ -1063,7 +1061,7 @@ static void sbmac_netpoll(struct net_device *netdev)
  ********************************************************************* */
 
 static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
-			    int work_to_do, int poll)
+			    int work_to_do)
 {
 	struct net_device *dev = sc->sbm_dev;
 	int curidx;
@@ -1076,7 +1074,6 @@ static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
 
 	prefetch(d);
 
-again:
 	/* Check if the HW dropped any frames */
 	dev->stats.rx_fifo_errors
 	    += __raw_readq(sc->sbm_rxdma.sbdma_oodpktlost) & 0xffff;
@@ -1169,10 +1166,7 @@ static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
 				}
 				prefetch(sb->data);
 				prefetch((const void *)(((char *)sb->data)+32));
-				if (poll)
-					dropped = netif_receive_skb(sb);
-				else
-					dropped = netif_rx(sb);
+				dropped = netif_receive_skb(sb);
 
 				if (dropped == NET_RX_DROP) {
 					dev->stats.rx_dropped++;
@@ -1201,10 +1195,6 @@ static int sbdma_rx_process(struct sbmac_softc *sc, struct sbmacdma *d,
 		d->sbdma_remptr = SBDMA_NEXTBUF(d,sbdma_remptr);
 		work_done++;
 	}
-	if (!poll) {
-		work_to_do = 32;
-		goto again; /* collect fifo drop statistics again */
-	}
 done:
 	return work_done;
 }
@@ -2006,11 +1996,6 @@ static irqreturn_t sbmac_intr(int irq,void *dev_instance)
 			__napi_schedule(&sc->napi);
 			/* Depend on the exit from poll to reenable intr */
 		}
-		else {
-			/* may leave some packets behind */
-			sbdma_rx_process(sc,&(sc->sbm_rxdma),
-					 SBMAC_MAX_RXDESCR * 2, 0);
-		}
 	}
 	return IRQ_RETVAL(handled);
 }
@@ -2529,7 +2514,7 @@ static int sbmac_poll(struct napi_struct *napi, int budget)
 	struct sbmac_softc *sc = container_of(napi, struct sbmac_softc, napi);
 	int work_done;
 
-	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), budget, 1);
+	work_done = sbdma_rx_process(sc, &(sc->sbm_rxdma), budget);
 	sbdma_tx_process(sc, &(sc->sbm_txdma), 1);
 
 	if (work_done < budget) {


