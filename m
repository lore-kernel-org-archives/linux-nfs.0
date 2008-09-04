From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?= <francois.valenduc@skynet.be>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 04 Sep 2008 18:45:03 +0200
Message-ID: <48C0108F.40204@skynet.be>
References: <48BED539.1000404@skynet.be> <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agave.telenet-ops.be ([195.130.137.77]:38693 "EHLO
	agave.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752433AbYIDQpH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 12:45:07 -0400
In-Reply-To: <4d569c330809031312p3515f4d8id9cbec94d871e058-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Coffman a =E9crit :
> Hello Fran=E7ois,
> First, you should not need to limit the encryption types in
> /etc/krb5.conf as you have done.  None of the following lines are
> necessary in either the client or server's /etc/krb5.conf file.
> (Leaving them in will probably lead to headaches with other Kerberos
> applications in the future.)
>
>   default_tkt_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
>   default_tgs_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
>   permitted_enctypes =3D aes256-cts-hmac-sha1-96 rc4-hmac des-cbc-crc
> des3-hmac-sha1
>
> You said that you limited the client's keytab to des-cbc-crc.  It
> appears you have done the same for the server's keytab since the
> ticket and session key the client gets are des-cbc-crc.
>
>  =20
>> Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1})
>> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D18 tkt=3D1 se=
s=3D1},
>> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
>> nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
>>    =20
>
> It looks like the client is successfully authenticating as
> "nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org".
>
>  =20
>> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sname =3D
>> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
>>    =20
>
> However, mapping that gss_auth_name to a local ID is failing, and is
> being mapped to uid/gid of "-1 -1"
> .
>
>  =20
>> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: \x01000000 2147483647=
 -1 -1 0 krb5
>> \x000000000000[...]80b98
>>    =20
>
> The "-1" should be interpreted in the kernel as nfsnobody.  What are
> the permissions on the exported filesystem?
>
> K.C.
>
>  =20
So, is it normat that gss map the local uid/gid to -1 -1 ? If not, what=
=20
should I change ?
The folder I try to export is configured like this:

/home/francois ordi-francois(rw,root_squash,no_subtree_check)

=46ran=E7ois
