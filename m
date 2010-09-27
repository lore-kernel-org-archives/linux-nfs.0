Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.asenwelt.de ([89.238.66.139]:45234 "EHLO
	extern.asenwelt.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755266Ab0I0Ru4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 13:50:56 -0400
Received: from [192.168.6.50] (188-192-68-246-dynip.superkabel.de [188.192.68.246])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by extern.asenwelt.de (Postfix) with ESMTPSA id 59A023C79D
	for <linux-nfs@vger.kernel.org>; Mon, 27 Sep 2010 17:50:55 +0000 (UTC)
Message-ID: <4CA0D97D.5080904@asenwelt.de>
Date: Mon, 27 Sep 2010 19:50:53 +0200
From: Malte Zacharias <kernel-ml-alias@asenwelt.de>
To: linux-nfs@vger.kernel.org
Subject: Re: NFS+krb5 ID mapping always maps to nobody
References: <4C9E72BB.5080000@asenwelt.de> <20100927171227.GA12033@fieldses.org>
In-Reply-To: <20100927171227.GA12033@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


> If you're using kerberos then it's the kerberos principal name->uid
> mapping that matters here.
> 
> So:
> 
>> [...]
>
> who did you kinit as before doing this?  (What does klist say?)

I kinit'ed as nfstest01@TADPOLE (my domain is .local, while the realm is
TADPOLE, can this be a cause of the problem?)

I repeated the same test with rpc.idmapd configured to use domain
TADPOLE, results where the same. Unfortunately I found no log mentioning
the principal used.

===============================================
nfstest01@desktop:/mnt/nfs$ klist
Ticket cache: FILE:/tmp/krb5cc_4321_CWpZhW
Default principal: nfstest01@TADPOLE

Valid starting     Expires            Service principal
09/27/10 19:42:07  09/28/10 19:42:07  krbtgt/TADPOLE@TADPOLE
	renew until 09/27/10 19:42:07
nfstest01@desktop:/mnt/nfs$ ls -l
total 8
drwxrwxrwx 2 root      root      4096 2010-07-04 16:00 heap
drwxr-x--- 2 nfstest01 nfstest01 4096 2010-09-25 22:34 nfstest01
nfstest01@desktop:/mnt/nfs$ touch heap/test
nfstest01@desktop:/mnt/nfs$ touch nfstest01/test
touch: cannot touch `nfstest01/test': Permission denied
nfstest01@desktop:/mnt/nfs$ klist
Ticket cache: FILE:/tmp/krb5cc_4321_CWpZhW
Default principal: nfstest01@TADPOLE

Valid starting     Expires            Service principal
09/27/10 19:42:07  09/28/10 19:42:07  krbtgt/TADPOLE@TADPOLE
	renew until 09/27/10 19:42:07
09/27/10 19:42:25  09/28/10 19:42:07  nfs/iris.local@TADPOLE
	renew until 09/27/10 19:42:07
===============================================


I verified that the user nfstest01 exists on both systems in the
respective /etc/passwd files.

Best Regards
Malte Zacharias
