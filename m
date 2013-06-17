Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.rfc2324.org ([31.172.8.67]:43508 "EHLO mail.rfc2324.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751090Ab3FQRC4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 13:02:56 -0400
Received: from rfc2324.org ([31.172.8.84] helo=principal.rfc2324.org)
	by mail.rfc2324.org with esmtp rfc2324.org Mailserver
	id 1UocpL-0006qq-SA
	for <linux-nfs@vger.kernel.org>; Mon, 17 Jun 2013 19:02:53 +0200
Date: Mon, 17 Jun 2013 19:02:47 +0200
From: Maximilian Wilhelm <max@rfc2324.org>
To: linux-nfs@vger.kernel.org
Message-ID: <20130617170247.GA16125@principal.rfc2324.org>
References: <20130611093403.GB27345@principal.rfc2324.org>
 <20130611114114.GB16756@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130611114114.GB16756@umich.edu>
Subject: Re: [PATCH]: gssd: Fix preferred_realm option handling
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anno domini 2013 Jim Rees scripsit:

> Maximilian Wilhelm wrote:

>   +	 * Make sure the preferred_realm (which may have been explicitly set
>   +	 * on the command line, is tried first. If nothing is found go on with
>   +	 * the host and local default realm (if that hasn't already been tried).

> You're missing a close paren there somewhere.

Indeed. The first '(' should have been a ','.

Anyone willing to apply this?

Thanks
Max
-- 
Fortschritt bedeutet, einen Schritt so zu machen,
daß man den nächsten auch noch machen kann.
