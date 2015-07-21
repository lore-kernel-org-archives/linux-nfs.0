Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:47407 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211AbbGUGoq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2015 02:44:46 -0400
Message-ID: <55ADEA5C.8020607@bio.ifi.lmu.de>
Date: Tue, 21 Jul 2015 08:44:44 +0200
From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Parallel file locking quite slow with vers=4.0 compared to vers=3
References: <55ACFF59.7040707@bio.ifi.lmu.de> <20150720212305.GB11050@fieldses.org>
In-Reply-To: <20150720212305.GB11050@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote

> One way to confirm that might be to run client kernels modified to make
> the polling behavior (controlled by
> fs/nfs/nfs4proc.c:nfs4_set_lock_task_retry()) more aggressive, and see
> if that removes the delays in your case.
> 
> If that works, then it might also be worth considering implementing
> CB_NOTIFY_LOCK:
> 
> 	https://tools.ietf.org/html/rfc5661#page-593

I wouldn't mind to test any kind of patch if someone would find the time
to provide some. Writing them myself is beyond my skills I'm afraid :-)

cu,
Frank
-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *
