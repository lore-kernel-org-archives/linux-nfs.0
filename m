Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:38595 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751681AbbGTOKL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 10:10:11 -0400
Received: from [IPv6:2001:4ca0:4000:1011:141:84:1:30] (galois.bio.ifi.lmu.de [IPv6:2001:4ca0:4000:1011:141:84:1:30])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: steiner.bio)
	by acheron.ifi.lmu.de (Postfix) with ESMTPSA id A006694A204
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2015 16:02:01 +0200 (CEST)
Message-ID: <55ACFF59.7040707@bio.ifi.lmu.de>
Date: Mon, 20 Jul 2015 16:02:01 +0200
From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Parallel file locking quite slow with vers=4.0 compared to vers=3
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we ran into this when opening about a dozen "xterm ...&"  in an ~/.xinitrc on
a diskless client with /var mounted with NFS. The xterms popup one after
another and sometimes it takes up to 7 or 8 seconds until they are all
available.

This works without any noticeable delay as long as /var was exported/mounted
with NFSv3. After switching to NFSv4 the delay showed up. It's caused
by the utempter processes called by xterm that are trying to write
(and thus lock) to /var/log/wtmp in parallel.

Making some little test with a c program doing nothing but 
"fcntl (fd, F_SETLKW, &lck);" with "lck.l_type = F_WRLCK" it turned out
that executing ten instances of this program on a NFSv3 share work
within one second, while on a NFSv4 share about 5 or 6 return immediately,
the remaining finish after up to 3 seconds. The more instances we
exec the more are delayed and the delays are getting bigger.

With NFSv4 shares this always happens.
If the server exports with NFSv3, it matters which value for vers= 
the client uses. We mounted the same nfs3-export once with "vers=3" 
and once with "vers=4.0" on the same client. The test on the vers=3 
mount shows no delays even with 20 parallel runs, the vers=4.0 mount 
has the delays.

I guess this is some kind of flodding protection for parallel operations,
but can it be tweaked on the server or the client side somehow? Apart
from the xinitrc setting we have some other (weird :-)) scenarions where
this delay are ugly and we would be happy to get rid of them (while still
using NFSv4).

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *
