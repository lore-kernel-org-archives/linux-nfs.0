Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aa.linuxbox.com ([134.215.213.37]:2834 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753063Ab1ARTgG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Jan 2011 14:36:06 -0500
Date: Tue, 18 Jan 2011 14:35:50 -0500 (EST)
From: "Matt W. Benjamin" <matt@linuxbox.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Daniel Muntz <Daniel.Muntz@emc.com>, rees@umich.edu,
        androsadamson@gmail.com, linux-nfs@vger.kernel.org,
        Benny Halevy <bhalevy@panasas.com>
Message-ID: <559269113.92.1295379350636.JavaMail.root@thunderbeast.private.linuxbox.com>
In-Reply-To: <553185711.90.1295379290216.JavaMail.root@thunderbeast.private.linuxbox.com>
Subject: Re: 4.1 no-pnfs mount option?
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

----- "Trond Myklebust" <Trond.Myklebust@netapp.com> wrote:

> "Why would an administrator never want to do this?" is not a helpful
> question.
> 
> A more useful question is "what reason would you possibly have for
> overriding the server's request that you do pNFS when your client has
> pNFS support?" What makes pNFS so special that we must allow
> administrators to do this on a per-mount basis?

Well, I phrased my question the other way because I suspect such cases will be found, but I may not have found all of them.  

Some thoughts on why I might wish to take a hand in the decision:

1. the client doing pnfs might behave badly due to a misconfiguration or outage, yet behave acceptably using ordinary nfsv4?
2. restricting the client to ordinary nfsv4 might be desirable for non-developer troubleshooting or other configuration work?

I apologize if neither is compelling.

> 
> Throwing more and more knobs into the kernel is easy. The difficult
> bit
> is to figure out which are useful knobs, and that is why I want real
> use
> cases... 
> 
> Trond
> 

Matt

-- 

Matt Benjamin

The Linux Box
206 South Fifth Ave. Suite 150
Ann Arbor, MI  48104

http://linuxbox.com

tel. 734-761-4689
fax. 734-769-8938
cel. 734-216-5309
