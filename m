From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Thu, 4 Sep 2008 14:59:54 -0400
Message-ID: <20080904185954.GR4536@fieldses.org>
References: <4d569c330809031312p3515f4d8id9cbec94d871e058@mail.gmail.com> <48C0108F.40204@skynet.be> <20080904165645.GG4536@fieldses.org> <48C01B5F.3060808@skynet.be> <20080904173346.GJ4536@fieldses.org> <48C01DBD.7000309@skynet.be> <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40656 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbYIDS74 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 14:59:56 -0400
In-Reply-To: <48C02E95.1000406@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2008 at 08:53:09PM +0200, Fran=C3=A7ois Valenduc wrote:
> It's my home directory, so it has normal permission for such a direct=
ory:
> drwxrwsr-x 77 francois francois 4,0K sep  4 20:43 francois/

So everybody has permission to read that directory--OK, that shouldn't
be a problem.

> I don't think there is someting strange with this. I start running ou=
t =20
> of ideas to get it working. I have reenabled nfs4 (which I also tried=
) =20
> and it give the same problem. In order to do that, I off course chang=
ed =20
> the exports file like this;

> /export/francois =20
> ordi-francois(nohide,rw,root_squash,no_subtree_check,sec=3Dsys:krb5)

Let's just pick nfsv3 and stick with it; both nfsv3 and nfsv4 should
work, and switching between the two just complicates the debugging.

What does your mount commandline look like?

Could you get a network trace?  Just start

	tcpdump -s0 -wtmp.pcap

then attempt the mount, then after it fails kill tcpdump and send me
tmp.pcap.

--b.
