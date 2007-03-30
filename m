From: Thorsten Kranzkowski <dl8bcu@dl8bcu.de>
Subject: Re: Odd log message associated with NFS
Date: Fri, 30 Mar 2007 20:51:45 +0000
Message-ID: <20070330205145.GA1349@Marvin.DL8BCU.ampr.org>
References: <2fe399760703271140l703c2791oa84e9e1832487dcb@mail.gmail.com> <20070327193909.GA585@ds20.borg.net> <20070328165925.GB21221@fieldses.org> <20070328190536.GB585@ds20.borg.net> <20070328232348.GJ21221@fieldses.org>
Reply-To: dl8bcu@dl8bcu.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754064AbXC3VaN@vger.kernel.org>
In-Reply-To: <20070328232348.GJ21221@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, Mar 28, 2007 at 07:23:48PM -0400, J. Bruce Fields wrote:
> On Wed, Mar 28, 2007 at 07:05:36PM +0000, Thorsten Kranzkowski wrote:
> > I'll let a tcpdump run this evening and see if I can correlate the message
> > with anything. 
> > 
> > If you have a printk or other patch for me to try, just let me know.
> 
> Well, just for fun, you could try something like this--should dump some
> data the first time it hits the "bad direction" error.

Time to check my iptables setup it seems ....
Thanks for the lesson ;-)

The source address obviously isn't from my local net, and the clear text speaks
for itself. looks like an attack to some Windows service with phishing content.
luckily this machine is neither windows based nor intel compatible :)

bye,
Thorsten

Mar 30 18:29:54 Marvin kernel: svc: bad direction 268435456, dropping request 
Mar 30 18:29:54 Marvin kernel: dumping request; rq_addr = 61.180.228.240, port=59653, rq_deferred = 0000000000000000, rq_arg: 
Mar 30 18:29:54 Marvin kernel: buf->head[0].iov_base = fffffc0008ea8850, buf->head[0].iov_len = 887 
Mar 30 18:29:54 Marvin kernel: buf->tail[0].iov_base = 0000000000000000, buf->tail[0].iov_len = 0 
Mar 30 18:29:54 Marvin kernel: pages = fffffc000b1bd168, page_base = 0, page_len = 0 
Mar 30 18:29:54 Marvin kernel: buflen = 0, len = 899 
Mar 30 18:29:54 Marvin kernel: head data (from fffffc0008ea8844): 
Mar 30 18:29:54 Marvin kernel: RPC: print_hexl: length 899 
Mar 30 18:29:54 Marvin kernel:   0000: 0400 2800 1000 0000 0000 0000 0000 0000  ..(............. 
Mar 30 18:29:54 Marvin kernel:   0010: 0000 0000 0000 0000 f891 7b5a 00ff d011  ..........{Z.... 
Mar 30 18:29:54 Marvin kernel:   0020: a9b2 00c0 4fb6 e6fc 0000 0000 0000 0000  ....O........... 
Mar 30 18:29:54 Marvin kernel:   0030: 0000 0000 0000 0000 0000 0000 0100 0000  ................ 
Mar 30 18:29:54 Marvin kernel:   0040: 0000 0000 0000 ffff ffff 3303 0000 0000  ..........3..... 
Mar 30 18:29:54 Marvin kernel:   0050: 1000 0000 0000 0000 1000 0000 5359 5354  ............SYST 
Mar 30 18:29:54 Marvin kernel:   0060: 454d 0000 0000 0000 0000 0000 1000 0000  EM.............. 
Mar 30 18:29:54 Marvin kernel:   0070: 0000 0000 1000 0000 414c 4552 5400 0000  ........ALERT... 
Mar 30 18:29:54 Marvin kernel:   0080: 0000 0000 0000 0000 ef02 0000 0000 0000  ................ 
Mar 30 18:29:54 Marvin kernel:   0090: ef02 0000 596f 7572 2073 7973 7465 6d20  ....Your system  
Mar 30 18:29:54 Marvin kernel:   00a0: 7265 6769 7374 7279 2069 7320 636f 7272  registry is corr 
Mar 30 18:29:54 Marvin kernel:   00b0: 7570 7465 6420 616e 6420 6e65 6564 7320  upted and needs  
Mar 30 18:29:54 Marvin kernel:   00c0: 746f 2062 6520 636c 6561 6e65 6420 696d  to be cleaned im 
Mar 30 18:29:54 Marvin kernel:   00d0: 6d65 6469 6174 656c 792e 0a0a 0a43 6f6d  mediately....Com 
Mar 30 18:29:54 Marvin kernel:   00e0: 7072 6f6d 6973 6564 2072 6567 6973 7472  promised registr 
Mar 30 18:29:54 Marvin kernel:   00f0: 7920 6669 6c65 7320 6361 6e20 6c65 6164  y files can lead 
Mar 30 18:29:54 Marvin kernel:   0100: 2074 6f20 7468 6520 666f 6c6c 6f77 696e   to the followin 
Mar 30 18:29:54 Marvin kernel:   0110: 673a 0a0a 312e 2043 6f6d 706c 6574 6520  g:..1. Complete  
Mar 30 18:29:54 Marvin kernel:   0120: 6163 6365 7373 206f 6620 796f 7572 2050  access of your P 
Mar 30 18:29:54 Marvin kernel:   0130: 4320 6279 2068 6163 6b65 7273 0a32 2e20  C by hackers.2.  
Mar 30 18:29:54 Marvin kernel:   0140: 536c 6f77 2073 7065 6564 7320 7265 7375  Slow speeds resu 
Mar 30 18:29:54 Marvin kernel:   0150: 6c74 696e 6720 696e 2073 6c6f 7720 646f  lting in slow do 
Mar 30 18:29:54 Marvin kernel:   0160: 776e 6c6f 6164 7320 6f66 2069 6e74 6572  wnloads of inter 
Mar 30 18:29:54 Marvin kernel:   0170: 6e65 7420 6669 6c65 730a 332e 2054 6865  net files.3. The 
Mar 30 18:29:54 Marvin kernel:   0180: 2063 6f6d 7072 6f6d 6973 6520 6f66 2070   compromise of p 
Mar 30 18:29:54 Marvin kernel:   0190: 6572 736f 6e61 6c20 696e 666f 726d 6174  ersonal informat 
Mar 30 18:29:54 Marvin kernel:   01a0: 696f 6e20 7374 6f72 6564 206f 6e20 796f  ion stored on yo 
Mar 30 18:29:54 Marvin kernel:   01b0: 7572 2063 6f6d 7075 7465 720a 342e 2043  ur computer.4. C 
Mar 30 18:29:54 Marvin kernel:   01c0: 6f6d 706c 6574 6520 7379 7374 656d 2066  omplete system f 
Mar 30 18:29:54 Marvin kernel:   01d0: 6169 6c75 7265 2072 6573 756c 7469 6e67  ailure resulting 
Mar 30 18:29:54 Marvin kernel:   01e0: 2069 6e20 7468 6520 6e65 6564 2066 6f72   in the need for 
Mar 30 18:29:54 Marvin kernel:   01f0: 2061 2063 6f6d 706c 6574 6520 7265 696e   a complete rein 
Mar 30 18:29:54 Marvin kernel:   0200: 7374 616c 6c20 6f66 2079 6f75 7220 6861  stall of your ha 
Mar 30 18:29:54 Marvin kernel:   0210: 7264 2064 7269 7665 2e0a 0a54 6f20 6669  rd drive...To fi 
Mar 30 18:29:54 Marvin kernel:   0220: 7820 7468 6973 2070 726f 626c 656d 3a0a  x this problem:. 
Mar 30 18:29:54 Marvin kernel:   0230: 0a31 2e20 4f70 656e 2049 6e74 6572 6e65  .1. Open Interne 
Mar 30 18:29:54 Marvin kernel:   0240: 7420 4578 706c 6f72 6572 0a32 2e20 496e  t Explorer.2. In 
Mar 30 18:29:54 Marvin kernel:   0250: 2074 6865 2055 524c 2046 6965 6c64 2074   the URL Field t 
Mar 30 18:29:54 Marvin kernel:   0260: 7970 6520 2d20 2052 6567 5570 6461 7469  ype -  RegUpdati 
Mar 30 18:29:54 Marvin kernel:   0270: 6e67 2e63 6f6d 0a33 2e20 4e6f 7465 2074  ng.com.3. Note t 
Mar 30 18:29:54 Marvin kernel:   0280: 6861 7420 616c 6c20 7665 7273 696f 6e73  hat all versions 
Mar 30 18:29:54 Marvin kernel:   0290: 206f 6620 7769 6e64 6f77 7320 6172 6520   of windows are  
Mar 30 18:29:54 Marvin kernel:   02a0: 7375 7070 6f72 2074 6564 2e0a 342e 204f  suppor ted..4. O 
Mar 30 18:29:54 Marvin kernel:   02b0: 6e63 6520 796f 7520 6c6f 6164 2074 6865  nce you load the 
Mar 30 18:29:54 Marvin kernel:   02c0: 2070 726f 6772 616d 2c20 636c 6f73 6520   program, close  
Mar 30 18:29:54 Marvin kernel:   02d0: 7468 6973 2077 696e 646f 772e 0a0a 506c  this window...Pl 
Mar 30 18:29:54 Marvin kernel:   02e0: 6561 7365 206e 6f74 6520 7468 6174 206f  ease note that o 
Mar 30 18:29:54 Marvin kernel:   02f0: 6e63 6520 796f 7520 7669 7369 7420 5265  nce you visit Re 
Mar 30 18:29:54 Marvin kernel:   0300: 6755 7064 6174 696e 672e 636f 6d20 616e  gUpdating.com an 
Mar 30 18:29:54 Marvin kernel:   0310: 6420 696e 7374 616c 6c20 7468 6520 0a63  d install the .c 
Mar 30 18:29:54 Marvin kernel:   0320: 6c65 616e 6572 2070 726f 6772 616d 2079  leaner program y 
Mar 30 18:29:54 Marvin kernel:   0330: 6f75 2077 696c 6c20 6e6f 7420 7265 6365  ou will not rece 
Mar 30 18:29:54 Marvin kernel:   0340: 6976 6520 616e 7920 6d6f 7265 2072 656d  ive any more rem 
Mar 30 18:29:54 Marvin kernel:   0350: 696e 6465 7273 206f 7220 706f 702d 7570  inders or pop-up 
Mar 30 18:29:54 Marvin kernel:   0360: 7320 6c69 6b65 2074 6869 7320 6f6e 652e  s like this one. 
Mar 30 18:29:54 Marvin kernel:   0370: 0a0a 5265 6755 7064 6174 696e 672e 636f  ..RegUpdating.co 
Mar 30 18:29:54 Marvin kernel:   0380: 6d0a 00                                  m.. 


> 
> --b.
> 

-- 
| Thorsten Kranzkowski        Internet: dl8bcu@dl8bcu.de                      |
| Mobile: ++49 170 1876134       Snail: Kiebitzstr. 14, 49324 Melle, Germany  |
| Ampr: dl8bcu@db0lj.#rpl.deu.eu, dl8bcu@marvin.dl8bcu.ampr.org [44.130.8.19] |
