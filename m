From: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Mon, 25 Feb 2008 10:51:21 -0500
Message-ID: <47C2E3F9.2060104@uvm.edu>
References: <47BCA119.2030404@foo-lounge.de> <18364.64328.189954.417159@notabene.brown> <47C2CFB1.4000004@foo-lounge.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eagle.uvm.edu ([132.198.101.203]:38353 "EHLO eagle.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754136AbYBYQnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Feb 2008 11:43:16 -0500
In-Reply-To: <47C2CFB1.4000004-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Timo Reimann wrote:
> Is there anything else I can do in attempt to resolve this issue? I
> suppose pasting the complete output of strace might help, but I wouldn't
> do so without explicit confirmation of yours as the log-file is 3.2 MB
> large.

Maybe this is too simplistic, but have you tried exportfs -f?  Old entry 
in the kernel table?

Whats in /var/lib/nfs/xtab?

~Ben
