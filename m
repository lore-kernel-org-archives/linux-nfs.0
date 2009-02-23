From: Omar Chanouha <chanouha@gmail.com>
Subject: School Project to Create Distributed Filesystem
Date: Mon, 23 Feb 2009 13:43:47 -0500
Message-ID: <130f58620902231043w3317c6cdrcedc6c4411cddadc@mail.gmail.com>
References: <130f58620902231036n527430bbp6cce2f322861a2ad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: greg.sheridan-/qnL7O6KwHDSiEDVxGk4TQ@public.gmane.org, ali.ezad@gmail.com,
	ankur_ece@gatech.edu
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.217.174]:52304 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131AbZBWSoC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2009 13:44:02 -0500
Received: by gxk22 with SMTP id 22so5521056gxk.13
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2009 10:44:00 -0800 (PST)
In-Reply-To: <130f58620902231036n527430bbp6cce2f322861a2ad-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Everyone,

        I have a school project this semster that involves creating a
distributed filesystem. The direct link to our proposal can be found
here:http://www.opensourceaficionado.com/winabi/tiki-download_file.php?fileId=5.
The website can be found here:
http://www.opensourceaficionado.com/winabi.

Essentially, what we want to do is create a distibuted filesystem via
a protocol we will create, but connect to it via nfs, so the client
does not need to have any special software on his/her pc. The section
I am assigned to is to create the nfs to winabi interface. Below is a
short example:

client ---NFS--->server--->winabi--->filesystem
client <---NFS---server<---winabi<---filesystem

I would like ANY help a kind sould is willing to offer. A few
questions that would be nice to have answered, but again, any
thoughts/comments you have would be appreciated.

1. Would modifying using space apps alone, ie. nfsutils, be enough?
(Probably not, right?)
2. Is there any documentation, I am having a little trouble finding
it? Specifically,
    -What comes with nfs-utils, and what do they do?
    -What is in the kernel, and what does it do?
3. If I have to modify kernel code, where is that code located?
    -If anyone could give me specific files to change, you would be my hero

Thanks alot!

-OFosho, Miami Dolphin and Linux Enthusiast
