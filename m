Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:41099 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934363AbbGVOtG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 10:49:06 -0400
Message-ID: <55AFAD60.7040607@bio.ifi.lmu.de>
Date: Wed, 22 Jul 2015 16:49:04 +0200
From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Parallel file locking quite slow with vers=4.0 compared to vers=3
References: <55ACFF59.7040707@bio.ifi.lmu.de> <20150720212305.GB11050@fieldses.org> <55ADEA5C.8020607@bio.ifi.lmu.de> <20150721155144.GC11050@fieldses.org>
In-Reply-To: <20150721155144.GC11050@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote
o provide some. Writing them myself is beyond my skills I'm afraid :-)
> 
> Well, I was just thinking of something like this.
> 
> (*Not* saying this is what we really want to do, but it might help
> confirm where your delay is coming from.)

Thanks! I tried your patch and it goes way faster. The last 2 or 3
of 20 xterms that I start in parallel still take about 1-3 seconds,
but the rest is poping up immediately. NFS3 is still better as it
shows all xterm (almost) immediately, but the patch definitely is 
an improvement.

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *
