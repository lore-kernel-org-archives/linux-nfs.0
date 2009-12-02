From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: 2.6.31.6, unresponsiveness and something with nfs
Date: Wed, 02 Dec 2009 22:19:40 +0100
Message-ID: <4B16D9EC.7080009@krogh.cc>
References: <4B13FBE7.9040304@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:41501 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753016AbZLBVTn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2009 16:19:43 -0500
In-Reply-To: <4B13FBE7.9040304-Q2TZfHgGEy4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I have a system running 2.6.31.6 that when running a particular process
> become "unresponsive". I cannot really tell what it is but the effect is
> that logins as ordinary users hangs, when that user has its home on a
> remote NFS-server.
> 
> so from root "su - localuser" works excellent. But su - user-with-home
> on-nfs doesnt.

Ok, the situation is more advanced than just that. I now have the
"sorting" process running while there is high cpu-only load and that
doesn't trigger the problem, so it seems to be that I have to have
"large merging, high cpu-load and lots of networktraffic on the NIC
(10GbitE)" before I encounter the prooblem.

Is there anything I can do to get a trace or other information about
what's holding the "login" process back the next time I get into this
situation?

Thanks
-- 
Jesper

