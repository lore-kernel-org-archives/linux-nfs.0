Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55931 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755664Ab1JSRPv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 13:15:51 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RGZk7-0008Mn-3V
	for linux-nfs@vger.kernel.org; Wed, 19 Oct 2011 13:15:51 -0400
Date: Wed, 19 Oct 2011 13:15:51 -0400
To: linux-nfs@vger.kernel.org
Subject: Re: Does NFS4 need st_gen?
Message-ID: <20111019171551.GA32028@fieldses.org>
References: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87ipnlcbg8.fsf@inspiron.ap.columbia.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 10:17:43AM -0400, Nikolaus Rath wrote:
> Does NFS4 still depend on inode generation numbers? I understand that
> earlier NFS versions used file handles based on inode and generation
> number, but it seems to me that this shouldn't be required anymore with
> the (stateful) NFS4.

Yes, it's true that NFSv4 has open and close operations, but filehandles
are still used a great deal outside of that, and clients are still
allowed to assume that the same filehandle always refers to the same
object.

http://www.ietf.org/rfc/rfc3530.txt, section 4.2.1:

	"If two filehandles from the same server are equal, they MUST
	refer to the same file."

--b.
