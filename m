From: =?UTF-8?B?RnJhbsOnb2lzIFZhbGVuZHVj?= <francois.valenduc@skynet.be>
Subject: Re: nfs and kerberos authentification problem.
Date: Fri, 05 Sep 2008 20:57:16 +0200
Message-ID: <48C1810C.5090703@skynet.be>
References: <48C01B5F.3060808@skynet.be> <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be> <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be> <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com> <48C0393A.5090503@skynet.be> <20080904194046.GA13981@fieldses.org> <48C17C20.6010707@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ananke.telenet-ops.be ([195.130.137.78]:35050 "EHLO
	ananke.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbYIES5T (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 14:57:19 -0400
In-Reply-To: <48C17C20.6010707@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

=46ran=C3=A7ois Valenduc a =C3=A9crit :
> J. Bruce Fields a =C3=A9crit :
>> On Thu, Sep 04, 2008 at 09:38:34PM +0200, Fran=C3=A7ois Valenduc wro=
te:
>> =20
>>> Kevin Coffman a =C3=A9crit :
>>>   =20
>>>> This may be a stupid question, but can you access the mount using
>>>> auth_sys?  As I think I said before, it looks like the Kerberos pa=
rt
>>>> is working.  (Unless there are errors on the client side from
>>>> rpc.gssd.)
>>>>
>>>>        =20
>>> I finally found a solution to the problem.
>>>    =20
>>
>> Great!
>>
>> =20
>>> It seems that it's needed to  compile both NFS v3 and v4 server=20
>>> support to make kerberos support  working. I find that a bit strang=
e,=20
>>> but with this kernel configuration,  it is working fine. I find tha=
t=20
>>> a bit strange since I export the  filesystem as NFS3.
>>> Should we consider this as a bug ? I am running kernel 2.6.26.3.
>>>    =20
>>
>> Yes, that would be a bug!  But: are you sure gss support was built i=
n on
>> the server?
>>
>> --b.
>>
>> =20
>>> Thanks a lot for your patience,
>>> Fran=C3=A7ois
>>>    =20
>>
>>  =20
> There is still a major problem. Even if I can now mount the filesyste=
m=20
> with kerberos authentification, I can't write any file. Furthermore, =
I=20
> can even not see the content of the exported directory without being=20
> root. Is it due to the problem of uid/gid mapping ?
>=20
> Fran=C3=A7ois

What I don' understand is that the file system is well mounted read-wri=
te:
pc-francois:/home/francois on /mnt/pc-francois type nfs=20
(rw,users,noatime,sec=3Dkrb5,rsize=3D1024,wsize=3D1024,soft,addr=3D192.=
168.1.2)

The mounted directory has the following permissions:

drwxrwsr-x 77 francois francois 4,0K sep  5 20:35 pc-francois/

So, I don't understand why I can't write any file on it.

Thanks for your help;

=46ran=C3=A7ois
