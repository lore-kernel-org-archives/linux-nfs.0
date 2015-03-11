Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541AbbCKUfx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2015 16:35:53 -0400
Date: Wed, 11 Mar 2015 16:35:52 -0400
To: "Benoit L'hoest" <b.lhoest@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Session Trunking
Message-ID: <20150311203552.GA25425@fieldses.org>
References: <CAF6uixBtLUm_Fv+iS8khL8UxfPwtYG1zqEyN9kUOSYgU-hHZ_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAF6uixBtLUm_Fv+iS8khL8UxfPwtYG1zqEyN9kUOSYgU-hHZ_g@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 10, 2015 at 02:18:01PM +0100, Benoit L'hoest wrote:
> Hello,
> 
> I'm a student in computer science and i'd like to make a review of nfs 4.1.
> I have a nfs server and a nfs client with 2 network interfaces and i'd
> like to use session trunking in order to improve the bandwith of my
> connection to the server.
> 
> How can i do it ?
> (i've seen it working with esxi 6.0 bu ti couldn't find a way to do it
> with nfs client in linux)

The linux client doesn't currently do trunking, so you'd have to add
support.  I don't know how big a project that would be....

The server does support trunking, though it's not gotten a lot of
testing (since the client doesn't use it).

--b.
