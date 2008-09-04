From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 4 Sep 2008 12:56:45 -0400
Message-ID: <20080904165645.GG4536@fieldses.org>
References: <48BED539.1000404@skynet.be> <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com> <48C0108F.40204@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60993 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136AbYIDQ4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 12:56:47 -0400
In-Reply-To: <48C0108F.40204@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 06:45:03PM +0200, Fran=C3=A7ois Valenduc wrote:
> Kevin Coffman a =C3=A9crit :
>> Hello Fran=C3=A7ois,
>> First, you should not need to limit the encryption types in
>> /etc/krb5.conf as you have done.  None of the following lines are
>> necessary in either the client or server's /etc/krb5.conf file.
>> (Leaving them in will probably lead to headaches with other Kerberos
>> applications in the future.)
>>
>>   default_tkt_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
>>   default_tgs_enctypes =3D aes256-cts-hmac-sha1-96 des-cbc-crc
>>   permitted_enctypes =3D aes256-cts-hmac-sha1-96 rc4-hmac des-cbc-cr=
c
>> des3-hmac-sha1
>>
>> You said that you limited the client's keytab to des-cbc-crc.  It
>> appears you have done the same for the server's keytab since the
>> ticket and session key the client gets are des-cbc-crc.
>>
>>  =20
>>> Sep  3 19:36:22 pc-francois krb5kdc[9787]: TGS_REQ (2 etypes {18 1}=
)
>>> 192.168.1.3: ISSUE: authtime 1220463382, etypes {rep=3D18 tkt=3D1 s=
es=3D1},
>>> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org for
>>> nfs/pc-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
>>>    =20
>>
>> It looks like the client is successfully authenticating as
>> "nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org".
>>
>>  =20
>>> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: sname =3D
>>> nfs/ordi-francois.homenetwork.net-wmZDWbG+120CDknkFGB/9A@public.gmane.org
>>>    =20
>>
>> However, mapping that gss_auth_name to a local ID is failing, and is
>> being mapped to uid/gid of "-1 -1"
>> .
>>
>>  =20
>>> Sep  3 19:36:22 pc-francois rpc.svcgssd[7008]: \x01000000 214748364=
7 -1 -1 0 krb5
>>> \x000000000000[...]80b98
>>>    =20
>>
>> The "-1" should be interpreted in the kernel as nfsnobody.  What are
>> the permissions on the exported filesystem?
>>
>> K.C.
>>
>>  =20
> So, is it normat that gss map the local uid/gid to -1 -1 ? If not, wh=
at =20
> should I change ?
> The folder I try to export is configured like this:
>
> /home/francois ordi-francois(rw,root_squash,no_subtree_check)

Assyming you're using nfs-utils 1.1.1 or later, add "sec=3Dkrb5" to the
export options.  (Or "sec=3Dkrb5:krb5i:krb5p" if you also want to allow
integrity and privacy; and "sec=3Dsys:krb5:krb5i:krb5p" if you also wan=
t
to allow auth_sys.)

--b.
