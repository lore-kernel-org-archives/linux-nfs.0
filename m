Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:53462 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbbGUN53 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2015 09:57:29 -0400
Received: from [IPv6:2001:4ca0:4000:1011:141:84:1:30] (galois.bio.ifi.lmu.de [IPv6:2001:4ca0:4000:1011:141:84:1:30])
	(using TLSv1 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: steiner.bio)
	by acheron.ifi.lmu.de (Postfix) with ESMTPSA id 885BB94A25B
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2015 15:57:26 +0200 (CEST)
Message-ID: <55AE4FC6.6050001@bio.ifi.lmu.de>
Date: Tue, 21 Jul 2015 15:57:26 +0200
From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Are there really no server-side mount/umount message for NFSv4?
Content-Type: text/plain; charset=ISO-8859-15
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we are missing the "authenticated u/mount request..." messages or 
error messages like "refused mount request from /x (/): not exported"
for NFSv4 servers. We were using the mount/umount messages e.g. to 
detect when some reached a certain point of an installation etc.
And the error messages on the server side often were more helpful
than the ones on the client.

Is there really no way to get these easy-to-understand messages? 
Debugging shows a lot but nothing that e.g. gives an understandable
error reason.

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *
