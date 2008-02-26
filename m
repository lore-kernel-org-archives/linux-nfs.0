From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: Re: mountd prevents spindown of non-exported disk
Date: Tue, 26 Feb 2008 15:04:45 +0100
Message-ID: <47C41C7D.7030302@foo-lounge.de>
References: <47BCA119.2030404@foo-lounge.de> <18364.64328.189954.417159@notabene.brown> <47C2CFB1.4000004@foo-lounge.de> <47C2E3F9.2060104@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:48153 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569AbYBZOEv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Feb 2008 09:04:51 -0500
In-Reply-To: <47C2E3F9.2060104@uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benjamin Coddington wrote:
> Timo Reimann wrote:
>> Is there anything else I can do in attempt to resolve this issue? I
>> suppose pasting the complete output of strace might help, but I wouldn't
>> do so without explicit confirmation of yours as the log-file is 3.2 MB
>> large.
> 
> Maybe this is too simplistic, but have you tried exportfs -f?  Old entry
> in the kernel table?

I had to reboot the machine a couple of times, so I suppose that is
similar to calling exportfs -f.

Just to make sure, I tried the command too, but to no avail.


> Whats in /var/lib/nfs/xtab?

It's empty. Is that reason to worry?


--Timo
