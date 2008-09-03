From: "Kevin Coffman" <kwc@umich.edu>
Subject: Re: nfs and kerberos authentification problem.
Date: Wed, 3 Sep 2008 16:12:35 -0400
Message-ID: <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com>
References: <48BED539.1000404@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "=?ISO-8859-1?Q?Fran=E7ois_Valenduc?=" <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:14217 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbYICUMg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Sep 2008 16:12:36 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2936183wfd.4
        for <linux-nfs@vger.kernel.org>; Wed, 03 Sep 2008 13:12:36 -0700 (PDT)
In-Reply-To: <48BED539.1000404@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Fran=E7ois,
=46irst, you should not need to limit the encryption types in
/etc/krb5.conf as you have done.  None of the following lines are
necessary in either the client or server's /etc/krb5.conf file.
(Leaving them in will probably lead to headaches with other Kerberos
applications in the future.)

  default_tkt_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
  default_tgs_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
  permitted_enctypes =3D aes256-cts-hmac-sha1-96 rc4-hmac des-cbc-crc
des3-hmac-sha1

You said that you limited the client's keytab to des-cbc-crc.  It
appears you have done the same for the server's keytab since the
ticket and session key the client gets are des-cbc-crc.

> Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1})
> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D18 tkt=3D1 ses=
=3D1},
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
> nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org

It looks like the client is successfully authenticating as
"nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org".

> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sname =3D
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org

However, mapping that gss_auth_name to a local ID is failing, and is
being mapped to uid/gid of "-1 -1"
=2E

> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: \x01000000 2147483647 =
-1 -1 0 krb5
> \x000000000000[...]80b98

The "-1" should be interpreted in the kernel as nfsnobody.  What are
the permissions on the exported filesystem?

K.C.

On Wed, Sep 3, 2008 at 2:19 PM, Fran=E7ois Valenduc
<francois.valenduc@skynet.be> wrote:
> Hello everybody,
>
> I am trying to set up kerberos authentification with nfs but it doesn=
't
> succeed. I have created to principals for the client and the server. =
I have
> added the client's principal to the keytab file by setting des-encryp=
tion
> (with ktadd -e des-cbc-crc:normal nfs/ordi-francois.homenetwork.net).=
 I have
> changed the /etc/krb5.conf on the client file to use des encryption. =
So,
> it's set like this;
>
> [libdefaults]
>  default_realm =3D HOMENETWORK.NET
>  default_tkt_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
>  default_tgs_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
>  permitted_enctypes =3D aes256-cts-hmac-sha1-96 rc4-hmac des-cbc-crc
> des3-hmac-sha1
>  forwardable =3D true
>
> [realms]
>  HOMENETWORK.NET =3D {
>     admin_server =3D pc-francois.homenetwork.net:749
>     kdc =3D pc-francois.homenetwork.net:88
>     }
>
> [domain_realm]
>  .homenetwork.net =3D HOMENETWORK.NET
>  homenetwork.net =3D HOMENETWORK.NET
>
> But, it doesn't succeed. I can see in the log of the server (pc-franc=
ois)
> that the client (ordi-francois) get's a kerberos ticket but each time=
 I
> mount a nfs share, it fails with this error:
> mount.nfs: permission denied.
>
> Does anybody know what's happening ?
> I have put the log of the server in the attached file.
>
> Thanks in advance for your help,
>
> Fran=E7ois Valenduc
>
>
>
>
> Sep  3 19:36:22 pc-francois mountd[7747]: authenticated mount request=
 from
> ordi-francois:865 for /home/francois (/home/francois)
> Sep  3 19:36:22 pc-francois krb5kdc[9787]: AS_REQ (2 etypes {18 1})
> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D1 tkt=3D18 ses=
=3D18},
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
> krbtgt/HOMENETWORK.NET-wmZDWbG+120CDknkFGB/9A@public.gmane.org
> Sep  3 19:36:22 pc-francois krb5kdc[9787]: AS_REQ (2 etypes {18 1})
> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D1 tkt=3D18 ses=
=3D18},
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
> krbtgt/HOMENETWORK.NET-wmZDWbG+120CDknkFGB/9A@public.gmane.org
> Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1})
> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D18 tkt=3D1 ses=
=3D1},
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
> nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
> Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1})
> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D18 tkt=3D1 ses=
=3D1},
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
> nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: leaving poll
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: handling null request
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: readline: read 1106 ch=
ars
> into buffer of size 2048: \x
> \x6082022206092a864886f71201020201006e8202113082020da003020105a103020=
10ea20703050020000000a3820125618201213082011da003020105a11b825f74da9da2=
14cf8780d29b9e4d2020640fbd2c598eb5e23ec084f9a8...
>
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: in_handle:
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: length 0
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: in_tok:
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: length 550
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0000: 6082 0222 0609=
 2a86
> 4886 f712 0102 0201  `.."..*.H.......
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0010: 006e 8202 1130=
 8202
> 0da0 0302 0105 a103  .n...0..........
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0020: 0201 0ea2 0703=
 0500
> 2000 0000 a382 0125  ........ ......%
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0030: 6182 0121 3082=
 011d
> a003 0201 05a1 111b  a..!0...........
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0040: 0f48 4f4d 454e=
 4554
> 574f 524b 2e4e 4554  .HOMENETWORK.NET
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0050: a22d 302b a003=
 0201
> 03a1 2430 221b 036e  .-0+......$0"..n
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0060: 6673 1b1b 7063=
 2d66
> 7261 6e63 6f69 732e  fs..pc-francois.
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]:   0070: 686f 6d65 6e65=
 7477
> 6f72 6b2e 6e65 74a3  homenetwork.net.
>
> ...
>
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sname =3D
> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: DEBUG: serialize_krb5_=
ctx:
> lucid version!
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: prepare_krb5_rfc1964_b=
uffer:
> serializing keys with enctype 4 and length 8
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: doing downcall
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: \x01000000 2147483647 =
-1 -1 0
> krb5
> \x0000000000000000b46525b6ff7f00000000000000000000000000000000000016a=
cbf48c5090c26090000002a864886f7120102020400000008000000a2df25511fa8fb68=
0400000008000000522fd5a1ef580b98
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sending null reply
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: writing message: \x
> \x6082022206092a864886f71201020201006e8202113082020da003020105a103020=
10ea20703050020000000a3820125618201213082011da003020105a11
> ...
>
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: finished handling null
> request
> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: entering poll
>
>
>
