From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?= <francois.valenduc@skynet.be>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 04 Sep 2008 21:38:34 +0200
Message-ID: <48C0393A.5090503@skynet.be>
References: <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com>	 <20080904165645.GG4536@fieldses.org> <48C01B5F.3060808@skynet.be>	 <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be>	 <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be>	 <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be>	 <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ananke.telenet-ops.be ([195.130.137.78]:59524 "EHLO
	ananke.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbYIDTih (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2008 15:38:37 -0400
In-Reply-To: <4d569c330809041231wcbddde8w419968280de9e39a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Coffman a =E9crit :
> On Thu, Sep 4, 2008 at 2:59 PM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
>  =20
>> On Thu, Sep 04, 2008 at 08:53:09PM +0200, Fran=E7ois Valenduc wrote:
>>    =20
>>> It's my home directory, so it has normal permission for such a dire=
ctory:
>>> drwxrwsr-x 77 francois francois 4,0K sep  4 20:43 francois/
>>>      =20
>> So everybody has permission to read that directory--OK, that shouldn=
't
>> be a problem.
>>
>>    =20
>>> I don't think there is someting strange with this. I start running =
out
>>> of ideas to get it working. I have reenabled nfs4 (which I also tri=
ed)
>>> and it give the same problem. In order to do that, I off course cha=
nged
>>> the exports file like this;
>>>      =20
>>> /export/francois
>>> ordi-francois(nohide,rw,root_squash,no_subtree_check,sec=3Dsys:krb5=
)
>>>      =20
>> Let's just pick nfsv3 and stick with it; both nfsv3 and nfsv4 should
>> work, and switching between the two just complicates the debugging.
>>
>> What does your mount commandline look like?
>>
>> Could you get a network trace?  Just start
>>
>>        tcpdump -s0 -wtmp.pcap
>>
>> then attempt the mount, then after it fails kill tcpdump and send me
>> tmp.pcap.
>>
>> --b.
>>    =20
>
> This may be a stupid question, but can you access the mount using
> auth_sys?  As I think I said before, it looks like the Kerberos part
> is working.  (Unless there are errors on the client side from
> rpc.gssd.)
>
>  =20
I finally found a solution to the problem. It seems that it's needed to=
=20
compile both NFS v3 and v4 server support to make kerberos support=20
working. I find that a bit strange, but with this kernel configuration,=
=20
it is working fine. I find that a bit strange since I export the=20
filesystem as NFS3.
Should we consider this as a bug ? I am running kernel 2.6.26.3.

Thanks a lot for your patience,
=46ran=E7ois
