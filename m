From: Michael Guntsche <mike-Z92qn3yYq0hWk0Htik3J/w@public.gmane.org>
Subject: Re: Problem with 2.6.33-rc1 and insecure flag
Date: Sun, 20 Dec 2009 10:28:44 +0100
Message-ID: <20091220092844.GA1961@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:35175
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751558AbZLTJ2x (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Dec 2009 04:28:53 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Good morning

Some more info on this topic.

I tried mounting the same export from the server itself for testing.
Using the noresvport flag I got the same result as with the macosx
client.

mount -onoresvport gibson:/var/media /mnt
mount.nfs: Operation not permitted

The relevant part from my exports file.

/var/media         192.168.42.0/24(rw,async,no_subtree_check,insecure)
dreambox(rw,async,no_subtree_check,insecure,anonuid=1000)

Kind regards,
Michael
