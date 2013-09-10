Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp4-g21.free.fr ([212.27.42.4]:49598 "EHLO smtp4-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751890Ab3IJNeR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Sep 2013 09:34:17 -0400
Date: Tue, 10 Sep 2013 15:34:09 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130910153409.3a418270@harpe.intellique.com>
In-Reply-To: <20130910132841.GC16011@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
	<20130905204536.GB24805@fieldses.org>
	<20130905233449.5eb8bf79@galadriel.home>
	<20130905214002.GD24805@fieldses.org>
	<20130906175721.30082c11@harpe.intellique.com>
	<20130906160735.GA16396@fieldses.org>
	<20130906185508.3f0d2730@harpe.intellique.com>
	<20130910132841.GC16011@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Le Tue, 10 Sep 2013 09:28:41 -0400
"J. Bruce Fields" <bfields@fieldses.org> écrivait:

> Sure, maybe.
> 
> Honestly looks like a network problem, if it weren't for the failing
> on the filesystem operation each time.
> 
> Hm, it may just be the first packet of a certain size.  In fact it's
> the first frame > 1500 bytes in that trace.  Is there some problem
> with jumbo frame configuration on your network?
> 

Interesting idea. I could try forcing both interfaces to 1500 mtu and
see what's happening. Oh, maybe the VMWare host interface /isn't/ set
to 9000? I'll check that. Thank you.

-- 
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------
