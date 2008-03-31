From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Version check in aclocal/kerberos.m5
Date: Mon, 31 Mar 2008 15:29:26 +0200
Message-ID: <20080331132926.GA10294@uio.no>
References: <20080330103159.GA4003@uio.no> <4d569c330803310615n1eb6e911o1e09c3df2ee5a7e2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:38747 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719AbYCaN3a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Mar 2008 09:29:30 -0400
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766] helo=trofast.sesse.net)
	by cassarossa.samfundet.no with esmtps (TLS-1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JgK4l-0002WT-Fj
	for linux-nfs@vger.kernel.org; Mon, 31 Mar 2008 15:29:27 +0200
Received: from root by trofast.sesse.net with local (Exim 4.69)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>)
	id 1JgK4k-0002hZ-Sw
	for linux-nfs@vger.kernel.org; Mon, 31 Mar 2008 15:29:26 +0200
In-Reply-To: <4d569c330803310615n1eb6e911o1e09c3df2ee5a7e2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 31, 2008 at 09:15:37AM -0400, Kevin Coffman wrote:
> Hello Steinar,
> I'm not clear what you are looking to patch?
> 
> It should be possible to improve the parsing in aclocal/kerberos5.m4
> to handle this situation.  Is that what you are looking for?

Yes, that was my idea.

My question was: Does this code actually originate in nfs-utils, or does it
come from somewhere else?

/* Steinar */
-- 
Homepage: http://www.sesse.net/
