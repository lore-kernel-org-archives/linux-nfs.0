Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:34699 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752782AbcI1MAD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Sep 2016 08:00:03 -0400
Received: by mail-lf0-f50.google.com with SMTP id y6so48665422lff.1
        for <linux-nfs@vger.kernel.org>; Wed, 28 Sep 2016 05:00:02 -0700 (PDT)
MIME-Version: 1.0
From: Lucas Hadjilucas <scrabble80@gmail.com>
Date: Wed, 28 Sep 2016 12:59:40 +0100
Message-ID: <CAEjt2VtPjbsUQdqyZ=4akuLiAvXJ6es5nbsxMo5KdnUSGNujnA@mail.gmail.com>
Subject: [Troubleshooting]: nfs4 share randomly freezes when editing a file
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I have a problem with one of my nfs clients that I cannot seem to be able
to resolve. For some reason, if the client opens a file, for example in
libre office, a while after he starts editing it and mostly when he tries
to save it, libre office freezes and then the whole share becomes
unreachable on the client machine. I cannot access the mount on the client
at all until a reboot.

I have 3 other clients connecting to this nfs4 server and they are running
trouble free.

I debugged the nfs service on both client and server using

rpcdebug -m nfsd -s proc (server)
rpcdebug -m nfs -s proc (client)

and the only thing I notice when I open the file on the client is a a
series of  NFS4ERR_EXPIRED, (I assume that is what status: 10011 stands
for) errors although I am not sure why this is happening.

I tried to switch the ethernet cables on the client to see if that was the
issue but it did not help. Any ideas what might be causing this ?

I hope this the right place to post such question.

Thank you for your help,
Lucas


Server Side (192.168.110.33)
======================

[1059172.447223] process_renew(57da879b/00003cce): starting
[1059172.447225] nfsv4 compound op ffff8803ef9d9080 opcnt 1 #1: 30: status
10011
[1059172.447226] nfsv4 compound returned 10011
[1059174.280371] NFSD: laundromat service - starting
[1059174.280375] NFSD: laundromat_main - sleeping for 60 seconds
[1059177.450478] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059177.450485] process_renew(57da879b/00003cce): starting
[1059177.450491] nfsv4 compound op ffff8803ef9d9080 opcnt 1 #1: 30: status
10011
[1059177.450494] nfsv4 compound returned 10011
[1059182.453596] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059182.453600] process_renew(57da879b/00003cce): starting
[1059182.453603] nfsv4 compound op ffff8803ef9d9080 opcnt 1 #1: 30: status
10011
[1059182.453604] nfsv4 compound returned 10011
[1059187.456780] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059187.456784] process_renew(57da879b/00003cce): starting
[1059187.456786] nfsv4 compound op ffff8803ef9d9080 opcnt 1 #1: 30: status
10011
[1059187.456788] nfsv4 compound returned 10011
[1059192.460001] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059192.460004] process_renew(57da879b/00003cce): starting
[1059192.460006] nfsv4 compound op ffff8803ef9d9080 opcnt 1 #1: 30: status
10011
[1059192.460006] nfsv4 compound returned 10011
[1059197.463213] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059197.463218] process_renew(57da879b/00003cce): starting
[1059197.463221] nfsv4 compound op ffff8803ef9d9080 opcnt 1 #1: 30: status
10011
[1059197.463222] nfsv4 compound returned 10011


[1059392.657664] renewing client (clientid 57da879b/00003ce2)
[1059392.657677] nfsv4 compound op ffff8803f5b3b080 opcnt 1 #1: 36: status 0
[1059392.657678] nfsv4 compound returned 0
[1059392.657737] NFSD: warning: no callback path to client Linux NFSv4.0
0.0.0.0/192.168.110.33 tcp: error -111
[1059397.290936] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059397.290946] process_renew(57da879b/00003ce1): starting
[1059397.290953] nfsv4 compound op ffff8803f5b3b080 opcnt 1 #1: 30: status
10011
[1059397.290956] nfsv4 compound returned 10011
[1059397.291475] nfsv4 compound op #1/1: 30 (OP_RENEW)
[1059397.291483] process_renew(57da879b/00003ce1): starting
[1059397.291489] nfsv4 compound op ffff8803f5b3b080 opcnt 1 #1: 30: status
10011
[1059397.291492] nfsv4 compound returned 10011


Client Side
===========

[  608.016760] NFS call  lookup atestfile.txt
[  608.017128] NFS reply lookup: 0
[  608.017646] _nfs4_do_setlk: begin!
[  608.017651] nfs4_lock_prepare: begin!
[  608.018009] nfs4_lock_done: begin!
[  608.018012] nfs4_lock_done: done, ret = 0!
[  608.018022] nfs4_lock_release: begin!
[  608.018024] nfs4_lock_release: done!
[  608.018025] _nfs4_do_setlk: done, ret = 0!
[  608.019565] nfs4_close_prepare: begin!
[  608.019567] nfs4_close_prepare: done!
[  608.020161] nfs4_close_done: begin!
[  608.020164] nfs4_close_done: done, ret = 0!
[  608.020742] _nfs4_do_setlk: begin!
[  608.020747] nfs4_lock_prepare: begin!
[  608.021113] nfs4_lock_done: begin!
[  608.021119] nfs4_lock_done: done, ret = 0!
[  608.021199] nfs4_lock_release: begin!
[  608.021202] nfs4_lock_release: done!
[  608.021203] _nfs4_do_setlk: done, ret = 0!
[  608.021765] nfs4_close_prepare: begin!
[  608.021766] nfs4_close_prepare: done!
[  608.022345] nfs4_close_done: begin!
[  608.022347] nfs4_close_done: done, ret = 0!
[  608.023636] _nfs4_do_setlk: begin!
[  608.023641] nfs4_lock_prepare: begin!
[  608.024026] nfs4_lock_done: begin!
[  608.024036] nfs4_lock_done: done, ret = 0!
[  608.024115] nfs4_lock_release: begin!
[  608.024118] nfs4_lock_release: done!
[  608.024119] _nfs4_do_setlk: done, ret = 0!
[  609.003947] nfs4_close_prepare: begin!
[  609.004427] nfs4_close_prepare: begin!
[  609.004435] nfs4_close_prepare: done!
[  609.004869] nfs4_close_done: begin!
[  609.004879] nfs4_close_done: done, ret = 0!
[  609.005159] --> nfs4_read_done
