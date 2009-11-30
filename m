From: Jesper Krogh <jesper-Q2TZfHgGEy4@public.gmane.org>
Subject: Re: Client cache updates missing? (2.6.31.5)
Date: Mon, 30 Nov 2009 19:30:55 +0100
Message-ID: <4B140F5F.6050107@krogh.cc>
References: <4B122FB2.7040505@krogh.cc> <20091130182643.GB6348@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:46654 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbZK3Saz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Nov 2009 13:30:55 -0500
In-Reply-To: <20091130182643.GB6348@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
>> Wether or not it has anything to do. The file has been written to the
>> NFS-server from another NFS-client. The server is running 2.6.31.5 and
>> the client that above was run on is 2.6.24-24 (Ubuntu Jaunty), the
>> client that wrote the file was running 2.6.29.1.
> 
> I this v3 or v4?  What's the exported filesystem?  (ext3?)

v3 and ext3

> It's probably a timestamp resolution problem; if the directory was
> modified twice in the same second, the later change won't change the
> timestamp, and so the client may assume its cache is still good.

That's not nice..  but given the situation is may quite well be the
problem.

> Recent clients try a little harder to work around this. 

How recent and how much harder?

> On the server
> side it should help to switch to a filesystem with better than 1-second
> timestamp resolution.

Converting filesystems takes time, the one with people $HOME on was
expected to be the last one to get "upgraded".

Jesper
-- 
Jesper
