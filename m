Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from messager.iut-bm.univ-fcomte.fr ([194.57.86.195]:57798 "EHLO
	messager.iut-bm.univ-fcomte.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753445Ab0DLKcm convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Apr 2010 06:32:42 -0400
From: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: BUG: cannot acquire lock twice with NFSv4
References: <wwer5mo3hf9.fsf@powwow.iut-bm.univ-fcomte.fr>
	<wwed3y73da5.fsf@powwow.iut-bm.univ-fcomte.fr>
	<1270999493.4663.1.camel@localhost.localdomain>
	<1271019030.2898.1.camel@localhost.localdomain>
Date: Mon, 12 Apr 2010 12:32:34 +0200
In-Reply-To: <1271019030.2898.1.camel@localhost.localdomain> (Trond
	Myklebust's message of "Sun, 11 Apr 2010 16:50:30 -0400")
Message-ID: <wwe633x2c71.fsf@powwow.iut-bm.univ-fcomte.fr>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dimanche 11 avril 2010, vers 22:50:30 (+0200), Trond Myklebust a écrit :

> How about the following?
> ----------------------------------------------------------------------------------------------- 
> NFSv4: fix delegated locking
[...]

It looks fine to me, and the locking now appears to work as expected.

Thank you!

        Arnaud
