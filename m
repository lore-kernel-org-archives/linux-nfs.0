From: =?UTF-8?B?RnJhbsOnb2lzIFZhbGVuZHVj?= <francois.valenduc@skynet.be>
Subject: Re: nfs and kerberos authentification problem.
Date: Fri, 05 Sep 2008 20:36:16 +0200
Message-ID: <48C17C20.6010707@skynet.be>
References: <48C01B5F.3060808@skynet.be> <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be> <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be> <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com> <48C0393A.5090503@skynet.be> <20080904194046.GA13981@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agave.telenet-ops.be ([195.130.137.77]:49514 "EHLO
	agave.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbYIESgU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 14:36:20 -0400
In-Reply-To: <20080904194046.GA13981@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields a =C3=A9crit :
> On Thu, Sep 04, 2008 at 09:38:34PM +0200, Fran=C3=A7ois Valenduc wrot=
e:
>  =20
>> Kevin Coffman a =C3=A9crit :
>>    =20
>>> This may be a stupid question, but can you access the mount using
>>> auth_sys?  As I think I said before, it looks like the Kerberos par=
t
>>> is working.  (Unless there are errors on the client side from
>>> rpc.gssd.)
>>>
>>>  =20
>>>      =20
>> I finally found a solution to the problem.
>>    =20
>
> Great!
>
>  =20
>> It seems that it's needed to =20
>> compile both NFS v3 and v4 server support to make kerberos support =20
>> working. I find that a bit strange, but with this kernel configurati=
on, =20
>> it is working fine. I find that a bit strange since I export the =20
>> filesystem as NFS3.
>> Should we consider this as a bug ? I am running kernel 2.6.26.3.
>>    =20
>
> Yes, that would be a bug!  But: are you sure gss support was built in=
 on
> the server?
>
> --b.
>
>  =20
>> Thanks a lot for your patience,
>> Fran=C3=A7ois
>>    =20
>
>  =20
There is still a major problem. Even if I can now mount the filesystem=20
with kerberos authentification, I can't write any file. Furthermore, I=20
can even not see the content of the exported directory without being=20
root. Is it due to the problem of uid/gid mapping ?

=46ran=C3=A7ois
