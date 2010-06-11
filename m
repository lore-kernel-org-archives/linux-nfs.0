Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from crash-1.cutaway.it ([89.186.66.80]:60141 "EHLO mail.cutaway.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759752Ab0FKItp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jun 2010 04:49:45 -0400
Message-ID: <4C11F8A7.3040303@miamammausalinux.org>
Date: Fri, 11 Jun 2010 10:49:43 +0200
From: RaSca <rasca@miamammausalinux.org>
Reply-To: rasca@miamammausalinux.org
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: Problem using exportfs in an active-active nfs cluster
References: <4C0E6ED0.60200@miamammausalinux.org>	<20100609075425.7ec4ccd9@notabene.brown>	<4C0F4634.8090102@miamammausalinux.org>	<20100609180439.40e856ac@notabene.brown>	<4C0F6CDB.5050004@miamammausalinux.org> <20100610140908.3a07596c@notabene.brown>
In-Reply-To: <20100610140908.3a07596c@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Il giorno Gio 10 Giu 2010 06:09:08 CET, Neil Brown ha scritto:
[...]
> Do you disable the network interface that the clients connect to *before*
> unexporting?  If you don't, you should.
> Maybe run mountd with "-d all" and see what it is doing when you are
> unexporting and unmounting.

So, after a very long time, here is the solution. You were absolutely 
right: i was not disabling the ip address first. Anyway it remains a 
little bit strange that exportfs -u does not unlock the exported 
filesystem, but removing the ip first makes things goes smooth, so... 
Many thanks again!

Have a good day.

-- 
RaSca
Mia Mamma Usa Linux: Niente è impossibile da capire, se lo spieghi bene!
rasca@miamammausalinux.org
http://www.miamammausalinux.org
