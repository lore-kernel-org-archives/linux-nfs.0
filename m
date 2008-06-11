From: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Subject: .Xauthority going stale (but not really)
Date: Wed, 11 Jun 2008 08:53:08 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.0806110849250.11896@qygrfg01.brgvxre.pu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from james.oetiker.ch ([213.144.138.195]:32787 "EHLO
	james.oetiker.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752836AbYFKHSi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jun 2008 03:18:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by james.oetiker.ch (Postfix) with ESMTP id A305B888C2
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2008 08:53:08 +0200 (CEST)
Received: from james.oetiker.ch ([127.0.0.1])
	by localhost (james.oetiker.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id BxZi5+wK2kwR for <linux-nfs@vger.kernel.org>;
	Wed, 11 Jun 2008 08:53:08 +0200 (CEST)
Received: from johan.oetiker.ch (johan.oetiker.ch [213.144.133.194])
	by james.oetiker.ch (Postfix) with ESMTP id 86383888BE
	for <linux-nfs@vger.kernel.org>; Wed, 11 Jun 2008 08:53:08 +0200 (CEST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Experts,

I have a strange problem on a diskless client. At ramdom intervals
(hours) when I try to open an xterm I get the message

 > xterm
 No protocol specified
 xterm Xt error: Can't open display: :13.0

Doing an strace on xterm I find that it gets a 'stale nfs handle'
when trying to open .Xauthority.

If I do a

 cat .Xauthority >/dev/null

things go back to normal and I can open xterms again ...

so how can it be, that xterm gets a stale nfs handle error while
cat can read the file just fine and after cat did it it works for
xterm as well ?

Our home directories are automounted via nfs and then from there
bindmounted into /home if that rings a bell ...

cheers
tobi


-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten
http://it.oetiker.ch tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org ++41 62 213 9902
