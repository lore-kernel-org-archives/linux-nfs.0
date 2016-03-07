Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mtareserve61.acsu.buffalo.edu ([128.205.6.126]:42967 "EHLO
	mtareserve1.acsu.buffalo.edu" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752681AbcCGQ1P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Mar 2016 11:27:15 -0500
Received: from localmaile.acsu.buffalo.edu (localmaile.acsu.buffalo.edu [128.205.4.3])
	by mtareserve1.acsu.buffalo.edu (Postfix) with ESMTP id BF01DD22290
	for <linux-nfs@vger.kernel.org>; Mon,  7 Mar 2016 11:27:14 -0500 (EST)
Received: from localmaile.acsu.buffalo.edu (localhost [127.0.0.1])
	by localhost (Postfix) with SMTP id B2B76160071
	for <linux-nfs@vger.kernel.org>; Mon,  7 Mar 2016 11:27:14 -0500 (EST)
Received: from localmaile.acsu.buffalo.edu (localhost [127.0.0.1])
	by localmaile.acsu.buffalo.edu (Postfix) with ESMTP id 864F7160082
	for <linux-nfs@vger.kernel.org>; Mon,  7 Mar 2016 11:27:14 -0500 (EST)
Received: from smtp.buffalo.edu (smtp3.acsu.buffalo.edu [128.205.5.226])
	by localmaile.acsu.buffalo.edu (Prefixe) with ESMTP id 85029160071
	for <linux-nfs@vger.kernel.org>; Mon,  7 Mar 2016 11:27:14 -0500 (EST)
Received: from flyline.acsu.buffalo.edu (porkchopexpress.acsu.buffalo.edu [128.205.123.27])
	by smtp.buffalo.edu (Postfix) with ESMTP id 80D81D5794B
	for <linux-nfs@vger.kernel.org>; Mon,  7 Mar 2016 11:27:14 -0500 (EST)
Message-ID: <56DDABE2.3040204@buffalo.edu>
Date: Mon, 07 Mar 2016 11:27:14 -0500
From: Mark Valites <mvalites@buffalo.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: RH 7 nfs-utils update causes segfault
References: <56DDA2C2.3010806@buffalo.edu> <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org>
In-Reply-To: <alpine.OSX.2.19.9992.1603071059490.66950@dhcp0201.cthon.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/07/2016 11:00 AM, Benjamin Coddington wrote:

> Hey Mark, could it be this one?
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1313090
>
> Ben
>

Doesn't look like it:

$ sudo restorecon -v /etc/krb5.keytab
<no output>
$ ls -laZ /etc/krb5.keytab
-rw-------. root root unconfined_u:object_r:krb5_keytab_t:s0 
/etc/krb5.keytab

I'd only had selinux in permissive mode, so I tried disabling it as 
well, but that too unfortunately made no difference.
