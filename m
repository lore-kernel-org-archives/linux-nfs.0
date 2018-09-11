Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf1-f172.google.com ([209.85.210.172]:43246 "EHLO
        mail-pf1-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726563AbeIKR2v (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Sep 2018 13:28:51 -0400
Received: by mail-pf1-f172.google.com with SMTP id j26-v6so12153943pfi.10
        for <linux-nfs@vger.kernel.org>; Tue, 11 Sep 2018 05:29:44 -0700 (PDT)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: lseek gets bad offset from nfs client with ganesha/gluster which
 supports SEEK
To: devel@lists.nfs-ganesha.org, linux-nfs@vger.kernel.org
Cc: kinglongmee@gmail.com
Message-ID: <182fecd3-66c3-0cbd-fbc0-cf1a88b7f165@gmail.com>
Date: Tue, 11 Sep 2018 20:29:34 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The latest ganesha/gluster supports seek according to,

https://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-41#section-15.11

   From the given sa_offset, find the next data_content4 of type sa_what
   in the file.  If the server can not find a corresponding sa_what,
   then the status will still be NFS4_OK, but sr_eof would be TRUE.  If
   the server can find the sa_what, then the sr_offset is the start of
   that content.  If the sa_offset is beyond the end of the file, then
   SEEK MUST return NFS4ERR_NXIO.

For a file's filemap as,

Part    1: HOLE 0x0000000000000000 ---> 0x0000000000600000
Part    2: DATA 0x0000000000600000 ---> 0x0000000000700000
Part    3: HOLE 0x0000000000700000 ---> 0x0000000001000000

SEEK(0x700000, SEEK_DATA) gets result (sr_eof:1, sr_offset:0x70000) from ganesha/gluster;
SEEK(0x700000, SEEK_HOLE) gets result (sr_eof:0, sr_offset:0x70000) from ganesha/gluster.

If an application depends the lseek result for data searching, it may enter infinite loop.

        while (1) {
                next_pos = lseek(fd, cur_pos, seek_type);
                if (seek_type == SEEK_DATA) {
                        seek_type = SEEK_HOLE;
                } else {
                        seek_type = SEEK_DATA;
                }

                if (next_pos == -1) {
                        return ;

                cur_pos = next_pos;
        }

The lseek syscall always gets 0x70000 from nfs client for those two cases, 
but, if underlying filesystem is ext4/f2fs, or the nfs server is knfsd,
the lseek(0x700000, SEEK_DATA) gets ENXIO.

I wanna to know,
should I fix the ganesha/gluster as knfsd return ENXIO for the first case?
or should I fix the nfs client to return ENXIO for the first case?

thanks,
Kinglong Mee
