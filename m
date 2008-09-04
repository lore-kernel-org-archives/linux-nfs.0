From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 4 Sep 2008 15:40:46 -0400
Message-ID: <20080904194046.GA13981@fieldses.org>
References: <48C01B5F.3060808@skynet.be> <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be> <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be> <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com> <48C0393A.5090503@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47468 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640AbYIDTks (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 15:40:48 -0400
In-Reply-To: <48C0393A.5090503@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 09:38:34PM +0200, Fran=C3=A7ois Valenduc wrote:
> Kevin Coffman a =C3=A9crit :
>> This may be a stupid question, but can you access the mount using
>> auth_sys?  As I think I said before, it looks like the Kerberos part
>> is working.  (Unless there are errors on the client side from
>> rpc.gssd.)
>>
>>  =20
> I finally found a solution to the problem.

Great!

> It seems that it's needed to =20
> compile both NFS v3 and v4 server support to make kerberos support =20
> working. I find that a bit strange, but with this kernel configuratio=
n, =20
> it is working fine. I find that a bit strange since I export the =20
> filesystem as NFS3.
> Should we consider this as a bug ? I am running kernel 2.6.26.3.

Yes, that would be a bug!  But: are you sure gss support was built in o=
n
the server?

--b.

>
> Thanks a lot for your patience,
> Fran=C3=A7ois
