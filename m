From: Tobias Oetiker <tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org>
Subject: 2.6.22.19 mount problem for /usr with nfs-root (diskless)
Date: Thu, 28 Feb 2008 16:16:44 +0100 (CET)
Message-ID: <alpine.DEB.1.00.0802281603000.5281@sebohet.brgvxre.pu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from james.oetiker.ch ([213.144.138.195]:37712 "EHLO
	james.oetiker.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758118AbYB1Pib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Feb 2008 10:38:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by james.oetiker.ch (Postfix) with ESMTP id C4F278AEF0
	for <linux-nfs@vger.kernel.org>; Thu, 28 Feb 2008 16:16:44 +0100 (CET)
Received: from james.oetiker.ch ([127.0.0.1])
	by localhost (james.oetiker.ch [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id Ug6kI626-RoS for <linux-nfs@vger.kernel.org>;
	Thu, 28 Feb 2008 16:16:44 +0100 (CET)
Received: from johan.oetiker.ch (johan.oetiker.ch [213.144.133.194])
	by james.oetiker.ch (Postfix) with ESMTP id A6D148AEDF
	for <linux-nfs@vger.kernel.org>; Thu, 28 Feb 2008 16:16:44 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi List,

I am running a diskless linux setup. I tired to upgrade to kernel
2.6.22.19 and found the following:

If I have the following exports on my server (2.6.24.2)

 /partition-a/client-root-a
 /partition-a/client-root-b
 /partition-a/client-root-c
 /partition-a/client-usr

Once the client has booted off /partition-a/client-root-a it can
not mount /partition-a/client-usr.

It complains with

 mount:  server:/partition-a/client-usr  already mounted or /usr busy

which is not true ...

Mouting also does not work if I try to mount this partition
anywhere else. I also get the same error if I try to mount any
other directory shared below /partition-a (/partition-a/XXXX)

If I move /partition-a/client-usr to /partition-b/client-usr
then everything works well ...

I have seen that 2.6.22.19 got quite a number of nfs patches, so
maybe this rings a bell with someone ... let me know if you need
more details.

cheers
tobi

ps. the setup works fine with 2.6.24.2 clients and 2.6.22.9 clients

-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten
http://it.oetiker.ch tobi-7K0TWYW2a3pyDzI6CaY1VQ@public.gmane.org ++41 62 213 9902
