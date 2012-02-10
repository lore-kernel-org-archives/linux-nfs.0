Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bontebok.le.ac.uk ([143.210.16.36]:38146 "EHLO
	bontebok.le.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab2BJUrp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2012 15:47:45 -0500
Received: from 87-194-172-193.bethere.co.uk ([87.194.172.193]:57022 helo=[192.168.1.3])
	by bontebok.le.ac.uk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <liam.gretton@leicester.ac.uk>)
	id 1RvxNf-0006tL-0v
	for linux-nfs@vger.kernel.org; Fri, 10 Feb 2012 20:47:43 +0000
Message-ID: <4F35826F.4020209@leicester.ac.uk>
Date: Fri, 10 Feb 2012 20:47:43 +0000
From: Liam Gretton <liam.gretton@leicester.ac.uk>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com> <4F2D9A0E.6010503@leicester.ac.uk> <4F2E4B50.5040701@steve-ss.com> <20120205141611.GA12826@umich.edu> <4F2EB471.9060508@leicester.ac.uk> <alpine.LNX.2.00.1202091707390.25543@localhost.localdomain>
In-Reply-To: <alpine.LNX.2.00.1202091707390.25543@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/02/2012 18:57, Don Riden wrote:
> I've recently managed to get a Linux Kerberized NFS server working
> using an Active Directory 2008 R2 domain controller as a KDC (using
> arcfour-hmac and aes256-cts-hmac-sha1-96).
>
> It's reasonably fiddly and took quite a lot of tweaking to get right.
>
> A short summary of the AD specific side of our configuration:

[snip]

Thanks very much for this information, it's very encouraging and I'll 
take another look at getting it working here.

> I'm surprised by the lack of documentation available on using Kerberised NFS with AD. I
> would have thought that it would be a fairly common configuration?

Me too. I'm working on knitting our Windows and Linux environments 
together, but all the hard work has to be done at the Linux end (as usual).

I hereby solemnly promise to document my experience on a blog somewhere 
assuming I make some progress and can add to the global knowledge pool.

-- 
Liam Gretton                                    liam.gretton@le.ac.uk
HPC Architect                                http://www.le.ac.uk/its/
IT Services                                   Tel: +44 (0)116 2522254
University Of Leicester, University Road
Leicestershire LE1 7RH, United Kingdom
