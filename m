Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 82-69-66-36.dsl.in-addr.zen.co.uk ([82.69.66.36]:64544 "EHLO
	gateway.l8s.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973Ab3CAI0N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2013 03:26:13 -0500
Date: Fri, 1 Mar 2013 08:17:29 +0000
From: David Laight <david@l8s.co.uk>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Pavel Shilovsky <piastry@etersoft.ru>, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, wine-devel@winehq.org
Subject: Re: [PATCH v3 0/7] Add O_DENY* support for VFS and CIFS/NFS
Message-ID: <20130301081729.GT5181@snowdrop.l8s.co.uk>
References: <1362065133-9490-1-git-send-email-piastry@etersoft.ru> <512FD1D5.3010106@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <512FD1D5.3010106@mit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2013 at 01:53:25PM -0800, Andy Lutomirski wrote:
> > O_DENYMAND - to switch on/off three flags above.
> 
> O_DENYMAND doesn't deny anything.  Would a name like O_RESPECT_DENY be
> better?

Possibly rename to O_CHECK_DENY ?

	David

-- 
David Laight: david@l8s.co.uk
