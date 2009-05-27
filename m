From: "Smirnov, Alexander" <AlSmirnov-WEWivvub1mjQT0dZR+AlfA@public.gmane.org>
Subject: NFSD for 2.6.30.rc7 problem
Date: Wed, 27 May 2009 14:32:47 +0400
Message-ID: <1CB6CF624D80D146921DF8431FF3D134A6B1ACEE48@LEMUR.luxoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sphinx.luxoft.com ([213.208.171.129]:1468 "EHLO
	sphinx.luxoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbZE0LKD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 May 2009 07:10:03 -0400
Received: from MSK-EDGE-01.luxoft.com by sphinx.luxoft.com
	(MDaemon PRO v9.0.4)
	with ESMTP id md50012441209.msg
	for <linux-nfs@vger.kernel.org>; Wed, 27 May 2009 14:34:48 +0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello everybody,

During test of NFS software I've found the problem in Linux kernel (nfsd)

On the NFS4_WRITE request (data len=44), NFS server is responding with NFS4_OK (bytes written count = 0) that follows to
cycliing in write request on client side.

REQUEST DUMP:

0000  00 00 00 01 00 06 00 09  6b 1a ed 41 00 00 08 00   ........ k..A....
0010  45 00 01 24 00 ae 00 00  40 06 7b da 09 0b 75 66   E..$.... @.{...uf
0020  09 0b 75 d0 1e 2c 08 01  ec 30 eb 6d 2e 0e 1d f8   ..u..,.. .0.m....
0030  80 18 7f dd 17 96 00 00  01 01 08 0a e4 d5 5a 09   ........ ......Z.
0040  02 e5 a3 f9 80 00 00 ec  39 35 0c f8 00 00 00 00   ........ 95......
0050  00 00 00 02 00 01 86 a3  00 00 00 04 00 00 00 01   ........ ........
0060  00 00 00 06 00 00 00 18  00 00 00 01 00 00 00 00   ........ ........
0070  00 00 00 79 00 00 00 01  00 00 00 04 00 00 00 16   ...y.... ........
0080  00 00 00 06 00 00 00 25  60 23 06 09 2a 86 48 86   .......% `#..*.H.
0090  f7 12 01 02 02 01 01 00  00 ff ff ff ff a3 ef 9f   ........ ........
00a0  60 d6 0f 43 48 bd 3a d4  0b 7f d1 13 85 00 00 00   `..CH.:. ........
00b0  00 00 00 00 00 00 00 00  00 00 00 03 00 00 00 16   ........ ........
00c0  00 00 00 10 01 00 01 01  00 00 00 00 00 0a 78 ee   ........ ......x.
00d0  81 d9 43 8a 00 00 00 26  00 00 00 00 4a 13 df 23   ..C....& ....J..#
00e0  00 00 00 13 00 00 01 db  00 00 00 00 00 00 00 00   ........ ........
00f0  00 00 00 01 00 00 00 2c  e3 c8 c9 e2 40 c9 e2 40   ......., ....@..@
0100  c1 40 e3 c5 e2 e3 40 c2  e4 c6 c6 c5 d9 4b e3 c8   .@....@. .....K..
0110  c9 e2 40 c9 e2 40 c1 40  e3 c5 e2 e3 40 c2 e4 c6   ..@..@.@ ....@...
0120  c6 c5 d9 4b 00 00 00 09  00 00 00 02 00 00 00 18   ...K.... ........
0130  00 30 a0 3a                                        .0.:             


ANSWER DUMP:

0000  00 04 00 01 00 06 62 a2  90 00 80 04 00 00 08 00   ......b. ........
0010  45 00 01 48 34 f2 40 00  40 06 07 72 09 0b 75 d0   E..H4.@. @..r..u.
0020  09 0b 75 66 08 01 1e 2c  2e 0e 1d f8 ec 30 ec 5d   ..uf..., .....0.]
0030  80 18 04 c8 00 00 00 00  01 01 08 0a 02 e5 a3 fe   ........ ........
0040  e4 d5 5a 09 80 00 01 10  39 35 0c f8 00 00 00 01   ..Z..... 95......
0050  00 00 00 00 00 00 00 06  00 00 00 25 60 23 06 09   ........ ...%`#..
0060  2a 86 48 86 f7 12 01 02  02 01 01 00 00 ff ff ff   *.H..... ........
0070  ff 3f 01 f5 2c f4 b1 ad  03 29 4f ef 8b f8 1f ea   .?..,... .)O.....
0080  d8 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ........ ........
0090  00 00 00 03 00 00 00 16  00 00 00 00 00 00 00 26   ........ .......&
00a0  00 00 00 00 00 00 00 00  00 00 00 01 4a 13 df 23   ........ ....J..#
00b0  00 0b 33 42 00 00 00 09  00 00 00 00 00 00 00 02   ..3B.... ........
00c0  00 00 00 18 00 30 a0 3a  00 00 00 8c 4a 16 d7 b0   .....0.: ....J...
00d0  00 00 00 00 00 00 00 00  00 00 00 2c 00 00 01 b6   ........ ...,....
00e0  00 00 00 01 00 00 00 1d  75 73 65 72 31 31 40 73   ........ user11@s
00f0  74 6f 72 61 67 65 2e 74  75 63 73 6f 6e 2e 69 62   torage.t ucson.ib
0100  6d 2e 63 6f 6d 00 00 00  00 00 00 1f 74 73 6f 75   m.com... ....tsou
0110  73 65 72 31 40 73 74 6f  72 61 67 65 2e 74 75 63   ser1@sto rage.tuc
0120  73 6f 6e 2e 69 62 6d 2e  63 6f 6d 00 00 00 00 00   son.ibm. com.....
0130  00 00 10 00 00 00 00 00  00 00 00 01 00 00 00 00   ........ ........
0140  00 00 00 00 4a 16 d7 b0  00 00 00 00 00 00 00 00   ....J... ........
0150  4a 16 d7 b0 00 00 00 00                            J.......         


I can suppose that problem is located in:

linux-2.6.30-rc7\fs\nfsd\vfs.c (nfsd_vfs_write):

....

	host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);			In the stable release (2.6.29) host_err
												                                         means OK == 0 or error code if host_err < 0

												                                          Current implementation (RC7) host_err
												                                          is NUMBER OF BYTES WRITTEN (>=0) or error code (<0)


....
			if (inode->i_state & I_DIRTY) {
				dprintk("nfsd: write sync %d\n", task_pid_nr(current));
				host_err=nfsd_sync(file);					                         Here host_err seems to have old meaning
												                                         so host_err again just 0 for OK and <0 for error

....
	dprintk("nfsd: write complete host_err=%d\n", host_err);
	if (host_err >= 0) {
		err = 0;
		*cnt = host_err;								                              Here is place to fill 'written bytes' field for
 												                                         RPC answer. It is filled sometimes to 'written
												                                         bytes' count and sometimes to zero.
	} else
		err = nfserrno(host_err);
out:
	return err;
}


Is it's the case I can propose to move the assignment "*cnt = host_err;" upper:

host_err = vfs_writev(file, (struct iovec __user *)vec, vlen, &offset);
if( host_err >= 0 )
  *cnt = host_err;


with best regards,

Alexander Smirnov,

Luxoft,
IBM zOS NFS Development team

