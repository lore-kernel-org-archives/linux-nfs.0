From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?= <francois.valenduc@skynet.be>
Subject: nfs and kerberos authentification problem.
Date: Wed, 03 Sep 2008 20:19:37 +0200
Message-ID: <48BED539.1000404@skynet.be>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060106060700060207070605"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yorgi.telenet-ops.be ([195.130.133.69]:35716 "EHLO
	yorgi.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbYICSUM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 14:20:12 -0400
Received: from agave.telenet-ops.be (agave.telenet-ops.be [195.130.137.77])
	by yorgi.telenet-ops.be (Postfix) with ESMTP id 5F9A6682A16
	for <linux-nfs@vger.kernel.org>; Wed,  3 Sep 2008 20:20:10 +0200 (CEST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by agave.telenet-ops.be (Postfix) with SMTP id 7DB0367D30
	for <linux-nfs@vger.kernel.org>; Wed,  3 Sep 2008 20:19:38 +0200 (CEST)
Received: from [192.168.1.2] (user-85-201-69-178.tvcablenet.be [85.201.69.178])
	by agave.telenet-ops.be (Postfix) with ESMTP id 510AF67D29
	for <linux-nfs@vger.kernel.org>; Wed,  3 Sep 2008 20:19:38 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060106060700060207070605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Hello everybody,

I am trying to set up kerberos authentification with nfs but it doesn't 
succeed. I have created to principals for the client and the server. I 
have added the client's principal to the keytab file by setting 
des-encryption (with ktadd -e des-cbc-crc:normal 
nfs/ordi-francois.homenetwork.net). I have changed the /etc/krb5.conf on 
the client file to use des encryption. So, it's set like this;

[libdefaults]
   default_realm = HOMENETWORK.NET
   default_tkt_enctypes = aes256-cts-hmac-sha1-96 des-cbc-crc
   default_tgs_enctypes = aes256-cts-hmac-sha1-96 des-cbc-crc
   permitted_enctypes = aes256-cts-hmac-sha1-96 rc4-hmac des-cbc-crc 
des3-hmac-sha1
   forwardable = true

[realms]
   HOMENETWORK.NET = {
      admin_server = pc-francois.homenetwork.net:749
      kdc = pc-francois.homenetwork.net:88
      }

[domain_realm]
   .homenetwork.net = HOMENETWORK.NET
   homenetwork.net = HOMENETWORK.NET

But, it doesn't succeed. I can see in the log of the server 
(pc-francois) that the client (ordi-francois) get's a kerberos ticket 
but each time I mount a nfs share, it fails with this error:
mount.nfs: permission denied.

Does anybody know what's happening ?
I have put the log of the server in the attached file.

Thanks in advance for your help,

François Valenduc




--------------060106060700060207070605
Content-Type: text/plain;
 name="nfs-kerberos"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-kerberos"

Sep  3 19:36:22 pc-francois mountd[7747]: authenticated mount request from ordi-francois:865 for /home/francois (/home/francois)
Sep  3 19:36:22 pc-francois krb5kdc[9787]: AS_REQ (2 etypes {18 1}) 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=1 tkt=18 ses=18}, nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for krbtgt/HOMENETWORK.NET-wmZDWbG+120CDknkFGB/9A@public.gmane.org
Sep  3 19:36:22 pc-francois krb5kdc[9787]: AS_REQ (2 etypes {18 1}) 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=1 tkt=18 ses=18}, nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for krbtgt/HOMENETWORK.NET-wmZDWbG+120CDknkFGB/9A@public.gmane.org
Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1}) 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=18 tkt=1 ses=1}, nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1}) 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=18 tkt=1 ses=1}, nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: leaving poll
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: handling null request
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: readline: read 1106 chars into buffer of size 2048: \x \x6082022206092a864886f71201020201006e8202113082020da003020105a10302010ea20703050020000000a3820125618201213082011da003020105a11b825f74da9da214cf8780d29b9e4d2020640fbd2c598eb5e23ec084f9a8...

Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: in_handle:
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: length 0
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: in_tok:
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: length 550
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0000: 6082 0222 0609 2a86 4886 f712 0102 0201  `.."..*.H.......
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0010: 006e 8202 1130 8202 0da0 0302 0105 a103  .n...0..........
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0020: 0201 0ea2 0703 0500 2000 0000 a382 0125  ........ ......%
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0030: 6182 0121 3082 011d a003 0201 05a1 111b  a..!0...........
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0040: 0f48 4f4d 454e 4554 574f 524b 2e4e 4554  .HOMENETWORK.NET
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0050: a22d 302b a003 0201 03a1 2430 221b 036e  .-0+......$0"..n
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0060: 6673 1b1b 7063 2d66 7261 6e63 6f69 732e  fs..pc-francois.
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0070: 686f 6d65 6e65 7477 6f72 6b2e 6e65 74a3  homenetwork.net.

...

Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sname = nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: DEBUG: serialize_krb5_ctx: lucid version!
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: doing downcall
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: \x01000000 2147483647 -1 -1 0 krb5 \x0000000000000000b46525b6ff7f00000000000000000000000000000000000016acbf48c5090c26090000002a864886f7120102020400000008000000a2df25511fa8fb680400000008000000522fd5a1ef580b98
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sending null reply
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: writing message: \x \x6082022206092a864886f71201020201006e8202113082020da003020105a10302010ea20703050020000000a3820125618201213082011da003020105a11
...

Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: finished handling null request
Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: entering poll


--------------060106060700060207070605--
