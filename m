Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:39314 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694Ab2KIXHt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Nov 2012 18:07:49 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<sven@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1TWxKc-0004fG-5h
	for linux-nfs@vger.kernel.org; Fri, 09 Nov 2012 23:45:46 +0100
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
In-Reply-To: <20121109200730.GI6171@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Message-Id: <E1TWxKX-00025I-J2@diesel.geggus.net>
Date: Fri, 09 Nov 2012 23:45:41 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In article <20121109200730.GI6171@fieldses.org> you wrote:

> Is it possible that your system has very large uid's?  (Large enough
> that they'd look like negative numbers when cast to ints?)

Shurely not. however, mounting is done as root which might get mapped to
nobody which usually is 65534.

> Output from
> 
>        strace -p $(pidof rpc.mountd) -s4096 -e trace=open,close,read,write
> 
> (while reproducing the bug) might help confirm that.

While doing the hanging or while doing the proper mount?

Sven

-- 
Microsoft ist offenbar die einzige Firma, die in der Lage ist, ein mit
Office nicht kompatibles Bürosoftwarepaket einzuführen.
                            (Florian Weimer in de.alt.sysadmin.recovery)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
