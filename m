From: Richard Perrin <rcp@sentientmeat.ca>
Subject: Hang in 2.6.11.11 NFSv3 client following NFSERR_JUKEBOX
Date: Wed, 17 Aug 2005 09:32:57 -0400
Message-ID: <20050817133257.GK13622@sentientmeat.ca>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="kXdP64Ggrk/fb43R"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5O8g-0002MM-BV
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 06:39:30 -0700
Received: from smtp104.rog.mail.re2.yahoo.com ([206.190.36.82])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1E5O8f-0003kv-Qp
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 06:39:30 -0700
Received: from rcp by flanker.sentientmeat.ca with local (Exim 3.35 #1 (Debian))
	id 1E5O2M-0006fk-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Aug 2005 09:32:58 -0400
To: nfs@lists.sourceforge.net
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


--kXdP64Ggrk/fb43R
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Summary:
After receiving an ERR_JUKEBOX, client does not appear to resend request.
- Script to reproduce enclosed.
- Packet capture available at
  http://sentientmeat.ca/~rcp/tmp/nfs_traffic.gz
- Reproduceable via interaction with a Samba server having oplocks enabled.
- Related to Haakon Riiser's message of 2005-05-08 to the NFS list
(http://sourceforge.net/mailarchive/message.php?msg_id=11689791).

Please see attached script for the order of operations. The end result is
that a process reading a file on the NFSv3 client machine will become
hung, unresponsive to signals after it receives the JUKEBOX error that
the server sends. ps(1) reveals the NFS reading process to be in
uninterruptible sleep.

Same process behaviour was witnessed with both UDP and TCP modes.

The second client (running the script on kernel 2.4) saw 5-10 second
pauses in its read loop, but never became unresponsive.


Server config:
Linux solace1 2.6.9-11.ELsmp #1 SMP Fri May 20 18:26:27 EDT 2005 i686 i686 i386 GNU/Linux
Red Hat Enterprise Linux ES release 4 (Nahant Update 1)
Dell PowerEdge 2850

Client config:
Linux solace46 2.6.11.11sol-poweredge1850 #5 SMP Fri Aug 12 14:59:28 EDT 2005 i686 i686 i386 GNU/Linux
Fedora Core 4
Dell PowerEdge 1850

Client 2 (unaffected) config:
Red Hat Linux release 9 (Shrike)
Linux solace4 2.4.20-8smp #1 SMP Thu Mar 13 17:45:54 EST 2003 i686 i686 i386 GNU/Linux


# tcpdump -r nfs_traffic
[...]
16:18:24.018188 solace1.nfs > solace46.2645644236: reply ok 112 getattr REG 100666 ids 42073/508 sz 0x00004ec8b  (DF)
16:18:24.018310 solace46.2662421452 > solace1.nfs: 124 access fh Unknown/1 002d (DF)
16:18:24.018563 solace1.nfs > solace46.2662421452: reply ok 120 access c 000d (DF)
16:18:24.018608 solace46.2679198668 > solace1.nfs: 132 read fh Unknown/1 4096 bytes @ 0x000000000 (DF)
16:18:24.018623 solace46.2695975884 > solace1.nfs: 132 read fh Unknown/1 4096 bytes @ 0x000001000 (DF)
16:18:24.018631 solace46.2712753100 > solace1.nfs: 132 read fh Unknown/1 4096 bytes @ 0x000002000 (DF)
16:18:24.018818 solace1.nfs > solace46.2679198668: reply ok 116 read ERROR: Request couldn't be completed in time (DF)
16:18:24.018826 solace1.nfs > solace46.2695975884: reply ok 116 read ERROR: Request couldn't be completed in time (DF)
16:18:24.019063 solace1.nfs > solace46.2712753100: reply ok 116 read ERROR: Request couldn't be completed in time (DF)

This appears to be a bug in the NFS client, as the NFSv3 RFC states
that "The client should wait and then try the request with a new RPC
transaction ID.". The packet capture above reveals that the client is
not trying the request again within any reasonable time.

# ps -lF -C nfstst
F S UID        PID  PPID  C PRI  NI ADDR SZ WCHAN    RSS PSR STIME TTY          TIME CMD
0 D root      2336  2306  0  77   0 -   352 sync_p   288   3 16:18 pts/1    00:00:00 ./nfstst BREAKME.txt

# echo t >/proc/sysrq-trigger
# dmesg
[...]
nfstst        D 00000020     0  2336   2306                     (NOTLB)
f58e3d1c 00000086 f58e3d0c 00000020 00000003 f589db98 f58e3d40 c31eaa80
       00000003 00000000 000001d2 c013f223 c0339320 c0338080 c3030060 00000003
       00000000 0e731d40 000f424d 00000000 c3373550 c33736a8 c0339320 00000004
Call Trace:
 [<c013f223>] __alloc_pages+0x2e3/0x420
 [<c02df9b8>] io_schedule+0x28/0x40
 [<c0139de5>] sync_page+0x45/0x60
 [<c02e06ff>] _spin_unlock_irqrestore+0xf/0x30
 [<c02dfd1f>] __wait_on_bit_lock+0x5f/0x70
 [<c0139da0>] sync_page+0x0/0x60
 [<c012f9a0>] wake_bit_function+0x0/0x60
 [<c013a691>] __lock_page+0x91/0xa0
 [<c012f9a0>] wake_bit_function+0x0/0x60
 [<c0141c3d>] page_cache_readahead+0x24d/0x2d0
 [<c012f9a0>] wake_bit_function+0x0/0x60
 [<c013a6e8>] find_get_page+0x48/0x60
 [<c013ae7b>] do_generic_mapping_read+0x41b/0x520
 [<c013b282>] __generic_file_aio_read+0x212/0x250
 [<c013af80>] file_read_actor+0x0/0xf0
 [<c013b31b>] generic_file_aio_read+0x5b/0x80
 [<f8c9c551>] nfs_file_read+0x81/0xb0 [nfs]
 [<c015aab7>] do_sync_read+0xb7/0xf0
 [<c01381b2>] audit_filter_syscall+0x72/0xe0
 [<c012f940>] autoremove_wake_function+0x0/0x60
 [<c015ab9e>] vfs_read+0xae/0x130
 [<c015ae91>] sys_read+0x51/0x80
 [<c0103cbf>] syscall_call+0x7/0xb

Many thanks for any assitance in resolving this,
- Richard

-- 
Richard Perrin
richard.perrin@solacesystems.com
rcp@sentientmeat.ca

--kXdP64Ggrk/fb43R
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=script

#!/bin/bash
man bash > BREAKME.txt
cat > nfstst.c <<EOF
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main(int argc, char *argv[])
{
        int i;
        for (i = 0;;i++) {
                char buf[4096];
                int fd = open(argv[1], O_RDONLY);
                read(fd, buf, sizeof(buf));
                close(fd);
                if (!(i %= 2000)) {
                        putchar('.');
                        fflush(stdout);
                }       
        }
        return 0;
}
EOF

gcc -o nfstst nfstst.c
echo "Running read loop, now go open BREAKME.txt on a Windows box through Samba"
echo "'ps -lF -C nfstst' for process info"
echo "'killall tcpdump' after it hangs"

tcpdump -s300 -tttt -N -vv udp port 2049 -w /tmp/nfs_traffic -C 1000 &
./nfstst BREAKME.txt 

--kXdP64Ggrk/fb43R--


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
