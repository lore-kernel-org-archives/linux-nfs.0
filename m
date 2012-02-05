Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bontebok.le.ac.uk ([143.210.16.36]:46702 "EHLO
	bontebok.le.ac.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab2BEQzO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Feb 2012 11:55:14 -0500
Received: from 87-194-172-193.bethere.co.uk ([87.194.172.193]:56819 helo=[192.168.1.3])
	by bontebok.le.ac.uk with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.69)
	(envelope-from <liam.gretton@leicester.ac.uk>)
	id 1Ru5Mu-00019S-0i
	for linux-nfs@vger.kernel.org; Sun, 05 Feb 2012 16:55:12 +0000
Message-ID: <4F2EB471.9060508@leicester.ac.uk>
Date: Sun, 05 Feb 2012 16:55:13 +0000
From: Liam Gretton <liam.gretton@leicester.ac.uk>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: where can I ask user qns about nfs4?
References: <4F2A2F9E.6030908@steve-ss.com> <CAGue13owEdBsr+anLKrbW931QZHYC7RbwiSH_7WjBb5aXw4JJQ@mail.gmail.com> <4F2D9A0E.6010503@leicester.ac.uk> <4F2E4B50.5040701@steve-ss.com> <20120205141611.GA12826@umich.edu>
In-Reply-To: <20120205141611.GA12826@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/02/2012 14:16, Jim Rees wrote:
> There is a a NFS wiki, and it does have kerberos setup instructions:
> http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos
>
> The wiki has mostly been used by developers for developer info but it might
> be a good thing to use it for more general info too.

Thanks, the problem isn't getting NFS with Kerberos to work in general, 
it's with AD as the KDC. It seems that NFS still only accepts DES 
encrypted Kerberos tickets, and these are specifically disabled in 
Windows Server 2008 R2.

-- 
Liam Gretton                                    liam.gretton@le.ac.uk
HPC Architect                                http://www.le.ac.uk/its/
IT Services                                   Tel: +44 (0)116 2522254
University Of Leicester, University Road
Leicestershire LE1 7RH, United Kingdom
