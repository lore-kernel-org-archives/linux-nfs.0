From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: Re: Mount error with NFSv4 and Kerberos (Bad encryption type)
Date: Wed, 30 Jun 2010 19:22:37 +0300 (EEST)
Message-ID: <alpine.DEB.2.00.1006301918360.17692@kosh.hut.fi>
References: <1277912631.11798.22.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Laurent Bonnaud <bonnaud-jHyHnS8NkcXLSxaa5bH2iPQULIy34Utc@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-1.hut.fi ([130.233.228.91]:34552 "EHLO smtp-1.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964Ab0F3QWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jun 2010 12:22:42 -0400
In-Reply-To: <1277912631.11798.22.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 30 Jun 2010, Laurent Bonnaud wrote:

> On the server /etc/krb5.conf does contain the following line (see the
> attached file):
>
>  allow_weak_crypto = true

Put that on the client as well and it should work.

--
Timo Aaltonen
Systems Specialist
Aalto IT
