Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50851 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753452Ab0I2PN7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Sep 2010 11:13:59 -0400
Received: by gxk9 with SMTP id 9so307704gxk.19
        for <linux-nfs@vger.kernel.org>; Wed, 29 Sep 2010 08:13:58 -0700 (PDT)
In-Reply-To: <D4AFE98FB48D2F4CBFEACD015C9642DF02662D@sha2122.hamburg.rwedea.de>
References: <D4AFE98FB48D2F4CBFEACD015C9642DF026628@sha2122.hamburg.rwedea.de>
	<AANLkTimHnNCaQrj2T4vuC8m3R_S8oqc9o6zQBW_GOGoo@mail.gmail.com>
	<D4AFE98FB48D2F4CBFEACD015C9642DF02662B@sha2122.hamburg.rwedea.de>
	<AANLkTi=FGmot-QyimqCk6O=zHto2fjxfpv1SAU6YrGhD@mail.gmail.com>
	<D4AFE98FB48D2F4CBFEACD015C9642DF02662D@sha2122.hamburg.rwedea.de>
Date: Wed, 29 Sep 2010 11:13:57 -0400
Message-ID: <AANLkTinfs6rbedqV9_sQrO2L4C=ADV2KoEHCL4yZnawK@mail.gmail.com>
Subject: Re: NFS4 / GSS: Problem with users accessing the mounted directories
 (with root, everything ist okay)
From: Kevin Coffman <kwc@citi.umich.edu>
To: "Beyersdorf, Wolfgang" <Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I think the problem is that that you are using Active Directory and
PAC information is being included in the user's ticket which makes it
larger than what can currently be passed up in the interface to
svcgssd.

See http://www.spinics.net/lists/linux-nfs/msg14777.html

And http://support.microsoft.com/kb/832572 for a work-around.

K.C.

On Wed, Sep 29, 2010 at 10:53 AM, Beyersdorf, Wolfgang
<Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com> wrote:
> Hi Kevin,
>
> The rcp debug had been enabled via: echo "65535" > /proc/sys/sunrpc/rpc_debug
>
> Here is the output:
>
> Sep 29 16:49:16 sha9012 kernel: svc: socket ffff81007cf34080 TCP (listen) state change 10
> Sep 29 16:49:16 sha9012 kernel: svc: socket ffff81007cf34080 served by daemon ffff8100758ec400
> Sep 29 16:49:16 sha9012 kernel: svc: server ffff8100758ec400, socket ffff810075fdea80, inuse=1
> Sep 29 16:49:16 sha9012 kernel: svc: tcp_recv ffff810075fdea80 data 0 conn 1 close 0
> Sep 29 16:49:16 sha9012 kernel: svc: tcp_accept ffff810075fdea80 sock ffff810075ffaac0
> Sep 29 16:49:16 sha9012 kernel: svc: socket ffff81007cf34080 busy, not enqueued
> Sep 29 16:49:16 sha9012 kernel: nfsd: connect from 10.133.224.155:03f3
> Sep 29 16:49:16 sha9012 kernel: svc: svc_setup_socket ffff81007421c080
> Sep 29 16:49:16 sha9012 kernel: setting up TCP socket for reading
> Sep 29 16:49:16 sha9012 kernel: svc: svc_setup_socket created ffff8100768656c0 (inet ffff810074a5b300)
> Sep 29 16:49:16 sha9012 kernel: svc: socket ffff810074a5b300 served by daemon ffff810002a05400
> Sep 29 16:49:16 sha9012 kernel: svc: socket ffff81007cf34080 served by daemon ffff810076315000
> Sep 29 16:49:16 sha9012 kernel: svc: got len=0
> Sep 29 16:49:17 sha9012 kernel: svc: socket ffff81007cf34080 busy, not enqueued
> Sep 29 16:49:17 sha9012 kernel: svc: server ffff8100758ec400 waiting for data (to = 3600000)
> Sep 29 16:49:19 sha9012 kernel: isit queued
> Sep 29 16:49:22 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:22 sha9012 kernel: svc: svc_process dropit
> Sep 29 16:49:22 sha9012 kernel: svc: socket ffff8100768656c0 dropped request
> Sep 29 16:49:23 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:24 sha9012 kernel: svc: server ffff810076315000 waiting for data (to = 3600000)
> Sep 29 16:49:26 sha9012 kernel: svc: server ffff810002a05400, socket ffff8100768656c0, inuse=1
> Sep 29 16:49:26 sha9012 kernel: svc: tcp_recv ffff8100768656c0 data 0 conn 0 close 0
> Sep 29 16:49:28 sha9012 kernel: svc: socket ffff810074a5b300 served by daemon ffff810076315000
> Sep 29 16:49:32 sha9012 kernel: svc: got len=3348
> Sep 29 16:49:32 sha9012 kernel: svc: svc_authenticate (6)
> Sep 29 16:49:35 sha9012 kernel: RPC:      svcauth_gss: argv->iov_len = 3320
> Sep 29 16:49:36 sha9012 kernel: Want update, refage=120, age=3
> Sep 29 16:49:36 sha9012 kernel: svc: server ffff810076315000, socket ffff8100768656c0, inuse=2
> Sep 29 16:49:36 sha9012 kernel: svc: tcp_recv ffff8100768656c0 data 0 conn 0 close 0
> Sep 29 16:49:38 sha9012 kernel: svc: socket ffff8100768656c0 recvfrom(ffff810076865760, 4) = -11
> Sep 29 16:49:38 sha9012 kernel: RPC: TCP recvfrom got EAGAIN
> Sep 29 16:49:39 sha9012 kernel: svc: got len=-11
> Sep 29 16:49:40 sha9012 kernel: svc: server ffff810076315000 waiting for data (to = 3600000)
> Sep 29 16:49:40 sha9012 kernel: revisit queued
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 served by daemon ffff810076315000
> Sep 29 16:49:41 sha9012 kernel: svc: svc_process dropit
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff8100768656c0 dropped request
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:41 sha9012 kernel: svc: server ffff810002a05400 waiting for data (to = 3600000)
> Sep 29 16:49:41 sha9012 kernel: svc: server ffff810076315000, socket ffff8100768656c0, inuse=1
> Sep 29 16:49:41 sha9012 kernel: svc: tcp_recv ffff8100768656c0 data 0 conn 0 close 0
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 served by daemon ffff810002a05400
> Sep 29 16:49:41 sha9012 kernel: svc: got len=3348
> Sep 29 16:49:41 sha9012 kernel: svc: svc_authenticate (6)
> Sep 29 16:49:41 sha9012 kernel: RPC:      svcauth_gss: argv->iov_len = 3320
> Sep 29 16:49:41 sha9012 kernel: Want update, refage=120, age=3
> Sep 29 16:49:41 sha9012 kernel: revisit queued
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:41 sha9012 kernel: svc: svc_process dropit
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff8100768656c0 dropped request
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:41 sha9012 kernel: svc: server ffff810076315000 waiting for data (to = 3600000)
> Sep 29 16:49:41 sha9012 kernel: svc: server ffff810002a05400, socket ffff8100768656c0, inuse=1
> Sep 29 16:49:41 sha9012 kernel: svc: tcp_recv ffff8100768656c0 data 0 conn 0 close 0
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 served by daemon ffff810076315000
> Sep 29 16:49:41 sha9012 kernel: svc: got len=3348
> Sep 29 16:49:41 sha9012 kernel: svc: svc_authenticate (6)
> Sep 29 16:49:41 sha9012 kernel: RPC:      svcauth_gss: argv->iov_len = 3320
> Sep 29 16:49:41 sha9012 kernel: Want update, refage=120, age=3
> Sep 29 16:49:41 sha9012 kernel: revisit queued
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:41 sha9012 kernel: svc: svc_process dropit
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff8100768656c0 dropped request
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:41 sha9012 kernel: svc: server ffff810002a05400 waiting for data (to = 3600000)
> Sep 29 16:49:41 sha9012 kernel: svc: server ffff810076315000, socket ffff8100768656c0, inuse=1
> Sep 29 16:49:41 sha9012 kernel: svc: tcp_recv ffff8100768656c0 data 0 conn 0 close 0
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 served by daemon ffff810002a05400
> Sep 29 16:49:41 sha9012 kernel: svc: got len=3348
> Sep 29 16:49:41 sha9012 kernel: svc: svc_authenticate (6)
> Sep 29 16:49:41 sha9012 kernel: RPC:      svcauth_gss: argv->iov_len = 3320
> Sep 29 16:49:41 sha9012 kernel: Want update, refage=120, age=3
> Sep 29 16:49:41 sha9012 kernel: revisit queued
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
> Sep 29 16:49:41 sha9012 kernel: svc: svc_process dropit
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff8100768656c0 dropped request
> Sep 29 16:49:41 sha9012 kernel: svc: socket ffff810074a5b300 busy, not enqueued
>
> This is repeated many times :-)
>
> Regards,
>  W.B.
>
>
>
> -----Ursprüngliche Nachricht-----
> Von: kwcoffman@gmail.com [mailto:kwcoffman@gmail.com] Im Auftrag von Kevin Coffman
> Gesendet: Mittwoch, 29. September 2010 16:40
> An: Beyersdorf, Wolfgang
> Betreff: Re: NFS4 / GSS: Problem with users accessing the mounted directories (with root, everything ist okay)
>
> Hi Wolfgang,
> This all looks OK.  You could try enabling rpc debugging in the
> server's kernel.  If that doesn't reveal anything,  a packet trace
> between the client and server when the normal user is trying to access
> it might give a clue to what the server doesn't like.
>
> On the client:
>
>  tcpdump -s 0 -w /tmp/trace.pcap -h sha9012.hamburg.rwede
>
> Send the trace.pcap file.
>
> K.C.
>
> On Wed, Sep 29, 2010 at 10:26 AM, Beyersdorf, Wolfgang
> <Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com> wrote:
>> Dear Kevin,
>>
>> Here are the answers:
>>
>> -----------------------------------------------
>> klist -e (as normal user xdiwb)
>>
>> Ticket cache: FILE:/tmp/krb5cc_569926353
>> Default principal: xdiwb@HAMBURG.RWEDEA.DE
>>
>> Valid starting     Expires            Service principal
>> 09/29/10 11:11:52  09/29/10 21:12:09  krbtgt/HAMBURG.RWEDEA.DE@HAMBURG.RWEDEA.DE
>>        renew until 09/30/10 11:11:52, Etype (skey, tkt): ArcFour with HMAC/md5, ArcFour with HMAC/md5
>> 09/29/10 11:12:30  09/29/10 21:12:09  nfs/sha9012.hamburg.rwedea.de@HAMBURG.RWEDEA.DE
>>        renew until 09/30/10 11:11:52, Etype (skey, tkt): DES cbc mode with CRC-32, DES cbc mode with CRC-32
>>
>>
>> Kerberos 4 ticket cache: /tmp/tkt569926353
>> klist: You have no tickets cached
>> -----------------------------------------------
>>
>> -----------------------------------------------
>> Output from svcgssd on the server when root accesses:
>>
>> NFS4 Server
>>
>> As user ROOT
>> ============
>>
>> Sep 29 08:52:55 sha9012 rpc.svcgssd[1667]: writing message: \x \x608204c606092a864886f71201020201006e8204b5308204b1a003020105a10302010ea20703050020000000a38203d1618203cd308203c9a003020105a1131b1148414d425552472e5257454445412e4445a22b3029a003020103a12230201b036e66731b19736861393031322e68616d627572672e7277656465612e6465a382037e3082037aa003020117a103020104a282036c0482036868c94283937af92e3b05ded1d3f4f4025c470512ac1a52fe3f4fdfa55a8f892cdc4a145d7e666ddaed77123cbc60bc20d6523dc8872e68d033f2bc57707171e9a2c22e51eb4520c1d424c90cf1a58752e1aba1f...
>> Sep 29 08:52:55 sha9012 rpc.svcgssd[1667]: finished handling null request
>> Sep 29 08:52:55 sha9012 rpc.svcgssd[1667]: entering poll
>> Sep 29 08:56:07 sha9012 ntpd[1820]: frequency error -512 PPM exceeds tolerance 500 PPM
>> Sep 29 09:03:37 sha9012 ntpd[1820]: frequency error -512 PPM exceeds tolerance 500 PPM
>> Sep 29 09:08:54 sha9012 winbindd[1948]: [2010/09/29 09:08:54.166722,  0] winbindd/winbindd_util.c:325(trustdom_recv)
>> Sep 29 09:08:54 sha9012 winbindd[1948]:   Got invalid trustdom response
>> Sep 29 09:10:58 sha9012 ntpd[1820]: no servers reachable
>> Sep 29 09:38:54 sha9012 winbindd[1948]: [2010/09/29 09:38:54.169369,  0] winbindd/winbindd_util.c:325(trustdom_recv)
>> Sep 29 09:38:54 sha9012 winbindd[1948]:   Got invalid trustdom response
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: leaving poll
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: handling null request
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: readline: read 2458 chars into buffer of size 4096: \x \x608204c606092a864886f71201020201006e8204b5308204b1a003020105a10302010ea20703050020000000a38203d1618203cd308203c9a003020105a1131b1148414d425552472e5257454445412e4445a22b3029a003020103a12230201b036e66731b19736861393031322e68616d627572672e7277656465612e6465a382037e3082037aa003020117a103020104a282036c0482036868c94283937af92e3b05ded1d3f4f4025c470512ac1a52fe3f4fdfa55a8f892cdc4a145d7e666ddaed77123cbc60bc20d6523dc8872e68d033f2bc57707171e9a2c2...
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: in_handle:
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: length 0
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: in_tok:
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]: length 1226
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0000: 6082 04c6 0609 2a86 4886 f712 0102 0201  `.....*.H.......
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0010: 006e 8204 b530 8204 b1a0 0302 0105 a103  .n...0..........
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0020: 0201 0ea2 0703 0500 2000 0000 a382 03d1  ........ .......
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0030: 6182 03cd 3082 03c9 a003 0201 05a1 131b  a...0...........
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0040: 1148 414d 4255 5247 2e52 5745 4445 412e  .HAMBURG.RWEDEA.
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0050: 4445 a22b 3029 a003 0201 03a1 2230 201b  DE.+0)......"0 .
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0060: 036e 6673 1b19 7368 6139 3031 322e 6861  .nfs..sha9012.ha
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0070: 6d62 7572 672e 7277 6564 6561 2e64 65a3  mburg.rwedea.de.
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0080: 8203 7e30 8203 7aa0 0302 0117 a103 0201  ..~0..z.........
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   0090: 04a2 8203 6c04 8203 6868 c942 8393 7af9  ....l...hh.B..z.
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   00a0: 2e3b 05de d1d3 f4f4 025c 4705 12ac 1a52  .;.......\G....R
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   00b0: fe3f 4fdf a55a 8f89 2cdc 4a14 5d7e 666d  .?O..Z..,.J.]~fm
>> Sep 29 09:53:05 sha9012 rpc.svcgssd[1667]:   00c0: daed 7712 3cbc 60bc 20d6 523d c887 2e68  ..w.<.`. .R=...h
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   00d0: d033 f2bc 5770 7171 e9a2 c22e 51eb 4520  .3..Wpqq....Q.E
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   00e0: c1d4 24c9 0cf1 a587 52e1 aba1 fba5 c827  ..$.....R......'
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   00f0: e9e8 f6f1 6b81 851a 902e a003 772a 34b7  ....k.......w*4.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0100: da3e 177e c6f6 334d 9eff 4105 b0e0 5d25  .>.~..3M..A...]%
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0110: 2f0e f600 17b8 5fa7 46b6 42a2 35ee 945d  /....._.F.B.5..]
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0120: 7b39 eeb3 1257 3425 0f5e 298e fee8 5b5f  {9...W4%.^)...[_
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0130: 35a8 c951 14c7 487b c7fb b91e e4dc a11e  5..Q..H{........
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0140: 6571 e088 0032 cc1e 5b7a 56fe 0c18 962d  eq...2..[zV....-
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0150: c248 689e f539 3c6e e9a6 0cac 0d3e 0ea6  .Hh..9<n.....>..
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0160: 006a 6734 77b8 903b 2d9d 7468 bfe7 11ef  .jg4w..;-.th....
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0170: 4587 12ea 6c90 4479 5c60 a67c 572e 0b9b  E...l.Dy\`.|W...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0180: 356c 9c18 eb1e 9ff8 d214 873b e43f 3674  5l.........;.?6t
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0190: 9bf0 efb3 3176 08f7 6088 de82 7db2 acc4  ....1v..`...}...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   01a0: 5309 c0fc e3e9 de73 4b08 f355 7a10 9ebe  S......sK..Uz...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   01b0: 0d3b be34 3aaa d252 5d38 c73d 1106 6d36  .;.4:..R]8.=..m6
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   01c0: 2f89 26a6 11ed fe7e d057 db71 f272 a94a  /.&....~.W.q.r.J
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   01d0: 3994 2146 dff8 e429 6c1a 5c8b b834 7221  9.!F...)l.\..4r!
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   01e0: 7eed 3e03 7e79 55b9 ae65 1da5 5bea a36d  ~.>.~yU..e..[..m
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   01f0: c481 34f9 709c 7141 77b3 3b3e 3ad3 b1be  ..4.p.qAw.;>:...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0200: 1705 6b9b f39b 179a 6d2a 87b5 f1ea 33b8  ..k.....m*....3.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0210: 1351 8978 f50e 82f8 5d06 dfa5 c5b0 95f8  .Q.x....].......
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0220: 853a f532 db77 9643 e0ed 4851 bc16 3e1e  .:.2.w.C..HQ..>.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0230: 4744 f43a 00b2 95c5 042b 1433 33e6 5c9b  GD.:.....+.33.\.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0240: 574e 8756 2a60 2d39 081b ba49 300a cb25  WN.V*`-9...I0..%
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0250: ce15 2c60 6f6b 7e3d 5b0b 4be6 9263 9521  ..,`ok~=[.K..c.!
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0260: e4d0 f9e2 37e2 933f f720 6880 0ea1 3219  ....7..?. h...2.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0270: 2489 8936 0492 8db6 fd55 2068 ef37 7752  $..6.....U h.7wR
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0280: 0097 928f e4ea 4c22 6263 6bcd 9ef2 70d0  ......L"bck...p.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0290: 3f4a 3784 4703 9e28 8bb6 0f02 586d 55d4  ?J7.G..(....XmU.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   02a0: ecc6 f835 834e 0df8 5b9b 60bf 305d 4c4c  ...5.N..[.`.0]LL
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   02b0: dcbb 6e3a 18e0 fb71 6b4d b198 2068 9d2c  ..n:...qkM.. h.,
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   02c0: cf9b 6f8a 6d36 6c19 ef67 e128 b0ab ad60  ..o.m6l..g.(...`
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   02d0: 84f2 8047 c048 d502 ff2e 844d 969f 4d9d  ...G.H.....M..M.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   02e0: 3518 16e2 f0d7 462f fc4b 74b8 98a1 e345  5.....F/.Kt....E
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   02f0: 249d f27e cbcd 4aba aad7 0c7c f7b3 d047  $..~..J....|...G
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0300: 807a bad8 4ece 49ef 007b c8b6 1c52 5333  .z..N.I..{...RS3
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0310: 7180 042f 1630 76d2 9a18 a532 a939 00c2  q../.0v....2.9..
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0320: 0df1 147d 7cae 7fb0 9513 144c 90a4 03a2  ...}|......L....
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0330: 365e 42bc 0845 4c4d 48ec c7c3 3c03 d995  6^B..ELMH...<...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0340: ebba 089d 7f60 70ed c333 228d bba7 b54b  .....`p..3"....K
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0350: 018c 42b0 8d2e dc1e 0147 8d5d 46cd bf5e  ..B......G.]F..^
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0360: 92f9 6d13 ae9a 0ccd 2e32 e6c2 bd00 9940  ..m......2.....@
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0370: 47f4 f36b 0978 1158 6348 b37f d8a7 ab89  G..k.x.XcH......
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0380: 5b22 eeb1 191a c49d 57d5 e397 3d3d 1ff3  ["......W...==..
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0390: d855 77ab 302b f54c c364 5126 b705 9487  .Uw.0+.L.dQ&....
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   03a0: 20eb aa96 8413 e615 975b 0b40 962e 14c2   ........[.@....
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   03b0: a617 0f71 26b8 37ab c252 93c9 b3c1 eb7e  ...q&.7..R.....~
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   03c0: 7d46 c4d3 faba b021 9c2c 347f d24e 5a69  }F.....!.,4..NZi
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   03d0: d1c9 d16a 7784 65a1 fb13 5b30 0238 4f46  ...jw.e...[0.8OF
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   03e0: c343 f086 1c34 cff2 528d 59d5 eb55 6a38  .C...4..R.Y..Uj8
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   03f0: 5b72 d474 a885 0ce6 b898 33b2 09bc 7bfb  [r.t......3...{.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0400: f2a4 81c6 3081 c3a0 0302 0101 a281 bb04  ....0...........
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0410: 81b8 3421 0829 ed9c 5d9b 847a 1083 5333  ..4!.)..]..z..S3
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0420: a091 0647 28f9 356c bed4 9ef3 21aa bfbb  ...G(.5l....!...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0430: 1f72 5073 3983 34d4 4529 c1e9 edc8 f77c  .rPs9.4.E).....|
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0440: bee1 6e61 e8f0 35de c67f a458 e6ea 3e5f  ..na..5....X..>_
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0450: 0945 deda a12f d6a3 e0d7 5055 209e b1b0  .E.../....PU ...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0460: 9799 db54 dd5c 78fc 7080 575a be0e 8e87  ...T.\x.p.WZ....
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0470: 7e5f c8d2 e603 de73 db48 56ff 6f88 f075  ~_.....s.HV.o..u
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0480: fce8 eb81 0846 a22b 174d e0f2 7c4b 4de0  .....F.+.M..|KM.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   0490: c549 7ad1 010f 9e5a 106e b83d 1f12 904a  .Iz....Z.n.=...J
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   04a0: bc18 da24 5d69 6268 b34f 7c5b 66e0 44f6  ...$]ibh.O|[f.D.
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   04b0: 6525 fdc7 01e2 aec0 076d 734e 5fbb 7234  e%.......msN_.r4
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]:   04c0: a61d 04ee f93f 379a 2971                 .....?7.)q
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: sname = nfs/sha9013.hamburg.rwedea.de@HAMBURG.RWEDEA.DE
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: DEBUG: serialize_krb5_ctx: lucid version!
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: doing downcall
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: \x0d000000 2147483647 -1 -1 0 krb5 \x0000000000000000142b48c2ff7f00000ca925070f2b00000000000000000000c12aa34cb4757a31090000002a864886f71201020204000000080000002675a40d1f68d5760400000008000000d68554fdef982586
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: sending null reply
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: writing message: \x \x608204c606092a864886f71201020201006e8204b5308204b1a003020105a10302010ea20703050020000000a38203d1618203cd308203c9a003020105a1131b1148414d425552472e5257454445412e4445a22b3029a003020103a12230201b036e66731b19736861393031322e68616d627572672e7277656465612e6465a382037e3082037aa003020117a103020104a282036c0482036868c94283937af92e3b05ded1d3f4f4025c470512ac1a52fe3f4fdfa55a8f892cdc4a145d7e666ddaed77123cbc60bc20d6523dc8872e68d033f2bc57707171e9a2c22e51eb4520c1d424c90cf1a58752e1aba1f...
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: finished handling null request
>> Sep 29 09:53:06 sha9012 rpc.svcgssd[1667]: entering poll
>>
>>
>> ---------------------------------------------------
>>
>> Thanks a lot for your help. I am really despaired.
>>
>> Kind regards,
>>  Wolfgang
>>
>> P.S: I have to leave my office now and will be back on Monday.
>>
>>
>>
>> -----Ursprüngliche Nachricht-----
>> Von: kwcoffman@gmail.com [mailto:kwcoffman@gmail.com] Im Auftrag von Kevin Coffman
>> Gesendet: Mittwoch, 29. September 2010 16:21
>> An: Beyersdorf, Wolfgang
>> Cc: linux-nfs@vger.kernel.org
>> Betreff: Re: NFS4 / GSS: Problem with users accessing the mounted directories (with root, everything ist okay)
>>
>> On Wed, Sep 29, 2010 at 5:02 AM, Beyersdorf, Wolfgang
>> <Wolfgang.Beyersdorf.Fa.Kontraktor@rwedea.com> wrote:
>>>
>>>
>>>
>>> Dear all,
>>>
>>> I got NFS4 with GSS running on CentOS 5. Everything is okay, all TGTs are okay and is working fine for the user ROOT.
>>>
>>> When I change to an other user, I got a permission denied, when I try to access the dierctory (e.g. ls -la)
>>>
>>> Here is the /var/log/messages part for this access (with full debugging on ndf, ndfs and rcp):
>>>
>>> Sep 29 10:11:59 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de                      <================================== system ist wating for 25 seconds
>>> Sep 29 10:12:23 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
>>> Sep 29 10:12:23 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
>>
>>> [ ... ]
>>
>>> Sep 29 10:12:23 sha9013 rpc.gssd[1645]: creating context with server nfs@sha9012.hamburg.rwedea.de
>>> Sep 29 10:12:48 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
>>> Sep 29 10:12:48 sha9013 rpc.gssd[1645]: WARNING: Failed to create krb5 context for user with uid 569926353 for server sha9012.hamburg.rwedea.de
>>>
>>> A  klist gives the following result:
>>> ========================
>>
>> What does "klist -e" show?
>>
>>>
>>> On the server, there is nothing inside the /var/log/messages
>>>
>>
>> I assume there is output from svcgssd on the server when root accesses it?
>>
>> The 25-second pauses sound as if there is an error of some kind on the
>> server and it is dropping the request rather than replying.  Perhaps a
>> network trace would reveal something.
>>
>> K.C.
>>
>>
>
>
