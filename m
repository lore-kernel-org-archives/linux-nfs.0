Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from netnation.com ([204.174.223.2]:33921 "EHLO peace.netnation.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751075Ab1ADXtj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 18:49:39 -0500
Received: from sim by peace.netnation.com with local (Exim 4.69)
	(envelope-from <sim@netnation.com>)
	id 1PaGdG-0005QY-9f
	for linux-nfs@vger.kernel.org; Tue, 04 Jan 2011 15:49:38 -0800
Date: Tue, 4 Jan 2011 15:49:38 -0800
From: Simon Kirby <sim@hostway.ca>
To: linux-nfs@vger.kernel.org
Subject: flock gives EIO on NFSv4, works on NFSv3
Message-ID: <20110104234938.GM27727@hostway.ca>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

In testing NFSv4, I found that this lock test script fails with EIO:

#!/usr/bin/perl

$|=1;
use Fcntl qw(:DEFAULT :flock);
open(IN, "< locktest.pl") or die "open: $!";
print "Locking...\n";
flock(IN,LOCK_EX) or die "flock $filename: $!";
print "Locked.\n";
sleep(4);
print "Unlocking...\n";
close(IN);
exit(0);

This just locks itself (assuming it's called locktest.pl).  This works
fine over NFSv3, but with NFSv4, I'm seeing:

flock(3, LOCK_EX)                       = -1 EIO (Input/output error)

tcpdump and NFS debugging shows status "10038", which as far as I can
tell is "NFS4ERR_OPENMODE".

Output from the server with nfsd_debug set to 255 is below.
Server and client are 2.6.38-rc8-git5.

Simon-

[ 9018.993475] nfsd_dispatch: vers 4 proc 1
[ 9018.993507] nfsv4 compound op #1/1: 35 (OP_SETCLIENTID)
[ 9018.993535] NFSD: nfs4_make_rec_clidname for 10.10.52.161/10.10.52.160 tcp UNIX 0
[ 9018.993595] renewing client (clientid 4d238df3/0000000a)
[ 9018.993624] nfsv4 compound op ffff8802264a5078 opcnt 1 #1: 35: status 0
[ 9018.993653] nfsv4 compound returned 0
[ 9018.994389] nfsd_dispatch: vers 4 proc 1
[ 9018.994416] nfsv4 compound op #1/3: 36 (OP_SETCLIENTID_CONFIRM)
[ 9018.994446] NFSD: move_to_confirm nfs4_client ffff8801f28f5c00
[ 9018.994473] renewing client (clientid 4d238df3/0000000a)
[ 9018.994504] nfsv4 compound op ffff8802264a5078 opcnt 3 #1: 36: status 0
[ 9018.994533] nfsv4 compound op #2/3: 24 (OP_PUTROOTFH)
[ 9018.994565] nfsd: fh_compose(exp 08:01/2 ///, ino=2)
[ 9018.994593] nfsv4 compound op ffff8802264a5078 opcnt 3 #2: 24: status 0
[ 9018.994622] nfsv4 compound op #3/3: 9 (OP_GETATTR)
[ 9018.994649] nfsd: fh_verify(8: 00010001 00000000 00000000 00000000 00000000 00000000)
[ 9018.994724] nfsv4 compound op ffff8802264a5078 opcnt 3 #3: 9: status 0
[ 9018.994753] nfsv4 compound returned 0
[ 9018.995564] nfsd_dispatch: vers 4 proc 1
[ 9018.995591] nfsv4 compound op #1/7: 22 (OP_PUTFH)
[ 9018.995617] nfsd: fh_verify(8: 00010001 00000001 00000000 00000000 00000000 00000000)
[ 9018.995667] nfsv4 compound op ffff8802264a5078 opcnt 7 #1: 22: status 0
[ 9018.995696] nfsv4 compound op #2/7: 32 (OP_SAVEFH)
[ 9018.995723] nfsv4 compound op ffff8802264a5078 opcnt 7 #2: 32: status 0
[ 9018.995752] nfsv4 compound op #3/7: 18 (OP_OPEN)
[ 9018.995778] NFSD: nfsd4_open filename lockme.file op_stateowner           (null)
[ 9018.995824] renewing client (clientid 4d238df3/0000000a)
[ 9018.995853] nfsd: nfsd_lookup(fh 8: 00010001 00000001 00000000 00000000 00000000 00000000, lockme.file)
[ 9018.995902] nfsd: fh_verify(8: 00010001 00000001 00000000 00000000 00000000 00000000)
[ 9018.995951] nfsd: fh_compose(exp 08:04/128 //lockme.file, ino=3571468)
[ 9018.995983] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9018.996038] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9018.996088] nfsd4_process_open2: stateid=(4d238df3/00015581/0001274a/00000000)
[ 9018.996134] nfsv4 compound op ffff8802264a5078 opcnt 7 #3: 18: status 0
[ 9018.996164] nfsv4 compound op #4/7: 10 (OP_GETFH)
[ 9018.996191] nfsv4 compound op ffff8802264a5078 opcnt 7 #4: 10: status 0
[ 9018.996220] nfsv4 compound op #5/7: 9 (OP_GETATTR)
[ 9018.996247] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9018.996300] nfsv4 compound op ffff8802264a5078 opcnt 7 #5: 9: status 0
[ 9018.996329] nfsv4 compound op #6/7: 31 (OP_RESTOREFH)
[ 9018.996356] nfsv4 compound op ffff8802264a5078 opcnt 7 #6: 31: status 0
[ 9018.996385] nfsv4 compound op #7/7: 9 (OP_GETATTR)
[ 9018.996411] nfsd: fh_verify(8: 00010001 00000001 00000000 00000000 00000000 00000000)
[ 9018.996459] nfsv4 compound op ffff8802264a5078 opcnt 7 #7: 9: status 0
[ 9018.996488] nfsv4 compound returned 0
[ 9018.997318] nfsd_dispatch: vers 4 proc 1
[ 9018.997343] nfsv4 compound op #1/2: 22 (OP_PUTFH)
[ 9018.997370] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9018.997424] nfsv4 compound op ffff8802264a5078 opcnt 2 #1: 22: status 0
[ 9018.997452] nfsv4 compound op #2/2: 20 (OP_OPEN_CONFIRM)
[ 9018.997479] NFSD: nfsd4_open_confirm on file lockme.file
[ 9018.997507] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9018.997554] NFSD: nfs4_preprocess_seqid_op: seqid=1 stateid = (4d238df3/00015581/0001274a/00000000)
[ 9018.997601] NFSD: find_stateid flags 0x6
[ 9018.997626] renewing client (clientid 4d238df3/0000000a)
[ 9018.997653] NFSD: nfsd4_open_confirm: success, seqid=1 stateid=(4d238df3/00015581/0001274a/00000001)
[ 9018.997700] NFSD: nfsd4_create_clid_dir for "2a9477472b93e2ed771e3f5269ce84a5"
[ 9018.998498] NFSD: nfsd4_create_clid_dir returns 0
[ 9018.998526] nfsv4 compound op ffff8802264a5078 opcnt 2 #2: 20: status 0
[ 9018.998555] nfsv4 compound returned 0
[ 9019.001009] nfsd_dispatch: vers 4 proc 1
[ 9019.001034] nfsv4 compound op #1/2: 22 (OP_PUTFH)
[ 9019.001061] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9019.001111] nfsv4 compound op ffff8802264a5078 opcnt 2 #1: 22: status 0
[ 9019.001140] nfsv4 compound op #2/2: 12 (OP_LOCK)
[ 9019.001166] NFSD: nfsd4_lock: start=0 length=-1
[ 9019.001192] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9019.001239] NFSD: nfs4_preprocess_seqid_op: seqid=2 stateid = (4d238df3/00015581/0001274a/00000001)
[ 9019.001286] NFSD: find_stateid flags 0x4
[ 9019.001311] nfsv4 compound op ffff8802264a5078 opcnt 2 #2: 12: status 10038
[ 9019.001341] nfsv4 compound returned 10038
[ 9019.002179] nfsd_dispatch: vers 4 proc 1
[ 9019.002205] nfsv4 compound op #1/3: 22 (OP_PUTFH)
[ 9019.002231] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9019.002280] nfsv4 compound op ffff8802264a5078 opcnt 3 #1: 22: status 0
[ 9019.002309] nfsv4 compound op #2/3: 4 (OP_CLOSE)
[ 9019.002334] NFSD: nfsd4_close on file lockme.file
[ 9019.002360] NFSD: nfs4_preprocess_seqid_op: seqid=3 stateid = (4d238df3/00015581/0001274a/00000001)
[ 9019.002408] NFSD: find_stateid flags 0x44
[ 9019.002432] renewing client (clientid 4d238df3/0000000a)
[ 9019.002461] NFSD: move_to_close_lru nfs4_stateowner ffff8800c23b06a0
[ 9019.002490] nfsv4 compound op ffff8802264a5078 opcnt 3 #2: 4: status 0
[ 9019.002519] nfsv4 compound op #3/3: 9 (OP_GETATTR)
[ 9019.002546] nfsd: fh_verify(20: 81010001 00000001 00367f0c 00000000 cfe46e7a 00000000)
[ 9019.002593] nfsv4 compound op ffff8802264a5078 opcnt 3 #3: 9: status 0
[ 9019.002622] nfsv4 compound returned 0
