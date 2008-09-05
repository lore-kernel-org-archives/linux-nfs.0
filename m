From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Fri, 5 Sep 2008 17:23:18 -0400
Message-ID: <20080905212318.GF12947@fieldses.org>
References: <48C01DBD.7000309@skynet.be> <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be> <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com> <48C0393A.5090503@skynet.be> <20080904194046.GA13981@fieldses.org> <48C17C20.6010707@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47725 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751448AbYIEVXV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 17:23:21 -0400
In-Reply-To: <48C17C20.6010707@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 05, 2008 at 08:36:16PM +0200, Fran=C3=A7ois Valenduc wrote:
> There is still a major problem. Even if I can now mount the filesyste=
m =20
> with kerberos authentification, I can't write any file. Furthermore, =
I =20
> can even not see the content of the exported directory without being =
=20
> root. Is it due to the problem of uid/gid mapping ?

Do you have a kerberos credential name for "francois"?  When you're
logged in as francois, what does klist say?

--b.

>
> Fran=C3=A7ois
