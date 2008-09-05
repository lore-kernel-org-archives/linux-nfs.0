From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfs and kerberos authentification problem.
Date: Fri, 5 Sep 2008 17:26:43 -0400
Message-ID: <20080905212643.GG12947@fieldses.org>
References: <20080904174928.GM4536@fieldses.org> <48C021E0.9000901@skynet.be> <20080904183934.GO4536@fieldses.org> <48C02E95.1000406@skynet.be> <20080904185954.GR4536@fieldses.org> <4d569c330809041231wcbddde8w419968280de9e39a@mail.gmail.com> <48C0393A.5090503@skynet.be> <20080904194046.GA13981@fieldses.org> <48C17C20.6010707@skynet.be> <48C1810C.5090703@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Kevin Coffman <kwc@umich.edu>, linux-nfs@vger.kernel.org
To: =?utf-8?B?RnJhbsOnb2lz?= Valenduc <francois.valenduc@skynet.be>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:44829 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693AbYIEV0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Sep 2008 17:26:44 -0400
In-Reply-To: <48C1810C.5090703@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 05, 2008 at 08:57:16PM +0200, Fran=C3=A7ois Valenduc wrote:
> What I don' understand is that the file system is well mounted read-w=
rite:
> pc-francois:/home/francois on /mnt/pc-francois type nfs =20
> (rw,users,noatime,sec=3Dkrb5,rsize=3D1024,wsize=3D1024,soft,addr=3D19=
2.168.1.2)
>
> The mounted directory has the following permissions:
>
> drwxrwsr-x 77 francois francois 4,0K sep  5 20:35 pc-francois/
>
> So, I don't understand why I can't write any file on it.

The way it would normally work is you'd have a kerberos principal named
"francois-wmZDWbG+120CDknkFGB/9A@public.gmane.org", and you'd run

	kinit francois-wmZDWbG+120CDknkFGB/9A@public.gmane.org

(or that'd be done automatically for you on login if you have the right
pam setup).  When you do an nfs operation then the server will see you
as francois-wmZDWbG+120CDknkFGB/9A@public.gmane.org, look for a local user named "francois", an=
d
use that uid/gid.

But all authentication in nfs is per-user, not per-client, so you need =
a
krb5 principal for each user.

--b.
