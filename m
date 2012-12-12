Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 82-69-66-36.dsl.in-addr.zen.co.uk ([82.69.66.36]:65471 "EHLO
	gateway.l8s.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411Ab2LLImn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2012 03:42:43 -0500
Date: Wed, 12 Dec 2012 08:34:01 +0000
From: David Laight <david@l8s.co.uk>
To: Pavel Shilovsky <piastry@etersoft.ru>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, wine-devel@winehq.org
Subject: Re: [PATCH 0/3] Add O_DENY* flags to fcntl and cifs
Message-ID: <20121212083401.GW5010@snowdrop.l8s.co.uk>
References: <1354818391-7968-1-git-send-email-piastry@etersoft.ru> <20121207161602.GA17710@infradead.org> <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <495d17310e0a687d446afc86def0f058@office.etersoft.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 08, 2012 at 12:43:14AM +0400, Pavel Shilovsky wrote:
> 
> The problem is the possibility of denial-of-service attacks here. We 
> can try to prevent them by:

FWIW I already see a DoS 'attack'.
I have some filestore shared using NFS (to Linux and Solaris) and 
using samba (to Windows).

I use it for release builds of a product to ensure the versions
built for the different operating systems match, and because some
files have to be built on an 'alien' system (eg gcc targetted at
embedded card).

I can't run the windows build at the same time as the others
because the windows C compiler manages to obtain exclusive access
to the source files - stopping the other systems from reading them.

	David

-- 
David Laight: david@l8s.co.uk
