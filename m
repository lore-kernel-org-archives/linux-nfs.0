From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: RPC retransmission of write requests containing bogus data
Date: Fri, 17 Oct 2008 12:01:13 +0100
Message-ID: <1224241273.9053.109.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-ukRXEtpJ5dHSj7QDyQY+"
Cc: mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25644 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbYJQLBZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2008 07:01:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-ukRXEtpJ5dHSj7QDyQY+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

(please CC me, I am not currently subscribed to linux-nfs)

Hi,

For some time now I have been tracking down a mysterious host crash when
using Xen with blktap (userspace paravirtual disk implementation) under
stress conditions. I have now managed to create a simple test case with
no Xen components which appears to show RPC retransmissions of write
requests containing invalid data. I'll start at the beginning and
explain the original bug although the test case is much simpler.

blktap is a userspace daemon which provides paravirtualised disk support
to Xen guests. The pages of data for a block write are mapped from the
Xen guest into a domain 0 driver called blktap which has a userspace
component which implements qcow/vhd/etc and writes the data to the
backing file using O_DIRECT and aio in a zero copy manner. Once the  the
aio is completed the pages are returned to the guest and unmapped from
domain 0. When a page is unmapped in this way the pte is set not present
and the PFN is mapped to an invalid MFN.

We have been seeing a crash in the domain 0 network driver's start_xmit
routine when it attempts to access data from a page where the PFN maps
to an invalid MFN. I added some tracing to the kernel and observed this
sequence of events on an individual page:
        tap: 0/41 at 4fac7a165ad6 "rpc_init_task" c8792844 0
        tap: 1/41 at 4fac7a1663e2 "nfs_direct_write_schedule" ece19850 2000
        tap: 2/41 at 4fac7a166cca "call_start" c8792844 0
        tap: 3/41 at 4fac7a167540 "call_reserve" c8792844 0
        tap: 4/41 at 4fac7a167de6 "call_reserveresult" c8792844 0
        tap: 5/41 at 4fac7a168620 "call_allocate" c8792844 0
        tap: 6/41 at 4fac7a168f08 "call_bind" c8792844 0
        tap: 7/41 at 4fac7a169712 "call_connect" c8792844 0
        tap: 8/41 at 4fac7a169f28 "call_transmit" c8792844 0
        tap: 9/41 at 4fac7a16a7f2 "call_encode" c8792844 0
        tap: 10/41 at 4fac7a16afd8 "call_header" c8792844 0
        tap: 11/41 at 4fac7a16bc6e "xs_tcp_send_request" c8792844 0
        tap: 12/41 at 4fac7a16c9d0 "tcp_sendpage" 0 0
        tap: 13/41 at 4fac7a16cec2 "do_tcp_sendpages (adding data to skb)" cef08b00 0
        tap: 14/41 at 4fac7a16e068 "call_transmit_status" c8792844 0
        tap: 15/41 at 4fac7a2ed8f4 "tcp_transmit_skb, skb_clone" c9dca500 c9dca5a8
        tap: 16/41 at 4faeeeb9f566 "xprt_timer" c8792844 0
        tap: 17/41 at 4faeeeb9ff0e "xprt_timer: !req-&gt;rq_received" c8792844 0
        tap: 18/41 at 4faeeeba08ec "rpc_make_runnable" c8792844 0
        tap: 19/41 at 4faeeec117b8 "call_status" c8792844 ffffff92
        tap: 20/41 at 4faeeec11faa "timeout (minor)" c8792844 0
        tap: 21/41 at 4faeeec12778 "call_bind" c8792844 0
        tap: 22/41 at 4faeeec12ef8 "call_connect" c8792844 0
        tap: 23/41 at 4faeeec13678 "call_transmit" c8792844 0
        tap: 24/41 at 4faeeec13e46 "call_encode" c8792844 0
        tap: 25/41 at 4faeeec145ae "call_header" c8792844 0
        tap: 26/41 at 4faeeec15082 "xs_tcp_send_request" c8792844 0
        tap: 27/41 at 4faeeec15d1e "tcp_sendpage" 0 0
        tap: 28/41 at 4faeeec161ce "do_tcp_sendpages (adding data to skb)" d06afe40 0
        tap: 29/41 at 4faeeec172ea "call_transmit_status" c8792844 0
        tap: 30/41 at 4faf2e3280d4 "rpc_make_runnable" c8792844 0
        tap: 31/41 at 4faf2e3440c4 "call_status" c8792844 88
        tap: 32/41 at 4faf2e3449d6 "call_decode" c8792844 0
        tap: 33/41 at 4faf2e345240 "call_verify" c8792844 0
        tap: 34/41 at 4faf2e345a9e "rpc_exit_task" c8792844 0
        tap: 35/41 at 4faf2e34652a "nfs_direct_write_result" ece19850 2000
        tap: 36/41 at 4faf2e351000 "nfs_direct_write_release (completing)" ece19850 0
        tap: 37/41 at 4faf2e3517ec "nfs_direct_write_complete,DEFAULT w/ iocb" ece19850 0
        tap: 38/41 at 4faf2e35205c "nfs_direct_free_writedata" ece19850 0
        tap: 39/41 at 4faf2e51026a "fast_flush_area" 0 0
        tap: 40/41 at 4faf33e1813a "tcp_transmit_skb, skb_clone" d06afe40 d06afee8
(nb: fast_flush_area is the blktap function which returns the pages to
the guest and unmaps them from domain 0, it is called via ioctl from the
userspace process once the aio write returns successfully. 4fac7.... is
the tsc, processor is 2.33GHz)

So what we see is the initial request being constructed and transmitted
(around 11/41-15/41) followed by a timeout ~60s later (16/41-20/41)
which causes us to queue a retransmit (26/41-29/41) but, critically, not
yet actually transmit it. At this point we get the reply to the original
request and complete the NFS write (35/41-38/41) returning success to
userspace which causes it to unmap the pages and return them to the
guest (39/41). At this point (40/41) we attempt to transmit the
duplicate request and crash because the pages are not present any more.

By using libnetfilter_queue I was then able to reproduce this in
non-stress situations by introducing delays into the network. Stalling
all network traffic with the NFS server for 65s every 1000 packets seems
to do the trick (probably on the aggressive side, I didn't attempt to
minimise the interruption required to reproduce and I realise that this
represents a pretty crappy network and/or server).

Given the observed sequence of events I then constructed a fairly simple
test program (blktest2.c, attached) using O_DIRECT (but not aio, I don't
think it matters) which shows the same issue without involving any Xen
parts. The test writes a buffer filed with a counter to a file and
immediately after the write() returns fills the buffer with 0xdeadbeef.
By using tcpdump I capture and observe duplicated requests on the wire
containing 0xdeadbeef in the payload and not the expected counter
values. I usually see this in a matter of minutes. I've attached a pcap
of a single request/reply pair which was corrupted.

Presumably in the case of a decent NFS server the XID request cache
would prevent the bogus data actually reaching the disk but on a
non-decent server I suspect it might actually lead to corruption (AIUI
the request cache is not a hard requirement of the NFS protocol?).
Perhaps even a decent server might have timed out the entry in the cache
after such a delay?

The Xen case and the blktest2 repro was on 2.6.18. I have also
reproduced the blktest2 case on 2.6.27 native but not with Xen since no
domain 0 support exists just yet.

I can think of several possible option to fix this issue:
      * Do not return success to userspace until all duplicated requests
        have actually hit the wire, even if the response comes back
        earlier than that.
      * Cancel queued duplicates if a response comes in late.
      * Copy the data pages on retransmission.

I think I prefer the 3rd option since the first two are a bit tricky
since request has been merged into a tcp stream and may have been
fragmented/segmented already etc. I don't think doing the copy on
retransmits has a massive performance impact -- you must already be
suffering from pretty severe network or server issues!

I have CC'd the maintainer of the bnx2 Ethernet driver (Michael Chan)
because I have so far only been able to reproduce this with the broadcom
NIC. Even in the same server if I switch to e1000 I cannot reproduce.
However given the analysis above I'm not convinced it is likely to be a
driver bug.

Ian.

--=-ukRXEtpJ5dHSj7QDyQY+
Content-Disposition: attachment; filename=netoutage.c
Content-Type: text/x-csrc; name=netoutage.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <netinet/in.h>
#include <linux/types.h>

#include <linux/netfilter.h>            /* for NF_ACCEPT */

#include <libnetfilter_queue/libnetfilter_queue.h>

#include <err.h>
#include <errno.h>

/* "Configuration" */
#define NR 1000 /* Delay 1/NR */
#define HOWLONG 65 /* Delay for HOWLONG seconds */

static int n = 0;

static int cb(struct nfq_q_handle *qh, struct nfgenmsg *nfmsg,
              struct nfq_data *nfa, void *data)
{
        int id = 0;
        struct nfqnl_msg_packet_hdr *ph;
	time_t t = time(NULL);

        ph = nfq_get_msg_packet_hdr(nfa);
        if (ph)
                id = ntohl(ph->packet_id);

	n++;

	if ((n%NR) == 0) {
		printf("%d: delaying at %d for %ds ...", t, id, HOWLONG);
		fflush(stdout);
		sleep(HOWLONG);
		printf("\n");
		n = 0;
	}

	return nfq_set_verdict(qh, id, NF_ACCEPT, 0, NULL);

}

int main(int argc, char **argv)
{
        struct nfq_handle *h;
        struct nfq_q_handle *qh;
        struct nfnl_handle *nh;
        int fd;
        int rv;
        char buf[4096] __attribute__ ((aligned));

        printf("opening library handle\n");
        h = nfq_open();
        if (!h) {
                fprintf(stderr, "error during nfq_open()\n");
                exit(1);
        }

        printf("unbinding existing nf_queue handler for AF_INET (if any)\n");
        if (nfq_unbind_pf(h, AF_INET) < 0) {
                fprintf(stderr, "error during nfq_unbind_pf()\n");
                exit(1);
        }

        printf("binding nfnetlink_queue as nf_queue handler for AF_INET\n");
        if (nfq_bind_pf(h, AF_INET) < 0) {
                fprintf(stderr, "error during nfq_bind_pf()\n");
                exit(1);
        }

        printf("binding this socket to queue '0'\n");
        qh = nfq_create_queue(h,  0, &cb, NULL);
        if (!qh) {
                fprintf(stderr, "error during nfq_create_queue()\n");
                exit(1);
        }

#if 0
        printf("setting copy_packet mode\n");
        if (nfq_set_mode(qh, NFQNL_COPY_PACKET, 0xffff) < 0) {
                fprintf(stderr, "can't set copy_packet mode\n");
                exit(1);
        }
#endif
#if 1
        printf("setting copy_meta mode\n");
        if (nfq_set_mode(qh, NFQNL_COPY_META, 0xffff) < 0) {
                fprintf(stderr, "can't set copy_meta mode\n");
                exit(1);
        }
#endif

        nh = nfq_nfnlh(h);
        fd = nfnl_fd(nh);

	if (nfnl_rcvbufsiz(nh, 10*1024*1024) < 0 ) {
                fprintf(stderr, "error during nfnl_rcvbufsiz()\n");
                exit(1);
	}

        while ((rv = recv(fd, buf, sizeof(buf), 0)) && rv >= 0) {
                nfq_handle_packet(h, buf, rv);
        }

        printf("unbinding from queue 0, rv %d, errno %d\n", rv, errno);
        nfq_destroy_queue(qh);

        printf("closing library handle\n");
        nfq_close(h);

	return 0;
}

--=-ukRXEtpJ5dHSj7QDyQY+
Content-Disposition: attachment; filename=blktest2.c
Content-Type: text/x-csrc; name=blktest2.c; charset=UTF-8
Content-Transfer-Encoding: 7bit

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>

#include <fcntl.h>

#include <err.h>
#include <errno.h>

#define SLEEP 1
#define SIZE 4096
#define NR 256
#define NONCE 0xdead

#define DOCHECK 0
#define RETRYWRITE 0

static void setup(int *data, int val, int size)
{
	int i;
	for (i=0; i<SIZE/sizeof(int); i++)
		data[i] = val;
}

#if DOCHECK
static void check(int *data, int val, int size)
{
	int i;
	for (i=0; i<SIZE/sizeof(int); i++) {
		if (data[i] != val) {
			err(1, "failed to verify %#x got %#x\n",
			     val, data[i]);
		}
	}
}
#endif

int main(int argc, char **argv)
{
	int fd, rc, n, iter = 0;
	const char *path;
	int data[NR][SIZE/sizeof(int)];

	if (argc != 2) {
		fprintf(stderr, "usage: blktest2 [PATH]\n");
		exit(1);
	}
	path = argv[1];

	printf("opening %s for O_DIRECT access\n", path);
	fd = open(path, O_CREAT|O_DIRECT|O_RDWR, 0666);
	if (fd < 0)
		err(1,"unable to open file");

	while(1) {
		if ((iter%10)==0)
			printf("iteration %d ...", iter);

		/* write */
		for(n=0; n<NR; n++) {
			do {
				if (lseek(fd, n * SIZE, SEEK_SET) < 0)
					err(1, "seek for write %d %d\n", iter, n);
				setup(data[n], (NONCE<<16)+(iter<<8)+n, sizeof(data[n]));
				rc = write(fd, data[n], SIZE);
				setup(data[n], 0xdeadbeef, sizeof(data[n]));
				if (rc == -1)
					warn("write failed");
				else if (rc != SIZE)
					err(1, "only wrote %d/%d bytes\n", rc, SIZE);
			} while(RETRYWRITE && rc == -1 && errno == EIO);

		}

#if DOCHECK
		/* check */
		for(n=0; n<NR; n++) {
			do {
				if (lseek(fd, n * SIZE, SEEK_SET) < 0)
					err(1, "seek for read %d %d\n", iter, n);
				rc = read(fd, data[n], SIZE);
				if (rc == -1)
					warn("read failed");
				else if (rc != SIZE)
					warn("only read %d/%d bytes\n", rc, SIZE);
			} while(rc == -1 && errno == EIO);

			check(data[n], (NONCE<<16)+(iter<<8)+n, SIZE);
		}
#endif

		if ((iter%10)==0)
			printf("\n", iter);

		iter++;
	}
}

--=-ukRXEtpJ5dHSj7QDyQY+
Content-Disposition: attachment; filename=corrupt.pcap
Content-Type: application/octet-stream; name=corrupt.pcap
Content-Transfer-Encoding: base64

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


--=-ukRXEtpJ5dHSj7QDyQY+--

